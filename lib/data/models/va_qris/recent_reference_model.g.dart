// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_reference_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecentReferenceModel _$RecentReferenceModelFromJson(
        Map<String, dynamic> json) =>
    RecentReferenceModel(
      jenisPajak: (json['jenisPajak'] as num).toInt(),
      jenisPajakNama: json['jenisPajakNama'] as String? ?? '',
      noReferensi: json['noReferensi'] as String,
      nama: json['nama'] as String? ?? '',
      disimpan: DateTime.parse(json['disimpan'] as String),
    );

Map<String, dynamic> _$RecentReferenceModelToJson(
        RecentReferenceModel instance) =>
    <String, dynamic>{
      'jenisPajak': instance.jenisPajak,
      'jenisPajakNama': instance.jenisPajakNama,
      'noReferensi': instance.noReferensi,
      'nama': instance.nama,
      'disimpan': instance.disimpan.toIso8601String(),
    };
