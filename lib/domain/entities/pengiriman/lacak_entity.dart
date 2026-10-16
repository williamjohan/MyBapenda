import 'package:equatable/equatable.dart';

import 'berkas_entity.dart';
import 'jejak_entity.dart';

/// Bagian `monitoring` dari `GET lacak` (hanya bila login punya akses).
/// Ditampilkan saja; keputusan supervisor tetap di Web.
class MonitoringBerkasEntity extends Equatable {
  final String noResi;
  final JenisSurat jenis;
  final String jenisNama;
  final String? noSurat;
  final DateTime? tglSurat;
  final String? noReferensi;
  final String? npwpd;
  final String namaWp;
  final String? alamatWp;
  final String? uptb;
  final StatusBerkas status;
  final String statusNama;
  final String? nipPetugas;
  final String? namaPetugas;
  final int jumlahGagal;
  final int? maksPercobaan;
  final bool modeTempel;
  final DateTime? tglDitugaskan;
  final DateTime? tglBatasSla;
  final DateTime? tglJatuhTempo;
  final DateTime? tglTerima;
  final String? caraSerah;
  final bool terlambat;
  final bool perluReview;
  final bool fisikBelumKembali;
  final String? tindakan;
  final String? noResiPos;
  final DateTime? tglKirimPos;
  final DateTime? tglUpdate;

  /// Terbaru di atas.
  final List<JejakEntity> jejak;

  const MonitoringBerkasEntity({
    required this.noResi,
    required this.jenis,
    required this.jenisNama,
    this.noSurat,
    this.tglSurat,
    this.noReferensi,
    this.npwpd,
    required this.namaWp,
    this.alamatWp,
    this.uptb,
    required this.status,
    required this.statusNama,
    this.nipPetugas,
    this.namaPetugas,
    this.jumlahGagal = 0,
    this.maksPercobaan,
    this.modeTempel = false,
    this.tglDitugaskan,
    this.tglBatasSla,
    this.tglJatuhTempo,
    this.tglTerima,
    this.caraSerah,
    this.terlambat = false,
    this.perluReview = false,
    this.fisikBelumKembali = false,
    this.tindakan,
    this.noResiPos,
    this.tglKirimPos,
    this.tglUpdate,
    this.jejak = const [],
  });

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
    alamatWp,
    uptb,
    status,
    statusNama,
    nipPetugas,
    namaPetugas,
    jumlahGagal,
    maksPercobaan,
    modeTempel,
    tglDitugaskan,
    tglBatasSla,
    tglJatuhTempo,
    tglTerima,
    caraSerah,
    terlambat,
    perluReview,
    fisikBelumKembali,
    tindakan,
    noResiPos,
    tglKirimPos,
    tglUpdate,
    jejak,
  ];
}

/// Hasil `GET lacak?kode=`: minimal salah satu [monitoring] / [tugas] terisi.
class LacakResultEntity extends Equatable {
  final String noResi;
  final bool aksesMonitoring;
  final bool tugasSaya;
  final MonitoringBerkasEntity? monitoring;
  final BerkasDetailEntity? tugas;

  const LacakResultEntity({
    required this.noResi,
    this.aksesMonitoring = false,
    this.tugasSaya = false,
    this.monitoring,
    this.tugas,
  });

  /// Titik perjalanan berkas urut waktu: check-in berkoordinat (lama → baru),
  /// diakhiri alamat tujuan bila koordinatnya ada. Dasar rute di peta.
  List<TitikRute> get titikRute {
    final jejak = monitoring?.jejak ?? tugas?.jejak ?? const [];
    final b = tugas?.berkas;
    return [
      for (final j in jejak.reversed)
        if (j.punyaKoordinat) TitikRute(j.latitude!, j.longitude!),
      if (b != null && b.punyaKoordinat) TitikRute(b.latTujuan!, b.longTujuan!),
    ];
  }

  @override
  List<Object?> get props => [
    noResi,
    aksesMonitoring,
    tugasSaya,
    monitoring,
    tugas,
  ];
}

/// Satu titik koordinat pada rute.
class TitikRute extends Equatable {
  final double lat;
  final double lng;

  const TitikRute(this.lat, this.lng);

  @override
  List<Object?> get props => [lat, lng];
}
