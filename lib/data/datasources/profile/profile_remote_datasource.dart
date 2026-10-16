// lib/data/datasources/profile/profile_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/exception.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/base_api/base_api_response_model.dart';
import '../../models/profile/profile_model.dart';

abstract class IProfileRemoteDataSource {
  Future<FotoProfilModel> gantiFoto(GantiFotoPayloadModel payload);
  Future<KirimOtpKontakResponseModel> kirimOtpKontak(
    KirimOtpKontakRequestModel request,
  );
  Future<KontakProfilModel> verifikasiOtpKontak(
    VerifikasiOtpKontakRequestModel request,
  );
}

@LazySingleton(as: IProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements IProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSourceImpl(this._dio);

  @override
  Future<FotoProfilModel> gantiFoto(GantiFotoPayloadModel payload) async {
    final response = await _dio.post(
      ApiEndpoints.profileGantiFoto,
      data: await payload.toFormData(),
    );
    return _parse(
      response,
      (json) => FotoProfilModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<KirimOtpKontakResponseModel> kirimOtpKontak(
    KirimOtpKontakRequestModel request,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.profileKirimOtpKontak,
      data: request.toJson(),
    );
    return _parse(
      response,
      (json) =>
          KirimOtpKontakResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<KontakProfilModel> verifikasiOtpKontak(
    VerifikasiOtpKontakRequestModel request,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.profileVerifikasiOtpKontak,
      data: request.toJson(),
    );
    return _parse(
      response,
      (json) => KontakProfilModel.fromJson(json as Map<String, dynamic>),
    );
  }

  T _parse<T>(Response response, T Function(Object? json) fromJson) {
    final base = BaseApiResponseModel<T>.fromJson(
      response.data as Map<String, dynamic>,
      fromJson,
    );
    if (!base.isSuccess || base.data == null) {
      throw ServerException(base.status, base.errorMessage);
    }
    return base.data as T;
  }
}
