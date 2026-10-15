// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryPhotoModel _$HistoryPhotoModelFromJson(Map<String, dynamic> json) =>
    HistoryPhotoModel(
      imageUrl: json['imageUrl'] as String?,
      namaFile: json['namaFile'] as String?,
      ukuranFile: json['ukuranFile'] as String?,
      tipeFile: json['tipeFile'] as String?,
      contentType: json['contentType'] as String?,
    );

Map<String, dynamic> _$HistoryPhotoModelToJson(HistoryPhotoModel instance) =>
    <String, dynamic>{
      'imageUrl': instance.imageUrl,
      'namaFile': instance.namaFile,
      'ukuranFile': instance.ukuranFile,
      'tipeFile': instance.tipeFile,
      'contentType': instance.contentType,
    };

HistoryModel _$HistoryModelFromJson(Map<String, dynamic> json) => HistoryModel(
      key: json['key'] as String,
      longitude: json['longitude'] as String,
      latitude: json['latitude'] as String,
      alamat: json['alamat'] as String,
      panjang: (json['panjang'] as num?)?.toDouble(),
      lebar: (json['lebar'] as num?)?.toDouble(),
      tinggi: (json['tinggi'] as num?)?.toDouble(),
      insDate: json['insDate'] as String,
      insBy: json['insBy'] as String,
      foto: json['foto'] == null
          ? null
          : HistoryPhotoModel.fromJson(json['foto'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HistoryModelToJson(HistoryModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'alamat': instance.alamat,
      'panjang': instance.panjang,
      'lebar': instance.lebar,
      'tinggi': instance.tinggi,
      'insDate': instance.insDate,
      'insBy': instance.insBy,
      'foto': instance.foto,
    };
