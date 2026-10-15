// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absen_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$AbsenRequestModelToJson(AbsenRequestModel instance) =>
    <String, dynamic>{
      'kodeDevice': instance.kodeDevice,
      'namaDevice': instance.namaDevice,
      'merkModel': instance.merkModel,
      'osVersion': instance.osVersion,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'akurasiMeter': instance.akurasiMeter,
      'isMockLocation': instance.isMockLocation,
      'metodeVerifikasi': instance.metodeVerifikasi,
      'appVersion': instance.appVersion,
    };

AbsenResultModel _$AbsenResultModelFromJson(Map<String, dynamic> json) =>
    AbsenResultModel(
      tglPresensi: json['tglPresensi'] as String,
      jenis: json['jenis'] as String? ?? 'SCAN',
      namaLokasi: json['namaLokasi'] as String?,
      jarakMeter: (json['jarakMeter'] as num?)?.toDouble(),
      menitTelat: (json['menitTelat'] as num?)?.toInt() ?? 0,
      menitPsw: (json['menitPsw'] as num?)?.toInt() ?? 0,
      ringkasan: RingkasanAbsensiModel.fromJson(
          json['ringkasan'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AbsenResultModelToJson(AbsenResultModel instance) =>
    <String, dynamic>{
      'tglPresensi': instance.tglPresensi,
      'jenis': instance.jenis,
      'namaLokasi': instance.namaLokasi,
      'jarakMeter': instance.jarakMeter,
      'menitTelat': instance.menitTelat,
      'menitPsw': instance.menitPsw,
      'ringkasan': instance.ringkasan,
    };
