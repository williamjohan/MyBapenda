import 'package:bapendacore/data/models/balai_rw/laporan_payload_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/exception.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../core/network/base_api/base_api_response_model.dart';
import '../../models/balai_rw/kategori_pertanyaan_model.dart';
import '../../models/balai_rw/laporan_pegawai_model.dart';
import '../../models/balai_rw/pertanyaan_model.dart';
import '../../models/balai_rw/roster_pegawai_model.dart';

abstract class IBalaiRwRemoteDataSource {
  Future<List<KategoriPertanyaanModel>> getKategori({required bool hanyaAktif});

  Future<List<PertanyaanModel>> getPertanyaan({
    int? idKategori,
    required bool hanyaAktif,
  });

  Future<List<RosterPegawaiModel>> getRosterPegawai({
    required String tanggalAwal,
    required String tanggalAkhir,
  });

  //Get Laporannya
  Future<List<LaporanPegawaiModel>> getLaporanAbsensi({
    required String tanggalAwal,
    required String tanggalAkhir,
  });

  Future<bool> postCheckin(CheckinPayloadModel payload);
  Future<bool> postCheckout(CheckoutPayloadModel payload);
  Future<bool> postLaporanPegawai(LaporanPayloadModel payload);
}

@LazySingleton(as: IBalaiRwRemoteDataSource)
class BalaiRwRemoteDataSourceImpl implements IBalaiRwRemoteDataSource {
  final Dio _dio;

  BalaiRwRemoteDataSourceImpl(this._dio);

  @override
  Future<List<KategoriPertanyaanModel>> getKategori({
    required bool hanyaAktif,
  }) async {
    final response = await _dio.get(
      ApiEndpoints
          .masterKategori, // Sesuaikan path ini (cth: '/api/umpeg/master/kategori')
      queryParameters: {'hanyaAktif': hanyaAktif},
    );

    final baseResponse =
        BaseApiResponseModel<List<KategoriPertanyaanModel>>.fromJson(
          response.data,
          (json) => (json as List)
              .map(
                (e) =>
                    KategoriPertanyaanModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        );

    if (!baseResponse.isSuccess) {
      throw ServerException(baseResponse.status, baseResponse.errorMessage);
    }

    return baseResponse.data ?? [];
  }

  @override
  Future<List<PertanyaanModel>> getPertanyaan({
    int? idKategori,
    required bool hanyaAktif,
  }) async {
    final queryParams = <String, dynamic>{'hanyaAktif': hanyaAktif};
    if (idKategori != null) {
      queryParams['idKategori'] = idKategori;
    }

    final response = await _dio.get(
      ApiEndpoints.masterPertanyaan,
      queryParameters: queryParams,
    );

    final baseResponse = BaseApiResponseModel<List<PertanyaanModel>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((e) => PertanyaanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    if (!baseResponse.isSuccess) {
      throw ServerException(baseResponse.status, baseResponse.errorMessage);
    }

    return baseResponse.data ?? [];
  }

  @override
  Future<List<RosterPegawaiModel>> getRosterPegawai({
    required String tanggalAwal,
    required String tanggalAkhir,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.rosterPegawai,
      queryParameters: {
        'tanggalAwal': tanggalAwal,
        'tanggalAkhir': tanggalAkhir,
      },
    );

    final baseResponse =
        BaseApiResponseModel<List<RosterPegawaiModel>>.fromJson(
          response.data,
          (json) => (json as List)
              .map(
                (e) => RosterPegawaiModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        );

    if (!baseResponse.isSuccess) {
      throw ServerException(baseResponse.status, baseResponse.errorMessage);
    }
    return baseResponse.data ?? [];
  }

  @override
  Future<List<LaporanPegawaiModel>> getLaporanAbsensi({
    required String tanggalAwal,
    required String tanggalAkhir,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.laporanAbsensi,
      queryParameters: {
        'tanggalAwal': tanggalAwal,
        'tanggalAkhir': tanggalAkhir,
      },
    );

    final baseResponse =
        BaseApiResponseModel<List<LaporanPegawaiModel>>.fromJson(
          response.data,
          (json) => (json as List)
              .map(
                (e) => LaporanPegawaiModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        );

    if (!baseResponse.isSuccess) {
      throw ServerException(baseResponse.status, baseResponse.errorMessage);
    }

    return baseResponse.data ?? [];
  }



  // ===========================================================================
  // POST LAPORAN PEGAWAI
  // ===========================================================================
  Future<bool> _postForm(String path, FormData form) async {
    final response = await _dio.post(path, data: form);

    final base = BaseApiResponseModel<dynamic>.fromJson(
      response.data,
      (json) => json,
    );
    if (!base.isSuccess) {
      throw ServerException(base.status, base.errorMessage);
    }
    return true;
  }

  @override
  Future<bool> postCheckin(CheckinPayloadModel payload) async =>
      _postForm(ApiEndpoints.checkin, await payload.toFormData());

  @override
  Future<bool> postCheckout(CheckoutPayloadModel payload) async =>
      _postForm(ApiEndpoints.checkout, await payload.toFormData());

  @override
  Future<bool> postLaporanPegawai(LaporanPayloadModel payload) async =>
      _postForm(ApiEndpoints.laporanAbsensi, await payload.toFormData());
}
