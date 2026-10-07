import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failure.dart';
import '../../entities/balai_rw/kategori_pertanyaan_entity.dart';
import '../../entities/balai_rw/pertanyaan_entity.dart';
import '../../entities/balai_rw/roster_pegawai_entity.dart';
import '../../repositories/balai_rw/i_balai_rw_repository.dart';

@lazySingleton
class BalaiRwUseCase {
  final IBalaiRwRepository _repository;

  BalaiRwUseCase(this._repository);

  Future<Either<Failure, List<KategoriPertanyaanEntity>>> getKategori({
    bool hanyaAktif = true,
  }) {
    return _repository.getKategori(hanyaAktif: hanyaAktif);
  }

  Future<Either<Failure, List<PertanyaanEntity>>> getPertanyaan({
    int? idKategori,
    bool hanyaAktif = true,
  }) {
    return _repository.getPertanyaan(
      idKategori: idKategori,
      hanyaAktif: hanyaAktif,
    );
  }

  Future<Either<Failure, List<RosterPegawaiEntity>>> getRosterPegawai({
    required String tanggalAwal,
    required String tanggalAkhir,
  }) {
    return _repository.getRosterPegawai(
      tanggalAwal: tanggalAwal,
      tanggalAkhir: tanggalAkhir,
    );
  }
}