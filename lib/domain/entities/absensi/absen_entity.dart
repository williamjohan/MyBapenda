import 'package:equatable/equatable.dart';

import 'ringkasan_absensi_entity.dart';

/// Data posisi & verifikasi dari layar. Identitas perangkat ditambahkan
/// di repository (data layer), waktu absen selalu dari server.
class AbsenParams extends Equatable {
  final double latitude;
  final double longitude;
  final double akurasiMeter;
  final bool isMockLocation;
  final String metodeVerifikasi;

  const AbsenParams({
    required this.latitude,
    required this.longitude,
    required this.akurasiMeter,
    required this.isMockLocation,
    // Konfirmasi dengan menahan tombol di aplikasi (tanpa PIN/biometrik HP).
    this.metodeVerifikasi = 'HOLD_HP',
  });

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    akurasiMeter,
    isMockLocation,
    metodeVerifikasi,
  ];
}

enum JenisAbsen {
  masuk,
  pulang,

  /// Di luar window masuk/pulang atau hari bebas.
  scan;

  static JenisAbsen fromCode(String? code) {
    switch (code?.toUpperCase()) {
      case 'MASUK':
        return JenisAbsen.masuk;
      case 'PULANG':
        return JenisAbsen.pulang;
      default:
        return JenisAbsen.scan;
    }
  }
}

class AbsenResultEntity extends Equatable {
  /// Pesan sukses dari server (`title`), mis. "Absen masuk tercatat".
  final String message;
  final DateTime tglPresensi;
  final JenisAbsen jenis;
  final String? namaLokasi;
  final double? jarakMeter;
  final int menitTelat;
  final int menitPsw;
  final RingkasanAbsensiEntity ringkasan;

  const AbsenResultEntity({
    required this.message,
    required this.tglPresensi,
    required this.jenis,
    this.namaLokasi,
    this.jarakMeter,
    this.menitTelat = 0,
    this.menitPsw = 0,
    required this.ringkasan,
  });

  @override
  List<Object?> get props => [
    message,
    tglPresensi,
    jenis,
    namaLokasi,
    jarakMeter,
    menitTelat,
    menitPsw,
    ringkasan,
  ];
}
