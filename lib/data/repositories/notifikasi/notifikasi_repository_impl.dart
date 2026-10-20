import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failure.dart';
import '../../../core/network/safe_api_call.dart';
import '../../../core/services/notifikasi/notifikasi_sinyal.dart';
import '../../../domain/entities/notifikasi/notifikasi_entity.dart';
import '../../../domain/repositories/notifikasi/i_notifikasi_repository.dart';
import '../../datasources/notifikasi/notifikasi_remote_datasource.dart';
import '../../models/notifikasi/notifikasi_model.dart';

@LazySingleton(as: INotifikasiRepository)
class NotifikasiRepositoryImpl implements INotifikasiRepository {
  final INotifikasiRemoteDataSource _remoteDataSource;
  final NotifikasiSinyal _sinyal;

  NotifikasiRepositoryImpl(this._remoteDataSource, this._sinyal);

  @override
  Future<Either<Failure, int>> getJumlahBelumDibaca() =>
      executeSafeApiCall(() => _remoteDataSource.getJumlahBelumDibaca());

  @override
  Future<Either<Failure, HalamanNotifikasiEntity>> getInbox({
    int page = 1,
    int pageSize = 20,
    bool hanyaBelumDibaca = false,
  }) => executeSafeApiCall(() async {
    final model = await _remoteDataSource.getInbox(
      page: page,
      pageSize: pageSize,
      hanyaBelumDibaca: hanyaBelumDibaca,
    );
    return model.toEntity();
  });

  @override
  Future<Either<Failure, int>> baca(int id) =>
      executeSafeApiCall(() => _remoteDataSource.baca(id));

  @override
  Future<Either<Failure, int>> bacaSemua() =>
      executeSafeApiCall(() => _remoteDataSource.bacaSemua());

  @override
  Stream<void> get perubahan => _sinyal.event;

  @override
  Stream<int> get jumlahBelumDibaca => _sinyal.jumlahBelumDibaca;

  @override
  int? get jumlahTerakhir => _sinyal.jumlahTerakhir;
}
