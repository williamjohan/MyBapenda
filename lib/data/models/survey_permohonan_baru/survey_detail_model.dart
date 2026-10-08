import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/cek_reklames/survey_permohonan_baru/detail_survey_entity.dart';

part 'survey_detail_model.g.dart';

// ====================================================================
// LEVEL 1: ROOT MODEL (SurveyDetailModel)
// ====================================================================
@JsonSerializable(explicitToJson: true)
class SurveyDetailModel {
  @JsonKey(name: 'key')
  final String key;
  @JsonKey(name: 'noPelayanan')
  final String noPelayanan;
  @JsonKey(name: 'npwpd')
  final String npwpd;
  @JsonKey(name: 'katPenyelenggaraan')
  final String katPenyelenggaraan;
  @JsonKey(name: 'kategoriPenyelenggaraanNama')
  final String? kategoriPenyelenggaraanNama;
  @JsonKey(name: 'statusPermohonan')
  final String? statusPermohonan;
  @JsonKey(name: 'header')
  final String? header;
  @JsonKey(name: 'checkin')
  final String? checkin;
  @JsonKey(name: 'sisiList')
  final List<SisiListModel> sisiList;

  const SurveyDetailModel({
    required this.key,
    required this.noPelayanan,
    required this.npwpd,
    required this.katPenyelenggaraan,
    this.kategoriPenyelenggaraanNama,
    this.statusPermohonan,
    this.header,
    this.checkin,
    required this.sisiList,
  });

  factory SurveyDetailModel.fromJson(Map<String, dynamic> json) =>
      _$SurveyDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$SurveyDetailModelToJson(this);
}

// ====================================================================
// LEVEL 2: SISI LIST MODEL
// ====================================================================
@JsonSerializable(explicitToJson: true)
class SisiListModel {
  @JsonKey(name: 'seq')
  final int seq;
  @JsonKey(name: 'keySisi')
  final String keySisi;
  @JsonKey(name: 'imageUrl')
  final String? imageUrl;
  @JsonKey(name: 'jenisReklameNama')
  final String? jenisReklameNama;
  @JsonKey(name: 'lokPenyelenggaraanPermohonan')
  final String? lokPenyelenggaraanPermohonan;
  @JsonKey(name: 'materiReklamePermohonan')
  final String? materiReklamePermohonan;
  @JsonKey(name: 'masaTayang')
  final String? masaTayang;
  @JsonKey(name: 'nor')
  final String? nor;
  @JsonKey(name: 'survey')
  final SurveyDataModel? survey;

  const SisiListModel({
    required this.seq,
    required this.keySisi,
    this.imageUrl,
    this.jenisReklameNama,
    this.lokPenyelenggaraanPermohonan,
    this.materiReklamePermohonan,
    this.masaTayang,
    this.nor,
    this.survey,
  });

  factory SisiListModel.fromJson(Map<String, dynamic> json) =>
      _$SisiListModelFromJson(json);

  Map<String, dynamic> toJson() => _$SisiListModelToJson(this);
}

// ====================================================================
// LEVEL 3: SURVEY DATA MODEL
// ====================================================================
@JsonSerializable()
class SurveyDataModel {
  @JsonKey(name: 'seq')
  final int seq;
  @JsonKey(name: 'idNor')
  final int? idNor;
  @JsonKey(name: 'idPersil')
  final int? idPersil;
  @JsonKey(name: 'lokasiTertentuId')
  final int? lokasiTertentuId;
  @JsonKey(name: 'letakReklame')
  final String? letakReklame;
  @JsonKey(name: 'statusTanah')
  final String? statusTanah;
  @JsonKey(name: 'lokPenyelenggaraan')
  final String? lokPenyelenggaraan;
  @JsonKey(name: 'panjang')
  final double? panjang;
  @JsonKey(name: 'lebar')
  final double? lebar;
  @JsonKey(name: 'tinggi')
  final double? tinggi;
  @JsonKey(name: 'idJenisReklame')
  final int? idJenisReklame;
  @JsonKey(name: 'idJenisProduk')
  final int? idJenisProduk;
  @JsonKey(name: 'sudutPandang')
  final String? sudutPandang;
  @JsonKey(name: 'ketSisi')
  final String? ketSisi;
  @JsonKey(name: 'materiReklame')
  final String? materiReklame;
  @JsonKey(name: 'ketSurvey')
  final String? ketSurvey;

  const SurveyDataModel({
    required this.seq,
    this.idNor,
    this.idPersil,
    this.lokasiTertentuId,
    this.letakReklame,
    this.statusTanah,
    this.lokPenyelenggaraan,
    this.panjang,
    this.lebar,
    this.tinggi,
    this.idJenisReklame,
    this.idJenisProduk,
    this.sudutPandang,
    this.ketSisi,
    this.materiReklame,
    this.ketSurvey,
  });

  factory SurveyDataModel.fromJson(Map<String, dynamic> json) =>
      _$SurveyDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$SurveyDataModelToJson(this);
}

// ====================================================================
// EXTENSIONS (MAPPER KE ENTITY)
// ====================================================================
extension SurveyDetailModelX on SurveyDetailModel {
  SurveyDetailEntity toEntity() => SurveyDetailEntity(
        key: key,
        noPelayanan: noPelayanan,
        npwpd: npwpd,
        katPenyelenggaraan: katPenyelenggaraan,
        kategoriPenyelenggaraanNama: kategoriPenyelenggaraanNama,
        statusPermohonan: statusPermohonan,
        header: header,
        checkin: checkin,
        sisiList: sisiList.map((e) => e.toEntity()).toList(),
      );
}

extension SisiListModelX on SisiListModel {
  SisiListEntity toEntity() => SisiListEntity(
        seq: seq,
        keySisi: keySisi,
        imageUrl: imageUrl,
        jenisReklameNama: jenisReklameNama,
        lokPenyelenggaraanPermohonan: lokPenyelenggaraanPermohonan,
        materiReklamePermohonan: materiReklamePermohonan,
        masaTayang: masaTayang,
        nor: nor,
        survey: survey?.toEntity(), // 🚀 Safe call operator karena nullable
      );
}

extension SurveyDataModelX on SurveyDataModel {
  SurveyDataEntity toEntity() => SurveyDataEntity(
        seq: seq,
        idNor: idNor,
        idPersil: idPersil,
        lokasiTertentuId: lokasiTertentuId,
        letakReklame: letakReklame,
        statusTanah: statusTanah,
        lokPenyelenggaraan: lokPenyelenggaraan,
        panjang: panjang,
        lebar: lebar,
        tinggi: tinggi,
        idJenisReklame: idJenisReklame,
        idJenisProduk: idJenisProduk,
        sudutPandang: sudutPandang,
        ketSisi: ketSisi,
        materiReklame: materiReklame,
        ketSurvey: ketSurvey,
      );
}