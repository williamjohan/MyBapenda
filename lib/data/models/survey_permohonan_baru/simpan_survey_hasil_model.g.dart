// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simpan_survey_hasil_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpanSurveyHasilModel _$SimpanSurveyHasilModelFromJson(
        Map<String, dynamic> json) =>
    SimpanSurveyHasilModel(
      hasil: json['hasil'] as String? ?? 'Draft',
      kurangLengkap: (json['kurangLengkap'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      message: json['message'] as String? ?? '',
    );

Map<String, dynamic> _$SimpanSurveyHasilModelToJson(
        SimpanSurveyHasilModel instance) =>
    <String, dynamic>{
      'hasil': instance.hasil,
      'kurangLengkap': instance.kurangLengkap,
      'message': instance.message,
    };
