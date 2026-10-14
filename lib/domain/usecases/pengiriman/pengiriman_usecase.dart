import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failure.dart';
import '../../entities/pengiriman/antrean_entity.dart';
import '../../entities/pengiriman/berkas_entity.dart';
import '../../entities/pengiriman/lacak_entity.dart';
import '../../entities/pengiriman/master_pengiriman_entity.dart';
import '../../entities/pengiriman/pengiriman_payload_entity.dart';
import '../../repositories/pengiriman/i_pengiriman_repository.dart';

@lazySingleton
class PengirimanUseCase {
  final IPengirimanRepository _repository;

  PengirimanUseCase(this._repository);

  Future<Either<Failure, MasterPengirimanEntity>> getMaster() =>
      _repository.getMaster();

  Future<Either<Failure, HasilBacaEntity<List<BerkasEntity>>>> getDaftar() =>
      _repository.getDaftar();

  Future<Either<Failure, HasilBacaEntity<BerkasDetailEntity>>> getDetail(
    String noResi,
  ) => _repository.getDetail(noResi);

  Future<Either<Failure, LacakResultEntity>> getLacak(String kode) =>
      _repository.getLacak(kode);

  Future<Either<Failure, List<HasilCheckinEntity>>> postAmbil(
    AmbilPayloadEntity payload,
  ) => _repository.postAmbil(payload);

  Future<Either<Failure, AntreanPengirimanEntity>> antreCheckin(
    CheckinPayloadEntity payload,
  ) => _repository.antreCheckin(payload);

  Future<Either<Failure, AntreanPengirimanEntity>> antreSerah(
    SerahPayloadEntity payload,
  ) => _repository.antreSerah(payload);

  Future<Either<Failure, AntreanPengirimanEntity>> antreGagal(
    GagalPayloadEntity payload,
  ) => _repository.antreGagal(payload);

  Future<Either<Failure, AntreanPengirimanEntity>> antreKembalikan(
    KembalikanPayloadEntity payload,
  ) => _repository.antreKembalikan(payload);

  Future<RingkasanAntreanEntity> bacaAntrean() => _repository.bacaAntrean();

  Stream<RingkasanAntreanEntity> get perubahanAntrean =>
      _repository.perubahanAntrean;

  Future<void> sinkronkan() => _repository.sinkronkan();

  Future<void> hapusGagal(String checkinUuid) =>
      _repository.hapusGagal(checkinUuid);
}
