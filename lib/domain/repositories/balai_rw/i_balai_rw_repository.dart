import 'package:bapendacore/domain/entities/balai_rw/laporan_payload_entity.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../entities/balai_rw/kategori_pertanyaan_entity.dart';
import '../../entities/balai_rw/laporan_pegawai_entity.dart';
import '../../entities/balai_rw/pertanyaan_entity.dart';
import '../../entities/balai_rw/roster_pegawai_entity.dart';

abstract class IBalaiRwRepository {
  Future<Either<Failure, List<KategoriPertanyaanEntity>>> getKategori({
    bool hanyaAktif = true,
  });

  Future<Either<Failure, List<PertanyaanEntity>>> getPertanyaan({
    int? idKategori,
    bool hanyaAktif = true,
  });

  Future<Either<Failure, List<RosterPegawaiEntity>>> getRosterPegawai({
    required String tanggalAwal,
    required String tanggalAkhir,
  });

  Future<Either<Failure, List<LaporanPegawaiEntity>>> getLaporanAbsensi({
    required String tanggalAwal,
    required String tanggalAkhir,
  });

  Future<Either<Failure, bool>> postCheckin(CheckinPayloadEntity payload);
  Future<Either<Failure, bool>> postCheckout(CheckoutPayloadEntity payload);
  Future<Either<Failure, bool>> postLaporanPegawai(
    LaporanPayloadEntity payload,
  );
}
