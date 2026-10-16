import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failure.dart';
import '../../entities/notifikasi/notifikasi_entity.dart';
import '../../repositories/notifikasi/i_notifikasi_repository.dart';

@lazySingleton
class NotifikasiUseCase {
  final INotifikasiRepository _repository;

  NotifikasiUseCase(this._repository);

  Future<Either<Failure, int>> getJumlahBelumDibaca() =>
      _repository.getJumlahBelumDibaca();

  Future<Either<Failure, HalamanNotifikasiEntity>> getInbox({
    int page = 1,
    int pageSize = 20,
    bool hanyaBelumDibaca = false,
  }) => _repository.getInbox(
    page: page,
    pageSize: pageSize,
    hanyaBelumDibaca: hanyaBelumDibaca,
  );

  Future<Either<Failure, int>> baca(int id) => _repository.baca(id);

  Future<Either<Failure, int>> bacaSemua() => _repository.bacaSemua();

  Stream<void> get perubahan => _repository.perubahan;

  Stream<int> get jumlahBelumDibaca => _repository.jumlahBelumDibaca;

  int? get jumlahTerakhir => _repository.jumlahTerakhir;
}
