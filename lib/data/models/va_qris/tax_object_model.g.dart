// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_object_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxObjectModel _$TaxObjectModelFromJson(Map<String, dynamic> json) =>
    TaxObjectModel(
      jenisPajak: (json['jenisPajak'] as num?)?.toInt() ?? 0,
      jenisPajakNama: json['jenisPajakNama'] as String? ?? '',
      nop: json['nop'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
    );

Map<String, dynamic> _$TaxObjectModelToJson(TaxObjectModel instance) =>
    <String, dynamic>{
      'jenisPajak': instance.jenisPajak,
      'jenisPajakNama': instance.jenisPajakNama,
      'nop': instance.nop,
      'nama': instance.nama,
      'alamat': instance.alamat,
    };

TaxTypeCountModel _$TaxTypeCountModelFromJson(Map<String, dynamic> json) =>
    TaxTypeCountModel(
      jenisPajak: (json['jenisPajak'] as num?)?.toInt() ?? 0,
      jenisPajakNama: json['jenisPajakNama'] as String? ?? '',
      jumlah: (json['jumlah'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TaxTypeCountModelToJson(TaxTypeCountModel instance) =>
    <String, dynamic>{
      'jenisPajak': instance.jenisPajak,
      'jenisPajakNama': instance.jenisPajakNama,
      'jumlah': instance.jumlah,
    };
