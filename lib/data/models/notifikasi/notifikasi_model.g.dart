// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifikasi_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotifikasiModel _$NotifikasiModelFromJson(Map<String, dynamic> json) =>
    NotifikasiModel(
      id: (json['id'] as num).toInt(),
      kodeJenis: json['kodeJenis'] as String? ?? '',
      namaJenis: json['namaJenis'] as String? ?? '',
      reffNo: jsonAsString(json['reffNo']),
      judul: json['judul'] as String? ?? '',
      isi: json['isi'] as String? ?? '',
      tglNotifikasi: json['tglNotifikasi'] as String?,
      dibaca: jsonAsBool(json['dibaca']),
      tglBaca: json['tglBaca'] as String?,
    );

Map<String, dynamic> _$NotifikasiModelToJson(NotifikasiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kodeJenis': instance.kodeJenis,
      'namaJenis': instance.namaJenis,
      'reffNo': instance.reffNo,
      'judul': instance.judul,
      'isi': instance.isi,
      'tglNotifikasi': instance.tglNotifikasi,
      'dibaca': instance.dibaca,
      'tglBaca': instance.tglBaca,
    };

HalamanNotifikasiModel _$HalamanNotifikasiModelFromJson(
        Map<String, dynamic> json) =>
    HalamanNotifikasiModel(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => NotifikasiModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      page: (json['page'] as num?)?.toInt() ?? 1,
      totalPage: (json['totalPage'] as num?)?.toInt() ?? 1,
      totalData: (json['totalData'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$HalamanNotifikasiModelToJson(
        HalamanNotifikasiModel instance) =>
    <String, dynamic>{
      'items': instance.items,
      'page': instance.page,
      'totalPage': instance.totalPage,
      'totalData': instance.totalData,
    };

NotifEventModel _$NotifEventModelFromJson(Map<String, dynamic> json) =>
    NotifEventModel(
      snapshot: json['snapshot'] == null ? false : jsonAsBool(json['snapshot']),
      jumlahBaru: (json['jumlahBaru'] as num?)?.toInt() ?? 0,
      jumlahBelumDibaca: (json['jumlahBelumDibaca'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => NotifikasiModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$NotifEventModelToJson(NotifEventModel instance) =>
    <String, dynamic>{
      'snapshot': instance.snapshot,
      'jumlahBaru': instance.jumlahBaru,
      'jumlahBelumDibaca': instance.jumlahBelumDibaca,
      'items': instance.items,
    };
