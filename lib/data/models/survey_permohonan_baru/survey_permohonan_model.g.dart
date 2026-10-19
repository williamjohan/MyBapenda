// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_permohonan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurveyPermohonanModel _$SurveyPermohonanModelFromJson(
        Map<String, dynamic> json) =>
    SurveyPermohonanModel(
      key: json['key'] as String,
      keyTask: json['keyTask'] as String,
      noPelayanan: json['noPelayanan'] as String,
      npwpd: json['npwpd'] as String,
      katPenyelenggaraan: json['katPenyelenggaraan'] as String,
      kategoriPenyelenggaraanNama:
          json['kategoriPenyelenggaraanNama'] as String,
      jenisReklameNama: json['jenisReklameNama'] as String,
      lokPenyelenggaraan: json['lokPenyelenggaraan'] as String,
      masaTayang: json['masaTayang'] as String,
      masaPajakHari: (json['masaPajakHari'] as num).toInt(),
      jumlahSisi: (json['jumlahSisi'] as num).toInt(),
      statusProses: json['statusProses'] as String,
      statusPermohonan: json['statusPermohonan'] as String,
      startTask: json['startTask'] as String,
      expTask: json['expTask'] as String,
      dikembalikanPenilaian: json['dikembalikanPenilaian'] as bool? ?? false,
      ketPengembalian: _textOrNull(json['ketPengembalian']),
      tglPengembalian: _dateTimeOrNull(json['tglPengembalian']),
      badge: json['badge'] == null
          ? null
          : SurveyBadgeModel.fromJson(json['badge'] as Map<String, dynamic>),
    );

SurveyBadgeModel _$SurveyBadgeModelFromJson(Map<String, dynamic> json) =>
    SurveyBadgeModel(
      text: json['text'] as String? ?? '',
      color: json['color'] == null
          ? null
          : SurveyBadgeColorModel.fromJson(
              json['color'] as Map<String, dynamic>),
    );

SurveyBadgeColorModel _$SurveyBadgeColorModelFromJson(
        Map<String, dynamic> json) =>
    SurveyBadgeColorModel(
      description: json['description'] as String? ?? '',
    );
