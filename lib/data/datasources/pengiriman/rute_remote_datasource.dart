import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/exception.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/env_config/env_config.dart';
import '../../../domain/entities/pengiriman/lacak_entity.dart';
import '../../models/pengiriman/rute_model.dart';

abstract class IRuteRemoteDataSource {
  /// Rute jalan melewati [titik] berurutan (minimal 2 titik).
  Future<RuteModel> hitungRute(List<TitikRute> titik);
}

/// Google Routes API. Memakai Dio sendiri (tanpa interceptor aplikasi)
/// supaya token login tidak ikut terkirim ke Google.
@LazySingleton(as: IRuteRemoteDataSource)
class RuteRemoteDataSourceImpl implements IRuteRemoteDataSource {
  final Dio _dio;
  final String _apiKey;

  RuteRemoteDataSourceImpl()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
        ),
      ),
      _apiKey = EnvConfig.googleMapsApiKey;

  @visibleForTesting
  RuteRemoteDataSourceImpl.uji(this._dio, this._apiKey);

  @override
  Future<RuteModel> hitungRute(List<TitikRute> titik) async {
    final response = await _dio.post(
      ApiEndpoints.googleRoutes,
      data: RuteModel.permintaan(titik),
      options: Options(
        headers: {
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask': 'routes.polyline.encodedPolyline',
        },
      ),
    );
    final model = RuteModel.fromJson(response.data as Map<String, dynamic>);
    if (model.encodedPolyline == null) {
      throw const ServerException(404, 'Rute tidak ditemukan.');
    }
    return model;
  }
}
