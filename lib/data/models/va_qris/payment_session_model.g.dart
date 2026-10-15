// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreatePaymentRequestModelToJson(
        CreatePaymentRequestModel instance) =>
    <String, dynamic>{
      'jenisPajak': instance.jenisPajak,
      'noReferensi': instance.noReferensi,
      'tipePembayaran': instance.tipePembayaran,
      'keyTagihan': instance.keyTagihan,
    };

PaymentSessionModel _$PaymentSessionModelFromJson(Map<String, dynamic> json) =>
    PaymentSessionModel(
      tipePembayaran: json['tipePembayaran'] as String? ?? '',
      noReferensi: json['noReferensi'] as String? ?? '',
      kodeBayar: json['kodeBayar'] as String? ?? '',
      nominalTotal: json['nominalTotal'] as num? ?? 0,
      expiredDate: json['expiredDate'] as String? ?? '',
      sisaDetik: (json['sisaDetik'] as num?)?.toInt() ?? 0,
      kodeVa: json['kodeVa'] as String?,
      qrValue: json['qrValue'] as String?,
    );

Map<String, dynamic> _$PaymentSessionModelToJson(
        PaymentSessionModel instance) =>
    <String, dynamic>{
      'tipePembayaran': instance.tipePembayaran,
      'noReferensi': instance.noReferensi,
      'kodeBayar': instance.kodeBayar,
      'nominalTotal': instance.nominalTotal,
      'expiredDate': instance.expiredDate,
      'sisaDetik': instance.sisaDetik,
      'kodeVa': instance.kodeVa,
      'qrValue': instance.qrValue,
    };
