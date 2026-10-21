import 'dart:io';

import 'package:mybapenda/data/models/survey_permohonan_baru/survey_history_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/exception.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/base_api/base_api_response_model.dart';

abstract class ISurveyHistoryRemoteDataSource {
  Future<List<SurveyHistoryModel>> getHistory({
    DateTime? tglAwal,
    DateTime? tglAkhir,
  });

  Future<SurveyHistoryDetailModel> getHistoryDetail({required String key});
  Future<String> downloadFile({required String url, required String fileName});
}

@LazySingleton(as: ISurveyHistoryRemoteDataSource)
class SurveyHistoryRemoteDataSourceImpl
    implements ISurveyHistoryRemoteDataSource {
  final Dio _dio;

  SurveyHistoryRemoteDataSourceImpl(this._dio);

  static String _ymd(DateTime d) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${p(d.month)}-${p(d.day)}';
  }

  // ===========================================================================
  // 1. GET LIST HISTORY
  // ===========================================================================
  @override
  Future<List<SurveyHistoryModel>> getHistory({
    DateTime? tglAwal,
    DateTime? tglAkhir,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.surveyHistory,
      queryParameters: {
        if (tglAwal != null) 'tglAwal': _ymd(tglAwal),
        if (tglAkhir != null) 'tglAkhir': _ymd(tglAkhir),
      },
    );

    final apiResponse = BaseApiResponseModel<List<SurveyHistoryModel>>.fromJson(
      response.data,
      (json) => (json as List)
          .map(
            (e) => SurveyHistoryModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );

    if (!apiResponse.isSuccess) {
      throw ServerException(apiResponse.status, apiResponse.errorMessage);
    }

    return apiResponse.data ?? [];
  }

  // ===========================================================================
  // 2. GET DETAIL HISTORY
  // ===========================================================================
  @override
  Future<SurveyHistoryDetailModel> getHistoryDetail({
    required String key,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.surveyHistoryDetail,
      queryParameters: {'key': key},
    );

    final apiResponse = BaseApiResponseModel<SurveyHistoryDetailModel>.fromJson(
      response.data,
      (json) => SurveyHistoryDetailModel.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    if (!apiResponse.isSuccess) {
      throw ServerException(apiResponse.status, apiResponse.errorMessage);
    }

    if (apiResponse.data == null) {
      throw const ServerException(
        404,
        'Detail history survey tidak ditemukan.',
      );
    }

    return apiResponse.data!;
  }

  @override
  Future<String> downloadFile({
    required String url,
    required String fileName,
  }) async {
    final path = '${Directory.systemTemp.path}/$fileName';
    await _dio.download(url, path);
    return path;
  }
}
