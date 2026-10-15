import 'package:equatable/equatable.dart';

import 'berkas_entity.dart';
import 'master_pengiriman_entity.dart';

/// Field check-in yang ikut di semua POST pengiriman.
/// [checkinUuid] dibuat di HP dan tetap sama saat retry (idempoten di server).
class CheckinPengirimanEntity extends Equatable {
  final String checkinUuid;

  /// Waktu HP saat check-in.
  final DateTime tglCheckin;
  final double latitude;
  final double longitude;
  final double? akurasi;
  final bool isMockLocation;
  final String? keterangan;

  /// File `fotoLokasi` (opsional di semua endpoint, wajib untuk Tiba).
  final String? fotoLokasiPath;

  const CheckinPengirimanEntity({
    required this.checkinUuid,
    required this.tglCheckin,
    required this.latitude,
    required this.longitude,
    this.akurasi,
    required this.isMockLocation,
    this.keterangan,
    this.fotoLokasiPath,
  });

  @override
  List<Object?> get props => [
    checkinUuid,
    tglCheckin,
    latitude,
    longitude,
    akurasi,
    isMockLocation,
    keterangan,
    fotoLokasiPath,
  ];
}

/// `POST ambil`: 1 manifest dari hasil scan QR (maks 100 berkas).
class AmbilPayloadEntity {
  final List<String> noResiList;
  final List<String> nipTim;
  final String fotoAmbilPath;
  final CheckinPengirimanEntity checkin;

  const AmbilPayloadEntity({
    required this.noResiList,
    this.nipTim = const [],
    required this.fotoAmbilPath,
    required this.checkin,
  });
}

enum JenisCheckin { perjalanan, tiba }

/// `POST perjalanan` / `POST tiba`.
class CheckinPayloadEntity {
  final JenisCheckin jenis;
  final String noResi;
  final CheckinPengirimanEntity checkin;

  const CheckinPayloadEntity({
    required this.jenis,
    required this.noResi,
    required this.checkin,
  });
}

/// `POST serah`.
class SerahPayloadEntity {
  final String noResi;
  final CaraSerah caraSerah;
  final String? namaPenerima;
  final int? idHubungan;
  final String? fotoSerahPath;

  /// PNG tanda tangan (wajib untuk Langsung/Dititipkan).
  final String? fotoTtdPath;

  /// Wajib untuk Ditempel (bersama `checkin.fotoLokasiPath`).
  final String? fotoTempelPath;

  /// Wajib bila `wajibFotoObjek`.
  final String? fotoObjekPath;
  final CheckinPengirimanEntity checkin;

  const SerahPayloadEntity({
    required this.noResi,
    required this.caraSerah,
    this.namaPenerima,
    this.idHubungan,
    this.fotoSerahPath,
    this.fotoTtdPath,
    this.fotoTempelPath,
    this.fotoObjekPath,
    required this.checkin,
  });
}

/// `POST gagal`. Keterangan memakai `checkin.keterangan`.
class GagalPayloadEntity {
  final String noResi;
  final int idAlasan;
  final String fotoGagalPath;
  final CheckinPengirimanEntity checkin;

  const GagalPayloadEntity({
    required this.noResi,
    required this.idAlasan,
    required this.fotoGagalPath,
    required this.checkin,
  });
}

/// `POST kembalikan`: hasil scan di kantor.
class KembalikanPayloadEntity {
  final List<String> noResiList;
  final CheckinPengirimanEntity checkin;

  const KembalikanPayloadEntity({
    required this.noResiList,
    required this.checkin,
  });
}

/// Hasil per berkas dari semua POST pengiriman.
class HasilCheckinEntity extends Equatable {
  final String noResi;
  final StatusBerkas? status;
  final String? statusNama;

  /// Jejak tersimpan tetapi status tidak berubah; tampilkan [pesan].
  final bool diabaikan;

  /// UUID sudah pernah diterima (sinkron ulang); anggap sukses.
  final bool duplikat;
  final String? pesan;

  const HasilCheckinEntity({
    required this.noResi,
    this.status,
    this.statusNama,
    this.diabaikan = false,
    this.duplikat = false,
    this.pesan,
  });

  @override
  List<Object?> get props => [
    noResi,
    status,
    statusNama,
    diabaikan,
    duplikat,
    pesan,
  ];
}
