// lib/data/datasources/my_task/my_task_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mybapenda/core/network/api_endpoints.dart';
import 'package:mybapenda/core/network/base_api/base_api_response_model.dart';
import 'package:mybapenda/data/models/my_task/my_task_checkin_model.dart';
import 'package:mybapenda/data/models/my_task/my_task_model.dart';
import '../../../core/errors/exception.dart';

abstract class IMyTaskRemoteDataSource {
  Future<MyTaskHeaderModel> getHeader({int page = 1, int pageSize = 50});

  Future<MyTaskDetailModel> getHeaderDetail({
    required String jenis,
    required String key,
  });

  Future<bool> checkin(MyTaskCheckinRequestModel request);
}

@LazySingleton(as: IMyTaskRemoteDataSource)
class MyTaskRemoteDataSourceImpl implements IMyTaskRemoteDataSource {
  final Dio _dio;
  MyTaskRemoteDataSourceImpl(this._dio);

  @override
  Future<MyTaskHeaderModel> getHeader({int page = 1, int pageSize = 50}) async {
    final response = await _dio.get(
      ApiEndpoints.myTaskHeader,
      queryParameters: {'Page': page, 'PageSize': pageSize},
    );

    final raw = response.data as Map<String, dynamic>;
    final apiResponse = BaseApiResponseModel<MyTaskHeaderModel>.fromJson(
      raw,
      (json) => MyTaskHeaderModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess) {
      throw ServerException(apiResponse.status, apiResponse.errorMessage);
    }

    return apiResponse.data!;
  }

  @override
  Future<MyTaskDetailModel> getHeaderDetail({
    required String jenis,
    required String key,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.myTaskHeaderDetail,
      queryParameters: {'Jenis': jenis, 'Key': key},
    );

    final raw = response.data as Map<String, dynamic>;
    final apiResponse = BaseApiResponseModel<MyTaskDetailModel>.fromJson(
      raw,
      (json) => MyTaskDetailModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess) {
      throw ServerException(apiResponse.status, apiResponse.errorMessage);
    }

    return apiResponse.data!;
  }

  @override
  Future<bool> checkin(MyTaskCheckinRequestModel request) async {
    final response = await _dio.post(
      ApiEndpoints.myTaskCheckin,
      data: await request.toFormData(),
      // Tiga foto lewat sinyal lemah butuh waktu lebih lama.
      options: Options(
        sendTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
      ),
    );

    final raw = response.data as Map<String, dynamic>;
    final apiResponse = BaseApiResponseModel<dynamic>.fromJson(
      raw,
      (json) => json,
    );

    if (!apiResponse.isSuccess) {
      throw ServerException(apiResponse.status, apiResponse.errorMessage);
    }
    return true;
  }
}
