// lib/domain/entities/balai_rw/laporan_payload_entity.dart
import 'package:equatable/equatable.dart';

class JawabanPayloadEntity extends Equatable {
  final int idPertanyaan;
  final String jawaban;

  const JawabanPayloadEntity({
    required this.idPertanyaan,
    required this.jawaban,
  });

  @override
  List<Object?> get props => [idPertanyaan, jawaban];
}

class CheckinPayloadEntity extends Equatable {
  final String tanggalLaporan; 
  final String waktuCheckIn; 
  final String fotoPath;
  final double? latitude;
  final double? longitude;

  const CheckinPayloadEntity({
    required this.tanggalLaporan,
    required this.waktuCheckIn,
    required this.fotoPath,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
    tanggalLaporan,
    waktuCheckIn,
    fotoPath,
    latitude,
    longitude,
  ];
}

class CheckoutPayloadEntity extends Equatable {
  final String tanggalLaporan;
  final String fotoPath;
  final double latitude;
  final double longitude;

  const CheckoutPayloadEntity({
    required this.tanggalLaporan,
    required this.fotoPath,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [tanggalLaporan, fotoPath, latitude, longitude];
}

class LaporanPayloadEntity extends Equatable {
  final String tanggalLaporan;
  final List<JawabanPayloadEntity> jawaban;

  const LaporanPayloadEntity({
    required this.tanggalLaporan,
    required this.jawaban,
  });

  @override
  List<Object?> get props => [tanggalLaporan, jawaban];
}
