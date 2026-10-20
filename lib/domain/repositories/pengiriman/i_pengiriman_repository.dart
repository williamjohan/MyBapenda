import 'package:dartz/dartz.dart';

import '../../../core/errors/failure.dart';
import '../../entities/pengiriman/antrean_entity.dart';
import '../../entities/pengiriman/berkas_entity.dart';
import '../../entities/pengiriman/lacak_entity.dart';
import '../../entities/pengiriman/master_pengiriman_entity.dart';
import '../../entities/pengiriman/pengiriman_payload_entity.dart';

abstract class IPengirimanRepository {
  Future<Either<Failure, MasterPengirimanEntity>> getMaster();

  /// Saat offline memakai data terakhir (`tglCache` terisi). Aksi di
  /// antrean sudah diterapkan ke status & tombol.
  Future<Either<Failure, HasilBacaEntity<List<BerkasEntity>>>> getDaftar();

  Future<Either<Failure, HasilBacaEntity<BerkasDetailEntity>>> getDetail(
    String noResi,
  );

  Future<Either<Failure, LacakResultEntity>> getLacak(String kode);

  /// Jalur jalan (motor) melewati [titik] berurutan, untuk digambar di peta.
  Future<Either<Failure, List<TitikRute>>> getRute(List<TitikRute> titik);

  /// Ambil selalu online: server bisa menolak sebagian berkas.
  Future<Either<Failure, List<HasilCheckinEntity>>> postAmbil(
    AmbilPayloadEntity payload,
  );

  // Aksi lain masuk antrean offline lalu dikirim berurutan.
  Future<Either<Failure, AntreanPengirimanEntity>> antreCheckin(
    CheckinPayloadEntity payload,
  );
  Future<Either<Failure, AntreanPengirimanEntity>> antreSerah(
    SerahPayloadEntity payload,
  );
  Future<Either<Failure, AntreanPengirimanEntity>> antreGagal(
    GagalPayloadEntity payload,
  );
  Future<Either<Failure, AntreanPengirimanEntity>> antreKembalikan(
    KembalikanPayloadEntity payload,
  );

  Future<RingkasanAntreanEntity> bacaAntrean();
  Stream<RingkasanAntreanEntity> get perubahanAntrean;

  /// Kirim antrean (NIP login). Aman dipanggil berkali-kali; proses yang
  /// sedang berjalan tidak digandakan.
  Future<void> sinkronkan();
  Future<void> hapusGagal(String checkinUuid);
}
