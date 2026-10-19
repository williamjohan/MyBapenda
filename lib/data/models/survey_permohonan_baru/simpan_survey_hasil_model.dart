import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/cek_reklames/survey_permohonan_baru/simpan_survey_hasil_entity.dart';

part 'simpan_survey_hasil_model.g.dart';

@JsonSerializable()
class SimpanSurveyHasilModel {
  @JsonKey(name: 'hasil', defaultValue: SimpanSurveyHasilEntity.hasilDraft)
  final String hasil;
  @JsonKey(name: 'kurangLengkap', defaultValue: <String>[])
  final List<String> kurangLengkap;
  @JsonKey(name: 'message', defaultValue: '')
  final String message;

  const SimpanSurveyHasilModel({
    required this.hasil,
    required this.kurangLengkap,
    required this.message,
  });

  factory SimpanSurveyHasilModel.fromJson(Map<String, dynamic> json) =>
      _$SimpanSurveyHasilModelFromJson(json);

  Map<String, dynamic> toJson() => _$SimpanSurveyHasilModelToJson(this);
}

extension SimpanSurveyHasilModelX on SimpanSurveyHasilModel {
  SimpanSurveyHasilEntity toEntity() => SimpanSurveyHasilEntity(
    hasil: hasil,
    kurangLengkap: kurangLengkap,
    message: message,
  );
}
