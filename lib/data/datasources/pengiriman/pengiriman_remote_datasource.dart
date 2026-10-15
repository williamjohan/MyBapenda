import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/exception.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/base_api/base_api_response_model.dart';
import '../../models/pengiriman/berkas_model.dart';
import '../../models/pengiriman/lacak_model.dart';
import '../../models/pengiriman/master_pengiriman_model.dart';

abstract class IPengirimanRemoteDataSource {
  Future<MasterPengirimanModel> getMaster();

  /// Semua tugas login, urut batas SLA.
  Future<List<BerkasModel>> getDaftar();

  Future<BerkasDetailModel> getDetail(String noResi);

  /// [kode] = isi QR apa adanya (no resi polos atau URL lacak).
  Future<LacakResultModel> getLacak(String kode);

  Future<List<HasilCheckinModel>> postAmbil(FormData form);

  /// POST aksi dari antrean (perjalanan, tiba, serah, gagal, kembalikan).
  Future<List<HasilCheckinModel>> postForm(String endpoint, FormData form);
}

@LazySingleton(as: IPengirimanRemoteDataSource)
class PengirimanRemoteDataSourceImpl implements IPengirimanRemoteDataSource {
  final Dio _dio;

  PengirimanRemoteDataSourceImpl(this._dio);

  @override
  Future<MasterPengirimanModel> getMaster() async {
    final response = await _dio.get(ApiEndpoints.pengirimanMaster);
    return _unwrap(
      response.data,
      (json) => MasterPengirimanModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<List<BerkasModel>> getDaftar() async {
    final response = await _dio.get(ApiEndpoints.pengirimanDaftar);
    return _unwrap(
      response.data,
      (json) => (json as List? ?? [])
          .map((e) => BerkasModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<BerkasDetailModel> getDetail(String noResi) async {
    final response = await _dio.get(
      ApiEndpoints.pengirimanDetail,
      queryParameters: {'noResi': noResi},
    );
    return _unwrap(
      response.data,
      (json) => BerkasDetailModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<LacakResultModel> getLacak(String kode) async {
    final response = await _dio.get(
      ApiEndpoints.pengirimanLacak,
      queryParameters: {'kode': kode},
    );
    return _unwrap(
      response.data,
      (json) => LacakResultModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<List<HasilCheckinModel>> postAmbil(FormData form) =>
      _post(ApiEndpoints.pengirimanAmbil, form);

  @override
  Future<List<HasilCheckinModel>> postForm(String endpoint, FormData form) =>
      _post(endpoint, form);

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Bongkar envelope `{ isSuccess, title, status, errors, data }`.
  /// Selalu cek `isSuccess`, karena error bisnis bisa HTTP 200.
  T _unwrap<T>(dynamic raw, T Function(Object? json) fromJsonT) {
    final base = BaseApiResponseModel<T>.fromJson(
      raw as Map<String, dynamic>,
      fromJsonT,
    );
    if (!base.isSuccess || base.data == null) {
      throw ServerException(base.status, base.errorMessage);
    }
    return base.data as T;
  }

  /// `ambil`/`kembalikan` mengembalikan `HasilCheckin[]`; endpoint lain bisa
  /// satu objek atau kosong, jadi dinormalkan ke list.
  Future<List<HasilCheckinModel>> _post(String path, FormData form) async {
    final response = await _dio.post(path, data: form);
    final base = BaseApiResponseModel<dynamic>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => json,
    );
    if (!base.isSuccess) {
      throw ServerException(base.status, base.errorMessage);
    }
    final data = base.data;
    final list = data is List ? data : (data is Map ? [data] : const []);
    return list
        .map((e) => HasilCheckinModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
