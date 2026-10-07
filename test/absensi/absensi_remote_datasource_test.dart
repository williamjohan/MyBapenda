import 'dart:convert';
import 'dart:typed_data';

import 'package:bapendacore/core/errors/exception.dart';
import 'package:bapendacore/data/datasources/absensi/absensi_remote_datasource.dart';
import 'package:bapendacore/data/models/absensi/absen_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adapter palsu: kembalikan body & header tetap untuk request apa pun.
class _FakeAdapter implements HttpClientAdapter {
  final int statusCode;
  final List<int> body;
  final Map<String, List<String>> headers;

  _FakeAdapter(this.statusCode, this.body, this.headers);

  _FakeAdapter.json(int statusCode, Map<String, dynamic> json)
    : this(statusCode, utf8.encode(jsonEncode(json)), {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromBytes(body, statusCode, headers: headers);

  @override
  void close({bool force = false}) {}
}

AbsensiRemoteDataSourceImpl _dataSource(HttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = adapter;
  return AbsensiRemoteDataSourceImpl(dio);
}

Map<String, dynamic> _gagal(int status, String message) => {
  'isSuccess': false,
  'title': 'Terjadi Kesalahan',
  'status': status,
  'traceId': 'x',
  'errors': [message],
  'data': null,
};

class _RecordingAdapter extends _FakeAdapter {
  RequestOptions? last;
  _RecordingAdapter()
    : super(200, utf8.encode('%PDF'), {
        Headers.contentTypeHeader: ['application/pdf'],
      });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    last = options;
    return super.fetch(options, requestStream, cancelFuture);
  }
}

void main() {
  test('PDF diminta sebagai bytes, tanpa retry otomatis', () async {
    final adapter = _RecordingAdapter();
    await _dataSource(adapter).downloadLaporanPdf(tahun: 2026, bulan: 9);

    final req = adapter.last!;
    expect(req.responseType, ResponseType.bytes);
    expect(req.extra['ro_disable_retry'], isTrue);
    expect(req.queryParameters, {'tahun': 2026, 'bulan': 9});
    expect(req.headers['Accept'], contains('application/pdf'));
  });

  test(
    'HTTP 200 dengan isSuccess=false → ServerException berisi errors[0]',
    () async {
      final ds = _dataSource(
        _FakeAdapter.json(200, _gagal(400, 'Tanggal tidak valid.')),
      );

      await expectLater(
        ds.getRingkasan(),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Tanggal tidak valid.',
          ),
        ),
      );
    },
  );

  test('absen sukses membawa title sebagai pesan', () async {
    final ds = _dataSource(
      _FakeAdapter.json(200, {
        'isSuccess': true,
        'title': 'Absen pulang tercatat',
        'status': 200,
        'errors': null,
        'data': {
          'tglPresensi': '2026-10-02T16:41:00',
          'jenis': 'PULANG',
          'menitTelat': 0,
          'menitPsw': 0,
          'ringkasan': {'nip': '1', 'nama': 'A', 'tanggal': '2026-10-02'},
        },
      }),
    );

    final result = await ds.absen(
      const AbsenRequestModel(
        kodeDevice: '6f1c2a0e-8a3b-4c1d-9e2f-0b7a5d3c1e44',
        namaDevice: 'Ponsel 24069PC21G',
        merkModel: 'Xiaomi 24069PC21G',
        osVersion: 'Android 14',
        latitude: -7.2593812,
        longitude: 112.7495031,
        akurasiMeter: 8.5,
        isMockLocation: false,
        metodeVerifikasi: 'BIOMETRIC_HP',
        appVersion: '1.0.0',
      ),
    );

    expect(result.message, 'Absen pulang tercatat');
    expect(result.data.jenis, 'PULANG');
  });

  test(
    'PDF: content-type JSON (gagal bisnis) tidak disimpan sebagai file',
    () async {
      final ds = _dataSource(
        _FakeAdapter.json(200, _gagal(400, 'Periode tidak valid.')),
      );

      await expectLater(
        ds.downloadLaporanPdf(tahun: 2030, bulan: 1),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Periode tidak valid.',
          ),
        ),
      );
    },
  );

  test('PDF: error HTTP 400 dengan body bytes JSON di-decode', () async {
    final ds = _dataSource(
      _FakeAdapter.json(400, _gagal(400, 'Periode tidak valid.')),
    );

    await expectLater(
      ds.downloadLaporanPdf(tahun: 2030, bulan: 1),
      throwsA(
        isA<DioException>().having(
          (e) => (e.response?.data as Map)['errors'],
          'errors',
          ['Periode tidak valid.'],
        ),
      ),
    );
  });

  test('PDF sukses: bytes & nama file dari Content-Disposition', () async {
    final pdfBytes = utf8.encode('%PDF-1.4 dummy');
    final ds = _dataSource(
      _FakeAdapter(200, pdfBytes, {
        Headers.contentTypeHeader: ['application/pdf'],
        'content-disposition': [
          'attachment; filename=Kehadiran_3506192511010005_202609.pdf',
        ],
      }),
    );

    final result = await ds.downloadLaporanPdf(tahun: 2026, bulan: 9);

    expect(result.bytes, pdfBytes);
    expect(result.fileName, 'Kehadiran_3506192511010005_202609.pdf');
  });
}
