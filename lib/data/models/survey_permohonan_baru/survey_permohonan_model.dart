import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/cek_reklames/survey_permohonan_baru/survey_permohonan_entity.dart';

part 'survey_permohonan_model.g.dart';

@JsonSerializable()
class SurveyPermohonanModel {
  @JsonKey(name: 'key')
  final String key;
  
  @JsonKey(name: 'keyTask')
  final String keyTask;
  
  @JsonKey(name: 'noPelayanan')
  final String noPelayanan;
  
  @JsonKey(name: 'npwpd')
  final String npwpd;
  
  @JsonKey(name: 'katPenyelenggaraan')
  final String katPenyelenggaraan;
  
  @JsonKey(name: 'kategoriPenyelenggaraanNama')
  final String kategoriPenyelenggaraanNama;
  
  @JsonKey(name: 'jenisReklameNama')
  final String jenisReklameNama;
  
  @JsonKey(name: 'lokPenyelenggaraan')
  final String lokPenyelenggaraan;
  
  @JsonKey(name: 'masaTayang')
  final String masaTayang;
  
  @JsonKey(name: 'masaPajakHari')
  final int masaPajakHari;
  
  @JsonKey(name: 'jumlahSisi')
  final int jumlahSisi;
  
  @JsonKey(name: 'statusProses')
  final String statusProses;
  
  @JsonKey(name: 'statusPermohonan')
  final String statusPermohonan;
  
  @JsonKey(name: 'startTask')
  final String startTask;
  
  @JsonKey(name: 'expTask')
  final String expTask;

  const SurveyPermohonanModel({
    required this.key,
    required this.keyTask,
    required this.noPelayanan,
    required this.npwpd,
    required this.katPenyelenggaraan,
    required this.kategoriPenyelenggaraanNama,
    required this.jenisReklameNama,
    required this.lokPenyelenggaraan,
    required this.masaTayang,
    required this.masaPajakHari,
    required this.jumlahSisi,
    required this.statusProses,
    required this.statusPermohonan,
    required this.startTask,
    required this.expTask,
  });

  factory SurveyPermohonanModel.fromJson(Map<String, dynamic> json) =>
      _$SurveyPermohonanModelFromJson(json);

  Map<String, dynamic> toJson() => _$SurveyPermohonanModelToJson(this);
}

// ====================================================================
// EXTENSION (MAPPER KE ENTITY)
// ====================================================================

extension SurveyPermohonanModelX on SurveyPermohonanModel {
  SurveyPermohonanEntity toEntity() => SurveyPermohonanEntity(
        key: key,
        keyTask: keyTask,
        noPelayanan: noPelayanan,
        npwpd: npwpd,
        katPenyelenggaraan: katPenyelenggaraan,
        kategoriPenyelenggaraanNama: kategoriPenyelenggaraanNama,
        jenisReklameNama: jenisReklameNama,
        lokPenyelenggaraan: lokPenyelenggaraan,
        masaTayang: masaTayang,
        masaPajakHari: masaPajakHari,
        jumlahSisi: jumlahSisi,
        statusProses: statusProses,
        statusPermohonan: statusPermohonan,
        startTask: startTask,
        expTask: expTask,
      );
}