// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_nominal_check_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentNominalCheckModel _$PaymentNominalCheckModelFromJson(
        Map<String, dynamic> json) =>
    PaymentNominalCheckModel(
      va: PaymentMethodAllowanceModel.fromJson(
          json['va'] as Map<String, dynamic>),
      qris: PaymentMethodAllowanceModel.fromJson(
          json['qris'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PaymentNominalCheckModelToJson(
        PaymentNominalCheckModel instance) =>
    <String, dynamic>{
      'va': instance.va.toJson(),
      'qris': instance.qris.toJson(),
    };

PaymentMethodAllowanceModel _$PaymentMethodAllowanceModelFromJson(
        Map<String, dynamic> json) =>
    PaymentMethodAllowanceModel(
      isAllow: json['isAllow'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );

Map<String, dynamic> _$PaymentMethodAllowanceModelToJson(
        PaymentMethodAllowanceModel instance) =>
    <String, dynamic>{
      'isAllow': instance.isAllow,
      'message': instance.message,
    };
