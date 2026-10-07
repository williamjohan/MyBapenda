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

/// Data yang dikirim ke POST laporan (multipart).
class LaporanPayloadEntity extends Equatable {
  final String tanggalLaporan; 
  final List<JawabanPayloadEntity> jawaban;
  final String jamMasuk; 
  final String jamPulang; 
  final String keterangan;
  final List<String> fotoPaths; // path file lokal

  const LaporanPayloadEntity({
    required this.tanggalLaporan,
    required this.jawaban,
    required this.jamMasuk,
    required this.jamPulang,
    required this.keterangan,
    this.fotoPaths = const [],
  });

  @override
  List<Object?> get props => [
    tanggalLaporan,
    jawaban,
    jamMasuk,
    jamPulang,
    keterangan,
    fotoPaths,
  ];
}
