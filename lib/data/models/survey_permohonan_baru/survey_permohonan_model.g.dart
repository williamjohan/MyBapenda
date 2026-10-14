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
    );

Map<String, dynamic> _$SurveyPermohonanModelToJson(
        SurveyPermohonanModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'keyTask': instance.keyTask,
      'noPelayanan': instance.noPelayanan,
      'npwpd': instance.npwpd,
      'katPenyelenggaraan': instance.katPenyelenggaraan,
      'kategoriPenyelenggaraanNama': instance.kategoriPenyelenggaraanNama,
      'jenisReklameNama': instance.jenisReklameNama,
      'lokPenyelenggaraan': instance.lokPenyelenggaraan,
      'masaTayang': instance.masaTayang,
      'masaPajakHari': instance.masaPajakHari,
      'jumlahSisi': instance.jumlahSisi,
      'statusProses': instance.statusProses,
      'statusPermohonan': instance.statusPermohonan,
      'startTask': instance.startTask,
      'expTask': instance.expTask,
    };
