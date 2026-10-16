import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/exception.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/base_api/base_api_response_model.dart';
import '../../models/notifikasi/notifikasi_model.dart';

abstract class INotifikasiRemoteDataSource {
  Future<int> getJumlahBelumDibaca();

  Future<HalamanNotifikasiModel> getInbox({
    required int page,
    required int pageSize,
    required bool hanyaBelumDibaca,
  });

  Future<int> baca(int id);

  Future<int> bacaSemua();
}

@LazySingleton(as: INotifikasiRemoteDataSource)
class NotifikasiRemoteDataSourceImpl implements INotifikasiRemoteDataSource {
  final Dio _dio;

  NotifikasiRemoteDataSourceImpl(this._dio);

  @override
  Future<int> getJumlahBelumDibaca() async {
    final response = await _dio.get(ApiEndpoints.notifikasiJumlahBelumDibaca);
    return _jumlah(response.data);
  }

  @override
  Future<HalamanNotifikasiModel> getInbox({
    required int page,
    required int pageSize,
    required bool hanyaBelumDibaca,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.notifikasiInbox,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        'hanyaBelumDibaca': hanyaBelumDibaca,
      },
    );
    return _unwrap(
      response.data,
      (json) => HalamanNotifikasiModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<int> baca(int id) async {
    final response = await _dio.patch(
      ApiEndpoints.notifikasiBaca,
      data: {'id': id},
    );
    return _jumlah(response.data);
  }

  @override
  Future<int> bacaSemua() async {
    final response = await _dio.post(ApiEndpoints.notifikasiBacaSemua);
    return _jumlah(response.data);
  }

  /// Respons `{ jumlah }`.
  int _jumlah(dynamic raw) => _unwrap(
    raw,
    (json) => ((json as Map<String, dynamic>)['jumlah'] as num?)?.toInt() ?? 0,
  );

  /// Bongkar envelope; gagal bisnis bisa HTTP 200 + `isSuccess=false`.
  T _unwrap<T>(dynamic raw, T Function(Object? json) fromJsonT) {
    final base = BaseApiResponseModel<T>.fromJson(
      raw as Map<String, dynamic>,
      fromJsonT,
    );
    if (!base.isSuccess || base.data == null) {
      throw ServerException(base.status, base.errorMessage);
    }
    return base.data as T;
  }
}
