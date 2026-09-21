// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryModel _$HistoryModelFromJson(Map<String, dynamic> json) => HistoryModel(
      key: json['key'] as String,
      longitude: json['longitude'] as String,
      latitude: json['latitude'] as String,
      alamat: json['alamat'] as String,
      insDate: json['insDate'] as String,
      insBy: json['insBy'] as String,
      ukuran: json['ukuran'] as String?,
      photoUrl: json['foto'] as String?,
    );

Map<String, dynamic> _$HistoryModelToJson(HistoryModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'alamat': instance.alamat,
      'insDate': instance.insDate,
      'insBy': instance.insBy,
      'ukuran': instance.ukuran,
      'foto': instance.photoUrl,
    };
