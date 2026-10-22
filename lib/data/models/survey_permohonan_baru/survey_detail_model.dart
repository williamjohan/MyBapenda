import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/cek_reklames/survey_permohonan_baru/detail_survey_entity.dart';

part 'survey_detail_model.g.dart';

// ====================================================================
// NORMALISASI
// ====================================================================

/// Angka atau teks -> String. Kosong -> null.
String? _strOrNull(Object? v) {
  if (v == null) return null;
  final s = '$v'.trim();
  return s.isEmpty ? null : s;
}

/// "3" atau 3 -> 3. Selain itu null.
int? _intOrNull(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v'.trim());
}

/// "-7.25" atau -7.25 -> -7.25. Kosong / bukan angka -> null.
double? _doubleOrNull(Object? v) {
  if (v is num) return v.toDouble();
  if (v == null) return null;
  return double.tryParse('$v'.trim().replaceAll(',', '.'));
}

String? _cleanOrNull(Object? v) {
  if (v == null) return null;
  final s = '$v'.trim();
  return (s.isEmpty || s == '-') ? null : s;
}

SurveyDetailHeaderModel? _headerFrom(Object? v) => v is Map
    ? SurveyDetailHeaderModel.fromJson(Map<String, dynamic>.from(v))
    : null;

SurveyDetailCheckinModel? _checkinFrom(Object? v) => v is Map
    ? SurveyDetailCheckinModel.fromJson(Map<String, dynamic>.from(v))
    : null;

/// Object -> parse. String (format lama) -> hanya idNor. Selain itu null.
SisiNorModel? _norFrom(Object? v) {
  if (v is Map) return SisiNorModel.fromJson(Map<String, dynamic>.from(v));
  if (v is String && v.trim().isNotEmpty) return SisiNorModel(idNor: v.trim());
  return null;
}

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
  @JsonKey(name: 'isDraft', defaultValue: false)
  final bool isDraft;

  /// Radius maksimal pin reklame dari posisi petugas (meter, setting server).
  @JsonKey(name: 'jarakMaksMeter', fromJson: _intOrNull)
  final int? jarakMaksMeter;

  @JsonKey(name: 'header', fromJson: _headerFrom, includeToJson: false)
  final SurveyDetailHeaderModel? header;
  @JsonKey(name: 'checkin', fromJson: _checkinFrom, includeToJson: false)
  final SurveyDetailCheckinModel? checkin;

  @JsonKey(name: 'sisiList', defaultValue: [])
  final List<SisiListModel> sisiList;

  const SurveyDetailModel({
    required this.key,
    required this.noPelayanan,
    required this.npwpd,
    required this.katPenyelenggaraan,
    this.kategoriPenyelenggaraanNama,
    this.statusPermohonan,
    this.isDraft = false,
    this.jarakMaksMeter,
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
  @JsonKey(name: 'nor', fromJson: _norFrom, includeToJson: false)
  final SisiNorModel? nor;
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

  // ID string dari BE (mis. idPersil "0000003000" punya nol di depan).
  @JsonKey(name: 'idNor', fromJson: _strOrNull)
  final String? idNor;
  @JsonKey(name: 'idPersil', fromJson: _strOrNull)
  final String? idPersil;

  // ID master (angka).
  @JsonKey(name: 'lokasiTertentuId', fromJson: _intOrNull)
  final int? lokasiTertentuId;
  @JsonKey(name: 'letakReklame', fromJson: _intOrNull)
  final int? letakReklame;
  @JsonKey(name: 'statusTanah', fromJson: _intOrNull)
  final int? statusTanah;
  @JsonKey(name: 'idJenisReklame', fromJson: _intOrNull)
  final int? idJenisReklame;
  @JsonKey(name: 'idJenisProduk', fromJson: _intOrNull)
  final int? idJenisProduk;
  @JsonKey(name: 'sudutPandang', fromJson: _intOrNull)
  final int? sudutPandang;

  @JsonKey(name: 'lokPenyelenggaraan')
  final String? lokPenyelenggaraan;
  @JsonKey(name: 'panjang')
  final double? panjang;
  @JsonKey(name: 'lebar')
  final double? lebar;
  @JsonKey(name: 'tinggi')
  final double? tinggi;
  @JsonKey(name: 'ketSisi')
  final String? ketSisi;
  @JsonKey(name: 'materiReklame')
  final String? materiReklame;
  @JsonKey(name: 'ketSurvey')
  final String? ketSurvey;
  @JsonKey(name: 'latitude', fromJson: _doubleOrNull)
  final double? latitude;
  @JsonKey(name: 'longitude', fromJson: _doubleOrNull)
  final double? longitude;

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
    this.latitude,
    this.longitude,
  });

  factory SurveyDataModel.fromJson(Map<String, dynamic> json) =>
      _$SurveyDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$SurveyDataModelToJson(this);
}

@JsonSerializable(createToJson: false)
class SurveyDetailHeaderModel {
  @JsonKey(name: 'kecamatan', fromJson: _cleanOrNull)
  final String? kecamatan;
  @JsonKey(name: 'kelurahan', fromJson: _cleanOrNull)
  final String? kelurahan;
  @JsonKey(name: 'lokBlok', fromJson: _cleanOrNull)
  final String? blok;
  @JsonKey(name: 'lokRt', fromJson: _cleanOrNull)
  final String? rt;
  @JsonKey(name: 'lokRw', fromJson: _cleanOrNull)
  final String? rw;

  const SurveyDetailHeaderModel({
    this.kecamatan,
    this.kelurahan,
    this.blok,
    this.rt,
    this.rw,
  });

  factory SurveyDetailHeaderModel.fromJson(Map<String, dynamic> json) =>
      _$SurveyDetailHeaderModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class SurveyDetailCheckinModel {
  @JsonKey(name: 'nipPembantu', defaultValue: <String>[])
  final List<String> nipPembantu;

  // true = check-in draft (foto + lokasi) tersimpan; app tidak check-in ulang.
  @JsonKey(name: 'tersimpan', defaultValue: false)
  final bool tersimpan;
  @JsonKey(name: 'latitude', fromJson: _doubleOrNull)
  final double? latitude;
  @JsonKey(name: 'longitude', fromJson: _doubleOrNull)
  final double? longitude;
  @JsonKey(name: 'alamat', fromJson: _cleanOrNull)
  final String? alamat;
  @JsonKey(name: 'fotoUrl', fromJson: _strOrNull)
  final String? fotoUrl;
  // yyyy-MM-dd HH:mm:ss
  @JsonKey(name: 'tglCheckin', fromJson: _strOrNull)
  final String? tglCheckin;

  const SurveyDetailCheckinModel({
    required this.nipPembantu,
    this.tersimpan = false,
    this.latitude,
    this.longitude,
    this.alamat,
    this.fotoUrl,
    this.tglCheckin,
  });

  factory SurveyDetailCheckinModel.fromJson(Map<String, dynamic> json) =>
      _$SurveyDetailCheckinModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class SisiNorModel {
  @JsonKey(name: 'idNor', fromJson: _strOrNull)
  final String? idNor;
  @JsonKey(name: 'idPersil', fromJson: _strOrNull)
  final String? idPersil;
  @JsonKey(name: 'noAlamat', fromJson: _cleanOrNull)
  final String? noAlamat;

  const SisiNorModel({this.idNor, this.idPersil, this.noAlamat});

  factory SisiNorModel.fromJson(Map<String, dynamic> json) =>
      _$SisiNorModelFromJson(json);
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
    isDraft: isDraft,
    jarakMaksMeter: jarakMaksMeter,
    header: header?.toEntity(),
    checkin: checkin?.toEntity(),
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
    nor: nor?.toEntity(),
    survey: survey?.toEntity(),
  );
}

extension SurveyDetailHeaderModelX on SurveyDetailHeaderModel {
  DetailHeaderEntity toEntity() => DetailHeaderEntity(
    kecamatan: kecamatan,
    kelurahan: kelurahan,
    blok: blok,
    rt: rt,
    rw: rw,
  );
}

extension SurveyDetailCheckinModelX on SurveyDetailCheckinModel {
  DetailCheckinEntity toEntity() => DetailCheckinEntity(
    nipPembantu: nipPembantu,
    // Tanpa koordinat check-in tidak bisa dipakai ulang.
    tersimpan: tersimpan && latitude != null && longitude != null,
    latitude: latitude,
    longitude: longitude,
    alamat: alamat,
    fotoUrl: fotoUrl,
    tglCheckin: tglCheckin,
  );
}

extension SisiNorModelX on SisiNorModel {
  SisiNorEntity toEntity() =>
      SisiNorEntity(idNor: idNor, idPersil: idPersil, noAlamat: noAlamat);
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
    latitude: latitude,
    longitude: longitude,
  );
}
