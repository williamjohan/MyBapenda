// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roster_pegawai_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RosterPegawaiModel _$RosterPegawaiModelFromJson(Map<String, dynamic> json) =>
    RosterPegawaiModel(
      key: json['key'] as String,
      idRoster: (json['idRoster'] as num).toInt(),
      tanggal: json['tanggal'] as String,
      jamMasuk: json['jamMasuk'] as String,
      jamPulang: json['jamPulang'] as String,
      kodeKecamatan: json['kdKecamatan'] as String,
      kodeKelurahan: json['kdKelurahan'] as String,
      rw: json['rw'] as String,
      isLibur: json['isLibur'] as bool,
    );

Map<String, dynamic> _$RosterPegawaiModelToJson(RosterPegawaiModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'idRoster': instance.idRoster,
      'tanggal': instance.tanggal,
      'jamMasuk': instance.jamMasuk,
      'jamPulang': instance.jamPulang,
      'kdKecamatan': instance.kodeKecamatan,
      'kdKelurahan': instance.kodeKelurahan,
      'rw': instance.rw,
      'isLibur': instance.isLibur,
    };
