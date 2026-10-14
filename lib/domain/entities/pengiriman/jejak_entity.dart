import 'package:equatable/equatable.dart';

import 'berkas_entity.dart';

/// Foto jejak; [key] untuk `GET foto?key=` (berlaku hari itu saja).
class FotoJejakEntity extends Equatable {
  final String key;
  final String? jenisFoto;

  const FotoJejakEntity({required this.key, this.jenisFoto});

  @override
  List<Object?> get props => [key, jenisFoto];
}

/// Satu titik check-in di timeline berkas.
class JejakEntity extends Equatable {
  final StatusBerkas status;
  final String statusNama;
  final String? sumber;
  final String? nip;
  final String? namaPetugas;
  final DateTime? tglCheckin;
  final double? latitude;
  final double? longitude;
  final double? akurasi;

  /// Meter dari titik tujuan.
  final double? jarakKeTujuan;
  final String? keterangan;

  /// Tersimpan sebagai jejak tetapi status berkas tidak berubah.
  final bool diabaikan;
  final bool perluReview;
  final int jumlahFoto;

  /// Hanya terisi dari `lacak` (akses monitoring); `detail` cukup [jumlahFoto].
  final List<FotoJejakEntity> foto;
  final bool flagAkurasi;
  final bool flagWaktu;
  final int? percobaanKe;

  /// Jejak dari antrean offline HP, belum diterima server.
  final bool belumTerkirim;

  const JejakEntity({
    required this.status,
    required this.statusNama,
    this.sumber,
    this.nip,
    this.namaPetugas,
    this.tglCheckin,
    this.latitude,
    this.longitude,
    this.akurasi,
    this.jarakKeTujuan,
    this.keterangan,
    this.diabaikan = false,
    this.perluReview = false,
    this.jumlahFoto = 0,
    this.foto = const [],
    this.flagAkurasi = false,
    this.flagWaktu = false,
    this.percobaanKe,
    this.belumTerkirim = false,
  });

  bool get punyaKoordinat => latitude != null && longitude != null;

  @override
  List<Object?> get props => [
    status,
    statusNama,
    sumber,
    nip,
    namaPetugas,
    tglCheckin,
    latitude,
    longitude,
    akurasi,
    jarakKeTujuan,
    keterangan,
    diabaikan,
    perluReview,
    jumlahFoto,
    foto,
    flagAkurasi,
    flagWaktu,
    percobaanKe,
    belumTerkirim,
  ];
}
