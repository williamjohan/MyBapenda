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

  /// true = header & isian sisi berasal dari draft tersimpan.
  final bool isDraft;
  final DetailHeaderEntity? header;
  final DetailCheckinEntity? checkin;
  final List<SisiListEntity> sisiList;

  const SurveyDetailEntity({
    required this.key,
    required this.noPelayanan,
    required this.npwpd,
    required this.katPenyelenggaraan,
    this.kategoriPenyelenggaraanNama,
    this.statusPermohonan,
    this.isDraft = false,
    this.header,
    this.checkin,
    required this.sisiList,
  });

  @override
  List<Object?> get props => [
    key,
    noPelayanan,
    npwpd,
    katPenyelenggaraan,
    kategoriPenyelenggaraanNama,
    statusPermohonan,
    isDraft,
    header,
    checkin,
    sisiList,
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
  final SisiNorEntity? nor;
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
    seq,
    keySisi,
    imageUrl,
    jenisReklameNama,
    lokPenyelenggaraanPermohonan,
    materiReklamePermohonan,
    masaTayang,
    nor,
    survey,
  ];
}

// ====================================================================
// LEVEL 3: SURVEY DATA ENTITY
// ====================================================================
class SurveyDataEntity extends Equatable {
  final int seq;
  final String? idNor;
  final String? idPersil;
  final int? lokasiTertentuId;
  final int? letakReklame;
  final int? statusTanah;
  final String? lokPenyelenggaraan;
  final double? panjang;
  final double? lebar;
  final double? tinggi;
  final int? idJenisReklame;
  final int? idJenisProduk;
  final int? sudutPandang;
  final String? ketSisi;
  final String? materiReklame;
  final String? ketSurvey;

  /// Titik reklame sisi ini (draft / survey tersimpan).
  final double? latitude;
  final double? longitude;

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
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
    seq,
    idNor,
    idPersil,
    lokasiTertentuId,
    letakReklame,
    statusTanah,
    lokPenyelenggaraan,
    panjang,
    lebar,
    tinggi,
    idJenisReklame,
    idJenisProduk,
    sudutPandang,
    ketSisi,
    materiReklame,
    ketSurvey,
    latitude,
    longitude,
  ];
}

class DetailHeaderEntity extends Equatable {
  final String? kecamatan;
  final String? kelurahan;
  final String? blok;
  final String? rt;
  final String? rw;

  const DetailHeaderEntity({
    this.kecamatan,
    this.kelurahan,
    this.blok,
    this.rt,
    this.rw,
  });

  @override
  List<Object?> get props => [kecamatan, kelurahan, blok, rt, rw];
}

class DetailCheckinEntity extends Equatable {
  final List<String> nipPembantu;

  /// true = check-in draft tersimpan di server (survey baru yang sudah
  /// ber-draft). Petugas tidak perlu selfie & ambil lokasi ulang. Selalu
  /// false untuk survey ulang (dikembalikan dari penilaian).
  final bool tersimpan;
  final double? latitude;
  final double? longitude;
  final String? alamat;
  final String? fotoUrl;
  final String? tglCheckin;

  const DetailCheckinEntity({
    this.nipPembantu = const [],
    this.tersimpan = false,
    this.latitude,
    this.longitude,
    this.alamat,
    this.fotoUrl,
    this.tglCheckin,
  });

  @override
  List<Object?> get props => [
    nipPembantu,
    tersimpan,
    latitude,
    longitude,
    alamat,
    fotoUrl,
    tglCheckin,
  ];
}

class SisiNorEntity extends Equatable {
  final String? idNor;
  final String? idPersil;
  final String? noAlamat;

  const SisiNorEntity({this.idNor, this.idPersil, this.noAlamat});

  /// "000000K011 · BUKIT DARMO BOULEVARD, 009". Null kalau kosong.
  String? get label {
    final parts = [if (idNor != null) idNor!, if (noAlamat != null) noAlamat!];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  @override
  List<Object?> get props => [idNor, idPersil, noAlamat];
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
  bool get isDimensiLengkap =>
      panjang != null && lebar != null && tinggi != null;

  // 3. Helper Cek Keseluruhan Form Survey
  bool get isSurveyLengkap =>
      isDimensiLengkap && letakReklame != null && statusTanah != null;
}
