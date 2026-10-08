import 'package:bapendacore/core/network/api_endpoints.dart';
import 'package:bapendacore/core/network/base_api/base_api_response_model.dart';
import 'package:bapendacore/data/models/history/history_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/exception.dart';

abstract class HistoryRemoteDataSource {
  Future<List<HistoryModel>> getHistory({
    required String tanggalAwal,
    required String tanggalAkhir,
    required int startData,
    required int jmlData,
  });
}

@LazySingleton(as: HistoryRemoteDataSource)
class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final Dio _dio;
  HistoryRemoteDataSourceImpl(this._dio);

  @override
  Future<List<HistoryModel>> getHistory({
    required String tanggalAwal,
    required String tanggalAkhir,
    required int startData,
  required int jmlData,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.historyList,
      queryParameters: {
        'TanggalAwal': tanggalAwal,
        'TanggalAkhir': tanggalAkhir,
        'StartData': startData,
        'JmlData': jmlData,
      },
    );

    final raw = response.data as Map<String, dynamic>;
    final apiResponse = BaseApiResponseModel<List<HistoryModel>>.fromJson(
      raw,
      (json) => (json as List<dynamic>)
          .map((e) => HistoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

     if (!apiResponse.isSuccess) {
      throw ServerException(apiResponse.status, apiResponse.errorMessage);
    }
    
    return apiResponse.data ?? [];
  }
}
