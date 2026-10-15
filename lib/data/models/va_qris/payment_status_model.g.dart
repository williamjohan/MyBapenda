// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentStatusModel _$PaymentStatusModelFromJson(Map<String, dynamic> json) =>
    PaymentStatusModel(
      isLunas: json['isLunas'] as bool? ?? false,
      tglBayar: json['tglBayar'] as String?,
      coreReference: json['coreReference'] as String?,
      jumlahBayar: json['jumlahBayar'] as num?,
    );

Map<String, dynamic> _$PaymentStatusModelToJson(PaymentStatusModel instance) =>
    <String, dynamic>{
      'isLunas': instance.isLunas,
      'tglBayar': instance.tglBayar,
      'coreReference': instance.coreReference,
      'jumlahBayar': instance.jumlahBayar,
    };
