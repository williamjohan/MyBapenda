// lib/domain/entities/balai_rw/laporan_pegawai_entity.dart
import 'package:equatable/equatable.dart';

class LaporanPegawaiEntity extends Equatable {
  final String key;
  final int idLaporan;
  final int idRoster;
  final String tanggalLaporan;
  final String insDate;
  final List<JawabanEntity> jawaban;
  final AbsenEntity? checkin; 
  final AbsenEntity? checkout; 

  const LaporanPegawaiEntity({
    required this.key,
    required this.idLaporan,
    required this.idRoster,
    required this.tanggalLaporan,
    required this.insDate,
    required this.jawaban,
    this.checkin,
    this.checkout,
  });

  @override
  List<Object?> get props => [
    key,
    idLaporan,
    idRoster,
    tanggalLaporan,
    insDate,
    jawaban,
    checkin,
    checkout,
  ];
}

class JawabanEntity extends Equatable {
  final int idPertanyaan;
  final String pertanyaan;
  final String? jawaban;

  const JawabanEntity({
    required this.idPertanyaan,
    required this.pertanyaan,
    this.jawaban,
  });

  @override
  List<Object?> get props => [idPertanyaan, pertanyaan, jawaban];
}

class AbsenEntity extends Equatable {
  final String key;
  final String jam; 
  final String? keterangan;
  final String? fotoUrl;

  const AbsenEntity({
    required this.key,
    required this.jam,
    this.keterangan,
    this.fotoUrl,
  });

  @override
  List<Object?> get props => [key, jam, keterangan, fotoUrl];
}
