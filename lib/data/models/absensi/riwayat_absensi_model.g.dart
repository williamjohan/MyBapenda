// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'riwayat_absensi_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RiwayatAbsensiModel _$RiwayatAbsensiModelFromJson(Map<String, dynamic> json) =>
    RiwayatAbsensiModel(
      tglPresensi: json['tglPresensi'] as String,
      jenisDevice: (json['jenisDevice'] as num?)?.toInt() ?? 1,
      namaDevice: json['namaDevice'] as String?,
      sumber: json['sumber'] as String? ?? 'ONLINE',
      isValid: json['isValid'] as bool? ?? true,
      keterangan: json['keterangan'] as String?,
      namaLokasi: json['namaLokasi'] as String?,
    );

Map<String, dynamic> _$RiwayatAbsensiModelToJson(
        RiwayatAbsensiModel instance) =>
    <String, dynamic>{
      'tglPresensi': instance.tglPresensi,
      'jenisDevice': instance.jenisDevice,
      'namaDevice': instance.namaDevice,
      'sumber': instance.sumber,
      'isValid': instance.isValid,
      'keterangan': instance.keterangan,
      'namaLokasi': instance.namaLokasi,
    };

RiwayatAbsensiPageModel _$RiwayatAbsensiPageModelFromJson(
        Map<String, dynamic> json) =>
    RiwayatAbsensiPageModel(
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) =>
                  RiwayatAbsensiModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$RiwayatAbsensiPageModelToJson(
        RiwayatAbsensiPageModel instance) =>
    <String, dynamic>{
      'page': instance.page,
      'pageSize': instance.pageSize,
      'total': instance.total,
      'items': instance.items,
    };
