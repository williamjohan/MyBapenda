import 'package:equatable/equatable.dart';

class LaporanPegawaiEntity extends Equatable {
  final String key;
  final int idLaporan;
  final int idRoster;
  final String tanggalLaporan;
  final String insDate;
  final List<JawabanEntity> jawaban;
  final List<KehadiranEntity> kehadiran;

  const LaporanPegawaiEntity({
    required this.key,
    required this.idLaporan,
    required this.idRoster,
    required this.tanggalLaporan,
    required this.insDate,
    required this.jawaban,
    required this.kehadiran,
  });

  @override
  List<Object?> get props => [
        key,
        idLaporan,
        idRoster,
        tanggalLaporan,
        insDate,
        jawaban,
        kehadiran,
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

class KehadiranEntity extends Equatable {
  final String key;
  final String jamMasuk;
  final String? jamPulang;
  final String keterangan;
  final String? fotoUrl;

  const KehadiranEntity({
    required this.key,
    required this.jamMasuk,
    this.jamPulang,
    required this.keterangan,
    this.fotoUrl,
  });

  @override
  List<Object?> get props => [key, jamMasuk, jamPulang, keterangan, fotoUrl];
}