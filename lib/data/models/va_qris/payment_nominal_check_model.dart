import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/va_qris/payment_nominal_check_entity.dart';

part 'payment_nominal_check_model.g.dart';

/// Response `POST /api/pembayaran/check-nominal`.
@JsonSerializable(explicitToJson: true)
class PaymentNominalCheckModel {
  @JsonKey(name: 'va')
  final PaymentMethodAllowanceModel va;

  @JsonKey(name: 'qris')
  final PaymentMethodAllowanceModel qris;

  const PaymentNominalCheckModel({required this.va, required this.qris});

  factory PaymentNominalCheckModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentNominalCheckModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentNominalCheckModelToJson(this);
}

@JsonSerializable()
class PaymentMethodAllowanceModel {
  @JsonKey(name: 'isAllow', defaultValue: false)
  final bool isAllow;

  @JsonKey(name: 'message', defaultValue: '')
  final String message;

  const PaymentMethodAllowanceModel({
    required this.isAllow,
    required this.message,
  });

  factory PaymentMethodAllowanceModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodAllowanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodAllowanceModelToJson(this);
}

extension PaymentNominalCheckModelX on PaymentNominalCheckModel {
  PaymentNominalCheckEntity toEntity() => PaymentNominalCheckEntity(
    vaAllowed: va.isAllow,
    vaMessage: va.message,
    qrisAllowed: qris.isAllow,
    qrisMessage: qris.message,
  );
}
