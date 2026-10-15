import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/va_qris/payment_method.dart';
import '../../../domain/entities/va_qris/payment_session_entity.dart';
import '../../../domain/entities/va_qris/tax_period_entity.dart';

part 'payment_session_model.g.dart';

/// Body `POST /api/pembayaran/bayar`.
@JsonSerializable(createFactory: false)
class CreatePaymentRequestModel {
  @JsonKey(name: 'jenisPajak')
  final int jenisPajak;

  @JsonKey(name: 'noReferensi')
  final String noReferensi;

  @JsonKey(name: 'tipePembayaran')
  final String tipePembayaran;

  @JsonKey(name: 'keyTagihan')
  final List<String> keyTagihan;

  const CreatePaymentRequestModel({
    required this.jenisPajak,
    required this.noReferensi,
    required this.tipePembayaran,
    required this.keyTagihan,
  });

  Map<String, dynamic> toJson() => _$CreatePaymentRequestModelToJson(this);
}

/// Response `POST /api/pembayaran/bayar`.
@JsonSerializable()
class PaymentSessionModel {
  @JsonKey(name: 'tipePembayaran', defaultValue: '')
  final String tipePembayaran;

  @JsonKey(name: 'noReferensi', defaultValue: '')
  final String noReferensi;

  @JsonKey(name: 'kodeBayar', defaultValue: '')
  final String kodeBayar;

  @JsonKey(name: 'nominalTotal', defaultValue: 0)
  final num nominalTotal;

  @JsonKey(name: 'expiredDate', defaultValue: '')
  final String expiredDate;

  @JsonKey(name: 'sisaDetik', defaultValue: 0)
  final int sisaDetik;

  @JsonKey(name: 'kodeVa')
  final String? kodeVa;

  @JsonKey(name: 'qrValue')
  final String? qrValue;

  const PaymentSessionModel({
    required this.tipePembayaran,
    required this.noReferensi,
    required this.kodeBayar,
    required this.nominalTotal,
    required this.expiredDate,
    required this.sisaDetik,
    this.kodeVa,
    this.qrValue,
  });

  factory PaymentSessionModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentSessionModelToJson(this);
}

extension PaymentSessionModelX on PaymentSessionModel {
  /// Response API hanya membawa kode bayar; konteks tagihan dari pemanggil.
  PaymentSessionEntity toEntity({
    required PaymentMethod method,
    required int taxTypeId,
    required String referenceLabel,
    required String taxpayerName,
    required List<TaxPeriodEntity> periods,
  }) => PaymentSessionEntity(
    reference: kodeBayar,
    method: method,
    taxTypeId: taxTypeId,
    referenceLabel: referenceLabel,
    referenceNumber: noReferensi,
    taxpayerName: taxpayerName,
    periods: periods,
    createdAt: DateTime.now(),
    validFor: Duration(seconds: sisaDetik),
    total: nominalTotal.round(),
    vaNumber: kodeVa,
    qrisPayload: qrValue,
  );
}
