// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxTypeModel _$TaxTypeModelFromJson(Map<String, dynamic> json) => TaxTypeModel(
      id: (json['id'] as num).toInt(),
      nama: json['nama'] as String? ?? '',
      labelReferensi: json['labelReferensi'] as String? ?? '',
      hint: json['hint'] as String? ?? '',
      hanyaAngka: json['hanyaAngka'] as bool? ?? false,
      panjangReferensi: (json['panjangReferensi'] as num?)?.toInt(),
      mask: json['mask'] as String?,
    );

Map<String, dynamic> _$TaxTypeModelToJson(TaxTypeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nama': instance.nama,
      'labelReferensi': instance.labelReferensi,
      'hint': instance.hint,
      'panjangReferensi': instance.panjangReferensi,
      'hanyaAngka': instance.hanyaAngka,
      'mask': instance.mask,
    };
