import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/va_qris/payment_status_entity.dart';

part 'payment_status_model.g.dart';

/// Response `/api/pembayaran/status`.
@JsonSerializable()
class PaymentStatusModel {
  @JsonKey(name: 'isLunas', defaultValue: false)
  final bool isLunas;

  @JsonKey(name: 'tglBayar')
  final String? tglBayar;

  @JsonKey(name: 'coreReference')
  final String? coreReference;

  @JsonKey(name: 'jumlahBayar')
  final num? jumlahBayar;

  const PaymentStatusModel({
    required this.isLunas,
    this.tglBayar,
    this.coreReference,
    this.jumlahBayar,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentStatusModelToJson(this);
}

extension PaymentStatusModelX on PaymentStatusModel {
  PaymentStatusEntity toEntity() => PaymentStatusEntity(
    isPaid: isLunas,
    paidAt: tglBayar == null ? null : DateTime.tryParse(tglBayar!),
    coreReference: coreReference,
    amount: jumlahBayar?.round(),
  );
}
