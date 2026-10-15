import 'package:equatable/equatable.dart';

import 'jejak_entity.dart';

/// Status berkas sesuai `statusId` dari server.
enum StatusBerkas {
  disiapkan(1, 'Disiapkan'),
  ditugaskan(2, 'Ditugaskan'),
  diambil(3, 'Diambil'),
  dalamPerjalanan(4, 'Dalam Perjalanan'),
  tiba(5, 'Tiba di Tujuan'),
  diterima(6, 'Diterima'),
  gagalAntar(7, 'Gagal Antar'),
  dikembalikan(8, 'Dikembalikan'),
  dikirimViaPos(9, 'Dikirim via Pos'),
  dibatalkan(10, 'Dibatalkan'),
  tidakTerkirim(11, 'Tidak Terkirim');

  final int id;
  final String label;
  const StatusBerkas(this.id, this.label);

  static StatusBerkas fromId(int? id) => StatusBerkas.values.firstWhere(
    (s) => s.id == id,
    orElse: () => StatusBerkas.ditugaskan,
  );

  /// Tidak ada lagi aksi pengantaran, SLA tidak dihitung.
  bool get isFinal => switch (this) {
    StatusBerkas.diterima ||
    StatusBerkas.dikembalikan ||
    StatusBerkas.dikirimViaPos ||
    StatusBerkas.dibatalkan ||
    StatusBerkas.tidakTerkirim => true,
    _ => false,
  };
}

/// Jenis surat dari `jenisKode`.
enum JenisSurat {
  himbauan('HMB', 'Himbauan'),
  teguran('TGR', 'Teguran'),
  skBongkar('SKB', 'SK Reklame Bongkar'),
  lainnya('', 'Surat');

  final String kode;
  final String label;
  const JenisSurat(this.kode, this.label);

  static JenisSurat fromKode(String? kode) {
    final k = kode?.trim().toUpperCase();
    return JenisSurat.values.firstWhere(
      (j) => j.kode.isNotEmpty && j.kode == k,
      orElse: () => JenisSurat.lainnya,
    );
  }
}

/// Kode tombol yang boleh tampil (`aksi[]` dari server).
enum AksiBerkas {
  ambil('AMBIL'),
  perjalanan('PERJALANAN'),
  tiba('TIBA'),
  serah('SERAH'),
  gagal('GAGAL'),
  kembalikan('KEMBALIKAN');

  final String kode;
  const AksiBerkas(this.kode);

  static AksiBerkas? fromKode(String kode) {
    final k = kode.trim().toUpperCase();
    for (final a in AksiBerkas.values) {
      if (a.kode == k) return a;
    }
    return null;
  }
}

/// Satu berkas tugas petugas (`BerkasItem` di `GET daftar`).
class BerkasEntity extends Equatable {
  final String noResi;
  final JenisSurat jenis;
  final String jenisNama;
  final String? noSurat;
  final DateTime? tglSurat;

  /// No SKPD.
  final String? noReferensi;
  final String? npwpd;
  final String namaWp;
  final StatusBerkas status;

  /// Nama status dari server; dipakai untuk tampilan.
  final String statusNama;
  final bool modeTempel;
  final int percobaanKe;
  final int jumlahGagal;
  final String? jenisTujuan;
  final String alamatTujuan;
  final double? latTujuan;
  final double? longTujuan;

  /// true = login penanggung jawab; false = hanya anggota tim.
  final bool penanggungJawab;
  final DateTime? tglDitugaskan;
  final DateTime? tglBatasSla;
  final bool terlambat;
  final bool perluDikembalikan;
  final bool wajibFotoObjek;
  final List<AksiBerkas> aksi;

  /// Jumlah aksi di antrean offline yang belum terkirim untuk berkas ini.
  final int antreanTertunda;

  const BerkasEntity({
    required this.noResi,
    required this.jenis,
    required this.jenisNama,
    this.noSurat,
    this.tglSurat,
    this.noReferensi,
    this.npwpd,
    required this.namaWp,
    required this.status,
    required this.statusNama,
    this.modeTempel = false,
    this.percobaanKe = 0,
    this.jumlahGagal = 0,
    this.jenisTujuan,
    required this.alamatTujuan,
    this.latTujuan,
    this.longTujuan,
    this.penanggungJawab = false,
    this.tglDitugaskan,
    this.tglBatasSla,
    this.terlambat = false,
    this.perluDikembalikan = false,
    this.wajibFotoObjek = false,
    this.aksi = const [],
    this.antreanTertunda = 0,
  });

  bool get punyaKoordinat => latTujuan != null && longTujuan != null;

  bool boleh(AksiBerkas a) => aksi.contains(a);

  /// Untuk tampilan sementara aksi yang masih di antrean.
  BerkasEntity copyWith({
    StatusBerkas? status,
    String? statusNama,
    bool? perluDikembalikan,
    List<AksiBerkas>? aksi,
    int? antreanTertunda,
  }) => BerkasEntity(
    noResi: noResi,
    jenis: jenis,
    jenisNama: jenisNama,
    noSurat: noSurat,
    tglSurat: tglSurat,
    noReferensi: noReferensi,
    npwpd: npwpd,
    namaWp: namaWp,
    status: status ?? this.status,
    statusNama: statusNama ?? this.statusNama,
    modeTempel: modeTempel,
    percobaanKe: percobaanKe,
    jumlahGagal: jumlahGagal,
    jenisTujuan: jenisTujuan,
    alamatTujuan: alamatTujuan,
    latTujuan: latTujuan,
    longTujuan: longTujuan,
    penanggungJawab: penanggungJawab,
    tglDitugaskan: tglDitugaskan,
    tglBatasSla: tglBatasSla,
    terlambat: terlambat,
    perluDikembalikan: perluDikembalikan ?? this.perluDikembalikan,
    wajibFotoObjek: wajibFotoObjek,
    aksi: aksi ?? this.aksi,
    antreanTertunda: antreanTertunda ?? this.antreanTertunda,
  );

  @override
  List<Object?> get props => [
    noResi,
    jenis,
    jenisNama,
    noSurat,
    tglSurat,
    noReferensi,
    npwpd,
    namaWp,
    status,
    statusNama,
    modeTempel,
    percobaanKe,
    jumlahGagal,
    jenisTujuan,
    alamatTujuan,
    latTujuan,
    longTujuan,
    penanggungJawab,
    tglDitugaskan,
    tglBatasSla,
    terlambat,
    perluDikembalikan,
    wajibFotoObjek,
    aksi,
    antreanTertunda,
  ];
}

/// `GET detail?noResi=`: BerkasItem + data serah terima + jejak.
class BerkasDetailEntity extends Equatable {
  final BerkasEntity berkas;
  final String? alamatWp;
  final String? caraSerah;
  final DateTime? tglTerima;
  final String? namaPenerima;

  /// Terbaru di atas.
  final List<JejakEntity> jejak;

  const BerkasDetailEntity({
    required this.berkas,
    this.alamatWp,
    this.caraSerah,
    this.tglTerima,
    this.namaPenerima,
    this.jejak = const [],
  });

  BerkasDetailEntity copyWith({
    BerkasEntity? berkas,
    List<JejakEntity>? jejak,
  }) => BerkasDetailEntity(
    berkas: berkas ?? this.berkas,
    alamatWp: alamatWp,
    caraSerah: caraSerah,
    tglTerima: tglTerima,
    namaPenerima: namaPenerima,
    jejak: jejak ?? this.jejak,
  );

  @override
  List<Object?> get props => [
    berkas,
    alamatWp,
    caraSerah,
    tglTerima,
    namaPenerima,
    jejak,
  ];
}
