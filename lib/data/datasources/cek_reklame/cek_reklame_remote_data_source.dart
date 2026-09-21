import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exception.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../core/network/base_api/base_api_response_model.dart'; 

abstract class CekReklameRemoteDataSource {
  Future<bool> uploadReklame({
    required File file,
    required String latitude,
    required String longitude,
    required String alamat,
  });
}

@LazySingleton(as: CekReklameRemoteDataSource)
class CekReklameRemoteDataSourceImpl implements CekReklameRemoteDataSource {
  final Dio _dio;

  CekReklameRemoteDataSourceImpl(this._dio);

  @override
  Future<bool> uploadReklame({
    required File file,
    required String latitude,
    required String longitude,
    required String alamat,
  }) async {
    // 1. Merakit form-data sesuai cURL endpoint
    final formData = FormData.fromMap({
      'Latitude': latitude,
      'Longitude': longitude,
      'Alamat': alamat,
      'File': await MultipartFile.fromFile(
        file.path, 
        filename: 'reklame_capture.jpg',
      ),
    });

    // 2. Tembak API
    final response = await _dio.post(
      ApiEndpoints.uploadReklame, // Pastikan ini bernilai '/api/cekreklame/upload-reklame'
      data: formData,
    );

    // 3. Parsing menggunakan BaseApiResponseModel yang sudah Anda buat
    // Karena kita tidak butuh parsing 'data' (T), kita gunakan dynamic
    final baseResponse = BaseApiResponseModel<dynamic>.fromJson(
      response.data,
      (json) => json, 
    );

    // 4. Lemparkan ServerException jika isSuccess == false
    // .errorMessage akan secara cerdas membedah string/list/map dari JSON
    if (!baseResponse.isSuccess) {
      throw ServerException(baseResponse.status, baseResponse.errorMessage);
    }

    return true;
  }
}