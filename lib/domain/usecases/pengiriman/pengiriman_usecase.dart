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

  // ---------------------------------------------------------------------------
  // Aturan isian wajib aksi (kontrak POST ambil/tiba/serah/gagal/kembalikan).
  // Mengembalikan pesan kesalahan pertama, atau null bila lengkap.
  // ---------------------------------------------------------------------------

  String? validasiAmbil({
    required int jumlahResi,
    required Set<FotoSlot> foto,
  }) {
    if (jumlahResi == 0) return 'Scan minimal satu QR berkas.';
    if (!foto.contains(FotoSlot.ambil)) return 'Foto pengambilan wajib.';
    return null;
  }

  String? validasiKembalikan({required int jumlahResi}) =>
      jumlahResi == 0 ? 'Scan minimal satu QR berkas.' : null;

  String? validasiTiba(Set<FotoSlot> foto) =>
      foto.contains(FotoSlot.lokasi) ? null : 'Foto lokasi wajib saat tiba.';

  String? validasiSerah({
    required CaraSerah? cara,
    required String namaPenerima,
    required int? idHubungan,
    required bool adaTtd,
    required bool wajibFotoObjek,
    required Set<FotoSlot> foto,
  }) {
    if (cara == null) return 'Pilih cara serah.';
    if (cara.butuhPenerima) {
      if (namaPenerima.trim().isEmpty) return 'Nama penerima wajib diisi.';
      if (idHubungan == null) return 'Pilih hubungan penerima.';
      if (!foto.contains(FotoSlot.serah)) return 'Foto penyerahan wajib.';
      if (!adaTtd) return 'Penerima belum tanda tangan.';
    } else {
      if (!foto.contains(FotoSlot.tempel)) {
        return 'Foto surat tertempel wajib.';
      }
      if (!foto.contains(FotoSlot.lokasi)) return 'Foto lokasi wajib.';
    }
    if (wajibFotoObjek && !foto.contains(FotoSlot.objek)) {
      return 'Foto objek pajak wajib untuk berkas ini.';
    }
    return null;
  }

  String? validasiGagal({
    required OpsiMasterEntity? alasan,
    required String keterangan,
    required Set<FotoSlot> foto,
  }) {
    if (alasan == null) return 'Pilih alasan gagal antar.';
    if (alasan.wajibKeterangan && keterangan.trim().isEmpty) {
      return 'Keterangan wajib untuk alasan "${alasan.nama}".';
    }
    if (!foto.contains(FotoSlot.gagal)) return 'Foto bukti gagal wajib.';
    return null;
  }
}
