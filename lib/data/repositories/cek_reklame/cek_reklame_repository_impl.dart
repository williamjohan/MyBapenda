import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failure.dart';
import '../../../core/network/safe_api_call.dart';
import '../../../domain/repositories/cek_reklame/i_cek_reklame_repository.dart';
import '../../datasources/cek_reklame/cek_reklame_remote_data_source.dart';

@LazySingleton(as: CekReklameRepository)
class CekReklameRepositoryImpl implements CekReklameRepository {
  final CekReklameRemoteDataSource remoteDataSource;

  CekReklameRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, bool>> uploadReklame({
    required File file,
    required String latitude,
    required String longitude,
    required String alamat,
  }) {
    // 🚀 Sangat Clean! 
    // Apapun yang meledak di dalam sini (Timeout, 401, 500, no internet) 
    // akan dibungkus rapi menjadi Either<Failure, bool> oleh executeSafeApiCall.
    return executeSafeApiCall<bool>(() async {
      return await remoteDataSource.uploadReklame(
        file: file,
        latitude: latitude,
        longitude: longitude,
        alamat: alamat,
      );
    });
  }
}