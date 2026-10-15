import 'package:bapendacore/core/errors/exception.dart';
import 'package:bapendacore/core/network/api_endpoints.dart';
import 'package:bapendacore/core/network/base_api/base_api_response_model.dart';
import 'package:bapendacore/presentation/shared/master_data/data/models/master_option_model.dart';
import 'package:bapendacore/presentation/shared/master_data/data/models/paged_master_data_model.dart';
import 'package:bapendacore/presentation/shared/master_data/domain/entities/master_option_type.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class IMasterRemoteDataSource {
  Future<List<MasterOptionModel>> getOptions(MasterOptionType type);
  Future<List<MasterOptionModel>> getKelurahan(String kecamatanId);

  Future<PagedModel<JalanItemModel>> getJalan({
    required String keyword,
    required int page,
    required int pageSize,
  });

  Future<PagedModel<PersilItemModel>> getPersil({
    required String keyword,
    required int page,
    required int pageSize,
  });

  Future<PagedModel<PegawaiSurveyModel>> getPegawaiSurvey({
    required String keyword,
    required int page,
    required int pageSize,
  });
}

@LazySingleton(as: IMasterRemoteDataSource)
class MasterRemoteDataSourceImpl implements IMasterRemoteDataSource {
  final Dio _dio;

  MasterRemoteDataSourceImpl(this._dio);

  static const _kecamatanParam = 'idKecamatan';

  // ===========================================================================
  // LIST BIASA ({id, nama})
  // ===========================================================================

  String _endpointFor(MasterOptionType type) => switch (type) {
    MasterOptionType.lokasiTertentu => ApiEndpoints.reklameMasterLokasiTertentu,
    MasterOptionType.lokasiPenyelenggaraan => ApiEndpoints.reklameMasterLokasiPenyelenggaraan,
    MasterOptionType.jenisReklame => ApiEndpoints.reklameMasterJenisReklame,
    MasterOptionType.jenisProduk => ApiEndpoints.reklameMasterJenisProduk,
    MasterOptionType.letakReklame => ApiEndpoints.reklameMasterLetakReklame,
    MasterOptionType.statusTanah => ApiEndpoints.reklameMasterStatusTanah,
    MasterOptionType.sudutPandang => ApiEndpoints.reklameMasterSudutPandang,
    MasterOptionType.jenisBangunan => ApiEndpoints.reklameMasterJenisBangunan,
    MasterOptionType.kecamatan => ApiEndpoints.reklameMasterKecamatan,
  };

  @override
  Future<List<MasterOptionModel>> getOptions(MasterOptionType type) =>
      _getList<MasterOptionModel>(
        _endpointFor(type),
        parseItem: MasterOptionModel.fromJson,
      );

  @override
  Future<List<MasterOptionModel>> getKelurahan(String kecamatanId) =>
      _getList<MasterOptionModel>(
        ApiEndpoints.reklameMasterKelurahan,
        parseItem: MasterOptionModel.fromJson,
        queryParameters: {_kecamatanParam: kecamatanId},
      );

  Future<List<T>> _getList<T>(
    String path, {
    required T Function(Map<String, dynamic> json) parseItem,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);

    final baseResponse = BaseApiResponseModel<List<T>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((e) => parseItem(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

    if (!baseResponse.isSuccess) {
      throw ServerException(baseResponse.status, baseResponse.errorMessage);
    }

    return baseResponse.data ?? <T>[];
  }

  // ===========================================================================
  // YANG ADA PAGINATION & SEARCHING
  // ===========================================================================

  @override
  Future<PagedModel<JalanItemModel>> getJalan({
    required String keyword,
    required int page,
    required int pageSize,
  }) => _getPage(
    ApiEndpoints.reklameMasterNamaJalan,
    keyword: keyword,
    page: page,
    pageSize: pageSize,
    parseItem: JalanItemModel.fromJson,
  );

  @override
  Future<PagedModel<PersilItemModel>> getPersil({
    required String keyword,
    required int page,
    required int pageSize,
  }) => _getPage(
    ApiEndpoints.reklameMasterPersil,
    keyword: keyword,
    page: page,
    pageSize: pageSize,
    parseItem: PersilItemModel.fromJson,
  );

  @override
  Future<PagedModel<PegawaiSurveyModel>> getPegawaiSurvey({
    required String keyword,
    required int page,
    required int pageSize,
  }) => _getPage(
    ApiEndpoints.reklameMasterPegawaiSurvey,
    keyword: keyword,
    page: page,
    pageSize: pageSize,
    parseItem: PegawaiSurveyModel.fromJson,
  );

  Future<PagedModel<T>> _getPage<T>(
    String path, {
    required String keyword,
    required int page,
    required int pageSize,
    required T Function(Map<String, dynamic> json) parseItem,
  }) async {
    final response = await _dio.get(
      path,
      queryParameters: {
        if (keyword.isNotEmpty) 'Keyword': keyword,
        'Page': page,
        'PageSize': pageSize,
      },
    );

    final baseResponse = BaseApiResponseModel<PagedModel<T>>.fromJson(
      response.data,
      // fromAny: menerima objek berhalaman maupun list biasa.
      (json) => PagedModel<T>.fromAny(json, parseItem),
    );

    if (!baseResponse.isSuccess) {
      throw ServerException(baseResponse.status, baseResponse.errorMessage);
    }

    return baseResponse.data ?? PagedModel<T>.empty();
  }
}
