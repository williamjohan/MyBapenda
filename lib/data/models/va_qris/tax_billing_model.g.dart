// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_billing_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxBillingModel _$TaxBillingModelFromJson(Map<String, dynamic> json) =>
    TaxBillingModel(
      jenisPajak: (json['jenisPajak'] as num?)?.toInt() ?? 0,
      jenisPajakNama: json['jenisPajakNama'] as String? ?? '',
      labelReferensi: json['labelReferensi'] as String? ?? '',
      noReferensi: json['noReferensi'] as String? ?? '',
      npwpd: json['npwpd'] as String? ?? '',
      namaWp: json['namaWp'] as String? ?? '',
      alamatWp: json['alamatWp'] as String? ?? '',
      namaObjek: json['namaObjek'] as String? ?? '',
      alamatObjek: json['alamatObjek'] as String? ?? '',
      belumLunas: (json['belumLunas'] as List<dynamic>?)
              ?.map((e) => TaxPeriodModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      sudahLunas: (json['sudahLunas'] as List<dynamic>?)
              ?.map((e) => TaxPeriodModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nomorPelayanan: json['nomorPelayanan'] as String?,
    );

Map<String, dynamic> _$TaxBillingModelToJson(TaxBillingModel instance) =>
    <String, dynamic>{
      'jenisPajak': instance.jenisPajak,
      'jenisPajakNama': instance.jenisPajakNama,
      'labelReferensi': instance.labelReferensi,
      'noReferensi': instance.noReferensi,
      'nomorPelayanan': instance.nomorPelayanan,
      'npwpd': instance.npwpd,
      'namaWp': instance.namaWp,
      'alamatWp': instance.alamatWp,
      'namaObjek': instance.namaObjek,
      'alamatObjek': instance.alamatObjek,
      'belumLunas': instance.belumLunas.map((e) => e.toJson()).toList(),
      'sudahLunas': instance.sudahLunas.map((e) => e.toJson()).toList(),
    };

TaxPeriodModel _$TaxPeriodModelFromJson(Map<String, dynamic> json) =>
    TaxPeriodModel(
      tahunPajak: (json['tahunPajak'] as num?)?.toInt() ?? 0,
      masaPajak: (json['masaPajak'] as num?)?.toInt() ?? 0,
      masaPajakNama: json['masaPajakNama'] as String? ?? '',
      jatuhTempo: json['jatuhTempo'] as String? ?? '',
      bulanTerlambat: (json['bulanTerlambat'] as num?)?.toInt() ?? 0,
      pokok: json['pokok'] as num? ?? 0,
      sanksi: json['sanksi'] as num? ?? 0,
      lainnya: json['lainnya'] as num? ?? 0,
      pengurang: json['pengurang'] as num? ?? 0,
      total: json['total'] as num? ?? 0,
      isLunas: json['isLunas'] as bool? ?? false,
      pembayaran: (json['pembayaran'] as List<dynamic>?)
              ?.map((e) =>
                  PaymentHistoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      keyTagihan: json['keyTagihan'] as String?,
      lainnyaLabel: json['lainnyaLabel'] as String?,
    );

Map<String, dynamic> _$TaxPeriodModelToJson(TaxPeriodModel instance) =>
    <String, dynamic>{
      'keyTagihan': instance.keyTagihan,
      'tahunPajak': instance.tahunPajak,
      'masaPajak': instance.masaPajak,
      'masaPajakNama': instance.masaPajakNama,
      'jatuhTempo': instance.jatuhTempo,
      'bulanTerlambat': instance.bulanTerlambat,
      'pokok': instance.pokok,
      'sanksi': instance.sanksi,
      'lainnya': instance.lainnya,
      'lainnyaLabel': instance.lainnyaLabel,
      'pengurang': instance.pengurang,
      'total': instance.total,
      'isLunas': instance.isLunas,
      'pembayaran': instance.pembayaran.map((e) => e.toJson()).toList(),
    };

PaymentHistoryModel _$PaymentHistoryModelFromJson(Map<String, dynamic> json) =>
    PaymentHistoryModel(
      tglBayar: json['tglBayar'] as String? ?? '',
      metodeBayar: json['metodeBayar'] as String? ?? '',
      jumlahBayar: json['jumlahBayar'] as num? ?? 0,
      noNtpd: json['noNtpd'] as String?,
    );

Map<String, dynamic> _$PaymentHistoryModelToJson(
        PaymentHistoryModel instance) =>
    <String, dynamic>{
      'tglBayar': instance.tglBayar,
      'noNtpd': instance.noNtpd,
      'metodeBayar': instance.metodeBayar,
      'jumlahBayar': instance.jumlahBayar,
    };
