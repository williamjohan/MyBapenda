// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'master_pengiriman_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpsiMasterModel _$OpsiMasterModelFromJson(Map<String, dynamic> json) =>
    OpsiMasterModel(
      id: (json['id'] as num).toInt(),
      nama: json['nama'] as String? ?? '-',
      wajibKeterangan: json['wajibKeterangan'] == null
          ? false
          : jsonAsBool(json['wajibKeterangan']),
    );

Map<String, dynamic> _$OpsiMasterModelToJson(OpsiMasterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nama': instance.nama,
      'wajibKeterangan': instance.wajibKeterangan,
    };

MasterPengirimanModel _$MasterPengirimanModelFromJson(
        Map<String, dynamic> json) =>
    MasterPengirimanModel(
      hubunganPenerima: (json['hubunganPenerima'] as List<dynamic>?)
              ?.map((e) => OpsiMasterModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      alasanGagal: (json['alasanGagal'] as List<dynamic>?)
              ?.map((e) => OpsiMasterModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      caraSerah: (json['caraSerah'] as List<dynamic>?)
              ?.map((e) => OpsiMasterModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$MasterPengirimanModelToJson(
        MasterPengirimanModel instance) =>
    <String, dynamic>{
      'hubunganPenerima': instance.hubunganPenerima,
      'alasanGagal': instance.alasanGagal,
      'caraSerah': instance.caraSerah,
    };

HasilCheckinModel _$HasilCheckinModelFromJson(Map<String, dynamic> json) =>
    HasilCheckinModel(
      noResi: json['noResi'] as String? ?? '',
      statusId: (json['statusId'] as num?)?.toInt(),
      status: json['status'] as String?,
      diabaikan:
          json['diabaikan'] == null ? false : jsonAsBool(json['diabaikan']),
      duplikat: json['duplikat'] == null ? false : jsonAsBool(json['duplikat']),
      pesan: json['pesan'] as String?,
    );

Map<String, dynamic> _$HasilCheckinModelToJson(HasilCheckinModel instance) =>
    <String, dynamic>{
      'noResi': instance.noResi,
      'statusId': instance.statusId,
      'status': instance.status,
      'diabaikan': instance.diabaikan,
      'duplikat': instance.duplikat,
      'pesan': instance.pesan,
    };
