

import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/balai_rw/roster_pegawai_entity.dart';

part 'roster_pegawai_model.g.dart';

@JsonSerializable()
class RosterPegawaiModel {
  @JsonKey(name: 'key')
  final String key;
  @JsonKey(name: 'idRoster')
  final int idRoster;
  @JsonKey(name: 'tanggal')
  final String tanggal;
  @JsonKey(name: 'jamMasuk')
  final String jamMasuk;
  @JsonKey(name: 'jamPulang')
  final String jamPulang;
  @JsonKey(name : 'kdKecamatan')
  final String kodeKecamatan;
  @JsonKey(name : 'kdKelurahan')
  final String kodeKelurahan;
  @JsonKey(name : 'rw')
  final String rw;
  @JsonKey(name : 'isLibur')
  final bool isLibur;

  const RosterPegawaiModel({
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

  factory RosterPegawaiModel.fromJson(Map<String, dynamic> json) =>
      _$RosterPegawaiModelFromJson(json);

  Map<String, dynamic> toJson() => _$RosterPegawaiModelToJson(this);
}


/// Extension untuk mapping Model ke Entity
extension RosterPegawaiModelX on RosterPegawaiModel {
  RosterPegawaiEntity toEntity() => RosterPegawaiEntity(
        key: key,
        idRoster: idRoster,
        tanggal: tanggal,
        jamMasuk: jamMasuk,
        jamPulang: jamPulang,
        kodeKecamatan: kodeKecamatan,
        kodeKelurahan: kodeKelurahan,
        rw: rw,
        isLibur: isLibur,
      );
}