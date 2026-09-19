import 'package:bapendacore/core/network/api_endpoints.dart';
import 'package:bapendacore/core/network/base_api/base_api_response_model.dart';
import 'package:bapendacore/data/models/auth/auth_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(AuthRequestModel request);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthResponseModel> login(AuthRequestModel request) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );

    final apiResponse = BaseApiResponseModel<AuthResponseModel>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw Exception(apiResponse.errorMessage);
    }
    return apiResponse.data!;
  }
}
