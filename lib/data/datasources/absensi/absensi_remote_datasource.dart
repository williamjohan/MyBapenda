import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/exception.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/base_api/base_api_response_model.dart';
import '../../models/absensi/absen_model.dart';
import '../../models/absensi/riwayat_absensi_model.dart';
import '../../models/absensi/ringkasan_absensi_model.dart';

/// Hasil unduhan PDF mentah dari server.
class LaporanPdfResponse {
  final List<int> bytes;

  /// Dari header `Content-Disposition`, null jika server tidak mengirim.
  final String? fileName;

  const LaporanPdfResponse({required this.bytes, this.fileName});
}

abstract class AbsensiRemoteDataSource {
  Future<RingkasanAbsensiModel> getRingkasan({String? tanggal});

  Future<RiwayatAbsensiPageModel> getRiwayat({
    required int page,
    required int pageSize,
    int? tahun,
    int? bulan,
  });

  /// [message] = `title` dari server, mis. "Absen masuk tercatat".
  Future<({AbsenResultModel data, String message})> absen(
    AbsenRequestModel request,
  );

  Future<LaporanPdfResponse> downloadLaporanPdf({
    required int tahun,
    required int bulan,
    void Function(int received, int total)? onReceiveProgress,
  });
}

@LazySingleton(as: AbsensiRemoteDataSource)
class AbsensiRemoteDataSourceImpl implements AbsensiRemoteDataSource {
  final Dio _dio;
  AbsensiRemoteDataSourceImpl(this._dio);

  @override
  Future<RingkasanAbsensiModel> getRingkasan({String? tanggal}) async {
    final response = await _dio.get(
      ApiEndpoints.absensiRingkasan,
      queryParameters: {if (tanggal != null) 'tanggal': tanggal},
    );
    return _unwrap(
      response.data,
      (json) => RingkasanAbsensiModel.fromJson(json as Map<String, dynamic>),
    ).data;
  }

  @override
  Future<RiwayatAbsensiPageModel> getRiwayat({
    required int page,
    required int pageSize,
    int? tahun,
    int? bulan,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.absensiRiwayat,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (tahun != null) 'tahun': tahun,
        if (bulan != null) 'bulan': bulan,
      },
    );
    return _unwrap(
      response.data,
      (json) => RiwayatAbsensiPageModel.fromJson(json as Map<String, dynamic>),
    ).data;
  }

  @override
  Future<({AbsenResultModel data, String message})> absen(
    AbsenRequestModel request,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.absensiAbsen,
      data: request.toJson(),
    );
    final result = _unwrap(
      response.data,
      (json) => AbsenResultModel.fromJson(json as Map<String, dynamic>),
    );
    return (data: result.data, message: result.title ?? 'Absen tercatat');
  }

  @override
  Future<LaporanPdfResponse> downloadLaporanPdf({
    required int tahun,
    required int bulan,
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    final Response<List<int>> response;
    try {
      response = await _dio.get<List<int>>(
        ApiEndpoints.absensiLaporanPdf,
        queryParameters: {'tahun': tahun, 'bulan': bulan},
        options: Options(
          // Ambil mentah sebagai bytes → disimpan ke .pdf oleh repository.
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/pdf, application/json'},
          // Generate PDF itu berat: jangan diulang otomatis saat 500/timeout
          // (default RetryInterceptor = 3x ulang), biar server tidak dipukul 4x.
          extra: {'ro_disable_retry': true},
        ),
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      // Body error berupa bytes JSON → decode agar DioErrorHandler bisa
      // membaca `errors[0]` seperti endpoint lain.
      throw _decodeBytesError(e);
    }

    final bytes = response.data ?? const <int>[];
    final contentType = response.headers.value(Headers.contentTypeHeader) ?? '';

    // Gagal bisnis bisa tetap HTTP 200 dengan envelope JSON.
    if (!contentType.contains('application/pdf')) {
      final json = _tryDecodeJson(bytes);
      if (json != null) {
        _unwrap(json, (data) => data);
      }
      throw const ServerException(
        500,
        'Format laporan dari server tidak dikenali.',
      );
    }

    return LaporanPdfResponse(
      bytes: bytes,
      fileName: _parseFileName(response.headers.value('content-disposition')),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Bongkar envelope `{ isSuccess, title, status, traceId, errors, data }`.
  /// Selalu cek `isSuccess`, karena error bisnis bisa HTTP 200.
  ({T data, String? title}) _unwrap<T>(
    dynamic raw,
    T Function(Object? json) fromJsonT,
  ) {
    final apiResponse = BaseApiResponseModel<T>.fromJson(
      raw as Map<String, dynamic>,
      fromJsonT,
    );
    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ServerException(apiResponse.status, apiResponse.errorMessage);
    }
    return (data: apiResponse.data as T, title: apiResponse.title);
  }

  DioException _decodeBytesError(DioException e) {
    final data = e.response?.data;
    if (data is! List<int>) return e;

    final json = _tryDecodeJson(data);
    if (json == null) return e;

    return e.copyWith(
      response: Response(
        requestOptions: e.requestOptions,
        statusCode: e.response?.statusCode,
        headers: e.response?.headers,
        data: json,
      ),
    );
  }

  Map<String, dynamic>? _tryDecodeJson(List<int> bytes) {
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// `attachment; filename=Kehadiran_<NIP>_202609.pdf`
  String? _parseFileName(String? contentDisposition) {
    if (contentDisposition == null) return null;
    final match = RegExp(
      r'''filename\*?=(?:UTF-8'')?"?([^";]+)"?''',
      caseSensitive: false,
    ).firstMatch(contentDisposition);
    return match?.group(1)?.trim();
  }
}
