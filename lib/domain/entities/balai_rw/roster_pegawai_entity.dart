import 'package:equatable/equatable.dart';

class RosterPegawaiEntity extends Equatable {
  final String key;
  final int idRoster;
  final String tanggal;
  final String jamMasuk;
  final String jamPulang;
  final String kodeKecamatan;
  final String kodeKelurahan;
  final String rw;
  final bool isLibur;

  const RosterPegawaiEntity({
    required this.key,
    required this.idRoster,
    required this.tanggal,
    required this.jamMasuk,
    required this.jamPulang,
    required this.kodeKecamatan,
    required this.kodeKelurahan,
    required this.rw,
    required this.isLibur,
  });

  @override
  List<Object?> get props => [
        key,
        idRoster,
        tanggal,
        jamMasuk,
        jamPulang,
        kodeKecamatan,
        kodeKelurahan,
        rw,
        isLibur,
      ];
}