import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/va_qris/tax_billing_entity.dart';
import '../../../domain/entities/va_qris/tax_period_entity.dart';

part 'tax_billing_model.g.dart';

/// Response `/api/pembayaran/tagihan`.
@JsonSerializable(explicitToJson: true)
class TaxBillingModel {
  @JsonKey(name: 'jenisPajak', defaultValue: 0)
  final int jenisPajak;

  @JsonKey(name: 'jenisPajakNama', defaultValue: '')
  final String jenisPajakNama;

  @JsonKey(name: 'labelReferensi', defaultValue: '')
  final String labelReferensi;

  @JsonKey(name: 'noReferensi', defaultValue: '')
  final String noReferensi;

  @JsonKey(name: 'nomorPelayanan')
  final String? nomorPelayanan;

  @JsonKey(name: 'npwpd', defaultValue: '')
  final String npwpd;

  @JsonKey(name: 'namaWp', defaultValue: '')
  final String namaWp;

  @JsonKey(name: 'alamatWp', defaultValue: '')
  final String alamatWp;

  @JsonKey(name: 'namaObjek', defaultValue: '')
  final String namaObjek;

  @JsonKey(name: 'alamatObjek', defaultValue: '')
  final String alamatObjek;

  @JsonKey(name: 'belumLunas', defaultValue: [])
  final List<TaxPeriodModel> belumLunas;

  @JsonKey(name: 'sudahLunas', defaultValue: [])
  final List<TaxPeriodModel> sudahLunas;

  const TaxBillingModel({
    required this.jenisPajak,
    required this.jenisPajakNama,
    required this.labelReferensi,
    required this.noReferensi,
    required this.npwpd,
    required this.namaWp,
    required this.alamatWp,
    required this.namaObjek,
    required this.alamatObjek,
    required this.belumLunas,
    required this.sudahLunas,
    this.nomorPelayanan,
  });

  factory TaxBillingModel.fromJson(Map<String, dynamic> json) =>
      _$TaxBillingModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaxBillingModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TaxPeriodModel {
  @JsonKey(name: 'keyTagihan')
  final String? keyTagihan;

  @JsonKey(name: 'tahunPajak', defaultValue: 0)
  final int tahunPajak;

  @JsonKey(name: 'masaPajak', defaultValue: 0)
  final int masaPajak;

  @JsonKey(name: 'masaPajakNama', defaultValue: '')
  final String masaPajakNama;

  @JsonKey(name: 'jatuhTempo', defaultValue: '')
  final String jatuhTempo;

  @JsonKey(name: 'bulanTerlambat', defaultValue: 0)
  final int bulanTerlambat;

  @JsonKey(name: 'pokok', defaultValue: 0)
  final num pokok;

  @JsonKey(name: 'sanksi', defaultValue: 0)
  final num sanksi;

  @JsonKey(name: 'lainnya', defaultValue: 0)
  final num lainnya;

  @JsonKey(name: 'lainnyaLabel')
  final String? lainnyaLabel;

  @JsonKey(name: 'pengurang', defaultValue: 0)
  final num pengurang;

  @JsonKey(name: 'total', defaultValue: 0)
  final num total;

  @JsonKey(name: 'isLunas', defaultValue: false)
  final bool isLunas;

  @JsonKey(name: 'pembayaran', defaultValue: [])
  final List<PaymentHistoryModel> pembayaran;

  const TaxPeriodModel({
    required this.tahunPajak,
    required this.masaPajak,
    required this.masaPajakNama,
    required this.jatuhTempo,
    required this.bulanTerlambat,
    required this.pokok,
    required this.sanksi,
    required this.lainnya,
    required this.pengurang,
    required this.total,
    required this.isLunas,
    required this.pembayaran,
    this.keyTagihan,
    this.lainnyaLabel,
  });

  factory TaxPeriodModel.fromJson(Map<String, dynamic> json) =>
      _$TaxPeriodModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaxPeriodModelToJson(this);
}

@JsonSerializable()
class PaymentHistoryModel {
  @JsonKey(name: 'tglBayar', defaultValue: '')
  final String tglBayar;

  @JsonKey(name: 'noNtpd')
  final String? noNtpd;

  @JsonKey(name: 'metodeBayar', defaultValue: '')
  final String metodeBayar;

  @JsonKey(name: 'jumlahBayar', defaultValue: 0)
  final num jumlahBayar;

  const PaymentHistoryModel({
    required this.tglBayar,
    required this.metodeBayar,
    required this.jumlahBayar,
    this.noNtpd,
  });

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentHistoryModelToJson(this);
}

extension TaxBillingModelX on TaxBillingModel {
  TaxBillingEntity toEntity() => TaxBillingEntity(
    taxTypeId: jenisPajak,
    taxType: jenisPajakNama,
    referenceLabel: labelReferensi,
    referenceNumber: noReferensi,
    serviceNumber: nomorPelayanan,
    npwpd: npwpd,
    taxpayerName: namaWp,
    taxpayerAddress: alamatWp,
    objectName: namaObjek,
    address: alamatObjek,
    unpaidPeriods: belumLunas.map((e) => e.toEntity()).toList(),
    paidPeriods: sudahLunas.map((e) => e.toEntity()).toList(),
  );
}

extension TaxPeriodModelX on TaxPeriodModel {
  TaxPeriodEntity toEntity() => TaxPeriodEntity(
    key: keyTagihan,
    year: tahunPajak,
    month: masaPajak,
    label: masaPajakNama,
    dueDate: DateTime.tryParse(jatuhTempo),
    lateMonths: bulanTerlambat,
    principal: pokok.round(),
    penalty: sanksi.round(),
    other: lainnya.round(),
    otherLabel: lainnyaLabel,
    discount: pengurang.round(),
    total: total.round(),
    isPaid: isLunas,
    paidAt: pembayaran.isEmpty
        ? null
        : DateTime.tryParse(pembayaran.first.tglBayar),
  );
}
