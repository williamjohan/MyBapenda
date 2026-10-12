import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exception.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../core/network/base_api/base_api_response_model.dart';
import '../../models/cek_reklame/cek_reklame_model.dart'; 

abstract class ICekReklameRemoteDataSource {
  Future<bool> uploadReklame(CekReklameUploadRequest request);
}

@LazySingleton(as: ICekReklameRemoteDataSource)
class CekReklameRemoteDataSourceImpl implements ICekReklameRemoteDataSource {
  final Dio _dio;

  CekReklameRemoteDataSourceImpl(this._dio);

  @override
  Future<bool> uploadReklame(CekReklameUploadRequest request) async {
    // 1. Tembak API dan biarkan model yang merakit FormData-nya
    final response = await _dio.post(
      ApiEndpoints.uploadReklame,
      data: await request.toFormData(), 
    );

    final baseResponse = BaseApiResponseModel<dynamic>.fromJson(
      response.data,
      (json) => json, 
    );

    if (!baseResponse.isSuccess) {
      throw ServerException(baseResponse.status, baseResponse.errorMessage);
    }

    return true;
  }
}