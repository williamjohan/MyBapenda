import 'package:equatable/equatable.dart';

// ====================================================================
// LEVEL 1: SurveyDetailEntity
// ====================================================================
class SurveyDetailEntity extends Equatable {
  final String key;
  final String noPelayanan;
  final String npwpd;
  final String katPenyelenggaraan;
  final String? kategoriPenyelenggaraanNama;
  final String? statusPermohonan;
  final String? header;
  final String? checkin;
  final List<SisiListEntity> sisiList;

  const SurveyDetailEntity({
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

  @override
  List<Object?> get props => [
        key, noPelayanan, npwpd, katPenyelenggaraan,
        kategoriPenyelenggaraanNama, statusPermohonan,
        header, checkin, sisiList,
      ];
}

// ====================================================================
// LEVEL 2: SISI LIST ENTITY 
// ====================================================================
class SisiListEntity extends Equatable {
  final int seq;
  final String keySisi;
  final String? imageUrl;
  final String? jenisReklameNama;
  final String? lokPenyelenggaraanPermohonan;
  final String? materiReklamePermohonan;
  final String? masaTayang;
  final String? nor;
  final SurveyDataEntity? survey;

  const SisiListEntity({
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

  @override
  List<Object?> get props => [
        seq, keySisi, imageUrl, jenisReklameNama,
        lokPenyelenggaraanPermohonan, materiReklamePermohonan,
        masaTayang, nor, survey,
      ];
}

// ====================================================================
// LEVEL 3: SURVEY DATA ENTITY 
// ====================================================================
class SurveyDataEntity extends Equatable {
  final int seq;
  final int? idNor;
  final int? idPersil;
  final int? lokasiTertentuId;
  final String? letakReklame;
  final String? statusTanah;
  final String? lokPenyelenggaraan;
  final double? panjang;
  final double? lebar;
  final double? tinggi;
  final int? idJenisReklame;
  final int? idJenisProduk;
  final String? sudutPandang;
  final String? ketSisi;
  final String? materiReklame;
  final String? ketSurvey;

  const SurveyDataEntity({
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

  @override
  List<Object?> get props => [
        seq, idNor, idPersil, lokasiTertentuId, letakReklame, statusTanah,
        lokPenyelenggaraan, panjang, lebar, tinggi, idJenisReklame,
        idJenisProduk, sudutPandang, ketSisi, materiReklame, ketSurvey,
      ];
}

// ====================================================================
// EXTENSION: UI LOGIC HELPERS (BUSINESS RULES)
// 
// ====================================================================

extension SurveyDataEntityHelper on SurveyDataEntity {
  
  // 1. Helper State: Jika isi tidak null, maka UI harus Read-Only
  bool get isPanjangReadOnly => panjang != null;
  bool get isLebarReadOnly => lebar != null;
  bool get isTinggiReadOnly => tinggi != null;
  bool get isLetakReklameReadOnly => letakReklame != null;
  bool get isStatusTanahReadOnly => statusTanah != null;
  bool get isLokPenyelenggaraanReadOnly => lokPenyelenggaraan != null;
  bool get isSudutPandangReadOnly => sudutPandang != null;
  bool get isKetSisiReadOnly => ketSisi != null;
  bool get isMateriReklameReadOnly => materiReklame != null;
  bool get isKetSurveyReadOnly => ketSurvey != null;
  bool get isIdJenisReklameReadOnly => idJenisReklame != null;
  bool get isIdJenisProdukReadOnly => idJenisProduk != null;

  // 2. Helper Komposit (Gabungan): Sangat berguna untuk validasi Submit Button di UI
  bool get isDimensiLengkap => panjang != null && lebar != null && tinggi != null;
  
  // 3. Helper Cek Keseluruhan Form Survey
  bool get isSurveyLengkap => isDimensiLengkap && 
                              letakReklame != null && 
                              statusTanah != null; 
}