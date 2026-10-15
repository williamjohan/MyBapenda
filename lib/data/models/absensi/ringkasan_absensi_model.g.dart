// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ringkasan_absensi_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RingkasanAbsensiModel _$RingkasanAbsensiModelFromJson(
        Map<String, dynamic> json) =>
    RingkasanAbsensiModel(
      nip: json['nip'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      tanggal: json['tanggal'] as String,
      masuk: json['masuk'] as String?,
      pulang: json['pulang'] as String?,
      jamMasukJadwal: json['jamMasukJadwal'] as String?,
      jamPulangJadwal: json['jamPulangJadwal'] as String?,
      menitTelat: (json['menitTelat'] as num?)?.toInt() ?? 0,
      menitPsw: (json['menitPsw'] as num?)?.toInt() ?? 0,
      keterangan: json['keterangan'] as String?,
    );

Map<String, dynamic> _$RingkasanAbsensiModelToJson(
        RingkasanAbsensiModel instance) =>
    <String, dynamic>{
      'nip': instance.nip,
      'nama': instance.nama,
      'tanggal': instance.tanggal,
      'masuk': instance.masuk,
      'pulang': instance.pulang,
      'jamMasukJadwal': instance.jamMasukJadwal,
      'jamPulangJadwal': instance.jamPulangJadwal,
      'menitTelat': instance.menitTelat,
      'menitPsw': instance.menitPsw,
      'keterangan': instance.keterangan,
    };
