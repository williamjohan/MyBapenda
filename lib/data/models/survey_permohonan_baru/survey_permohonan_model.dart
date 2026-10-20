import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/cek_reklames/survey_permohonan_baru/survey_permohonan_entity.dart';

part 'survey_permohonan_model.g.dart';

String? _textOrNull(Object? v) {
  if (v == null) return null;
  final s = '$v'.trim();
  return (s.isEmpty || s == '-') ? null : s;
}

/// "2026-10-16 07:57:20" -> DateTime
DateTime? _dateTimeOrNull(Object? v) =>
    v == null ? null : DateTime.tryParse('$v'.trim());

double _doubleFromJson(Object? v) {
  if (v is num) return v.toDouble();

  final result = double.tryParse('$v'.trim().replaceAll(',', '.'));

  if (result == null || !result.isFinite) {
    throw FormatException('Nilai koordinat tidak valid: $v');
  }

  return result;
}

@JsonSerializable(createToJson: false)
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

  @JsonKey(name: 'latitude', fromJson: _doubleFromJson)
  final double latitude;

  @JsonKey(name: 'longitude', fromJson: _doubleFromJson)
  final double longitude;

  // ---- Baru: tugas yang dikembalikan dari penilaian ----

  @JsonKey(name: 'dikembalikanPenilaian', defaultValue: false)
  final bool dikembalikanPenilaian;

  @JsonKey(name: 'ketPengembalian', fromJson: _textOrNull)
  final String? ketPengembalian;

  @JsonKey(name: 'tglPengembalian', fromJson: _dateTimeOrNull)
  final DateTime? tglPengembalian;

  @JsonKey(name: 'badge')
  final SurveyBadgeModel? badge;

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
    required this.dikembalikanPenilaian,
    this.ketPengembalian,
    this.tglPengembalian,
    this.badge,
    required this.latitude,
    required this.longitude,
  });

  factory SurveyPermohonanModel.fromJson(Map<String, dynamic> json) =>
      _$SurveyPermohonanModelFromJson(json);
}

// ====================================================================
// BADGE
// ====================================================================

@JsonSerializable(createToJson: false)
class SurveyBadgeModel {
  @JsonKey(name: 'text', defaultValue: '')
  final String text;

  @JsonKey(name: 'color')
  final SurveyBadgeColorModel? color;

  const SurveyBadgeModel({required this.text, this.color});

  factory SurveyBadgeModel.fromJson(Map<String, dynamic> json) =>
      _$SurveyBadgeModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class SurveyBadgeColorModel {
  @JsonKey(name: 'description', defaultValue: '')
  final String description;

  const SurveyBadgeColorModel({required this.description});

  factory SurveyBadgeColorModel.fromJson(Map<String, dynamic> json) =>
      _$SurveyBadgeColorModelFromJson(json);
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
    dikembalikanPenilaian: dikembalikanPenilaian,
    ketPengembalian: ketPengembalian,
    tglPengembalian: tglPengembalian,
    latitude: latitude,
    longitude: longitude,
    badge: badge == null
        ? null
        : SurveyBadgeEntity(
            text: badge!.text,
            color: (badge!.color?.description ?? '').toLowerCase(),
          ),
  );
}
