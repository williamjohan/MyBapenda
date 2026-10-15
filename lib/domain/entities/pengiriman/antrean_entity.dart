import 'package:equatable/equatable.dart';

import 'berkas_entity.dart';

/// Aksi yang lewat antrean offline (Ambil selalu online).
enum JenisAksiAntrean {
  perjalanan('perjalanan', 'Dalam Perjalanan', StatusBerkas.dalamPerjalanan),
  tiba('tiba', 'Tiba di Tujuan', StatusBerkas.tiba),
  serah('serah', 'Serah Terima', StatusBerkas.diterima),
  gagal('gagal', 'Gagal Antar', StatusBerkas.gagalAntar),
  kembalikan('kembalikan', 'Kembalikan ke Kantor', StatusBerkas.dikembalikan);

  final String kode;
  final String label;

  /// Status berkas setelah aksi ini diterima server (untuk tampilan
  /// sementara sebelum terkirim).
  final StatusBerkas statusSetelah;

  const JenisAksiAntrean(this.kode, this.label, this.statusSetelah);

  static JenisAksiAntrean fromKode(String kode) =>
      JenisAksiAntrean.values.firstWhere(
        (j) => j.kode == kode,
        orElse: () => JenisAksiAntrean.perjalanan,
      );
}

/// Satu aksi di antrean (menunggu kirim) atau di daftar gagal.
class AntreanPengirimanEntity extends Equatable {
  final String checkinUuid;
  final JenisAksiAntrean jenis;
  final List<String> noResi;
  final DateTime tglDibuat;
  final int jmlCoba;

  /// Galat terakhir (menunggu) atau alasan server (gagal).
  final String? pesan;

  /// Tersimpan sebagai jejak di server tapi status berkas tidak berubah.
  final bool diabaikan;

  const AntreanPengirimanEntity({
    required this.checkinUuid,
    required this.jenis,
    required this.noResi,
    required this.tglDibuat,
    this.jmlCoba = 0,
    this.pesan,
    this.diabaikan = false,
  });

  @override
  List<Object?> get props => [
    checkinUuid,
    jenis,
    noResi,
    tglDibuat,
    jmlCoba,
    pesan,
    diabaikan,
  ];
}

class RingkasanAntreanEntity extends Equatable {
  /// Urut FIFO (pertama dikirim lebih dulu).
  final List<AntreanPengirimanEntity> menunggu;
  final List<AntreanPengirimanEntity> gagal;

  const RingkasanAntreanEntity({
    this.menunggu = const [],
    this.gagal = const [],
  });

  /// Angka di indikator "N belum terkirim".
  int get jumlah => menunggu.length + gagal.length;

  @override
  List<Object?> get props => [menunggu, gagal];
}

/// Data baca + penanda asal: [tglCache] terisi = data offline terakhir.
class HasilBacaEntity<T> extends Equatable {
  final T data;
  final DateTime? tglCache;

  const HasilBacaEntity(this.data, {this.tglCache});

  bool get dariCache => tglCache != null;

  @override
  List<Object?> get props => [data, tglCache];
}
