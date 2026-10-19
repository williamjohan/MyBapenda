import 'package:bapendacore/domain/entities/cek_reklames/survey_permohonan_baru/survey_history_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'survey_history_model.g.dart';

// ====================================================================
// NORMALISASI (dipakai lewat @JsonKey(fromJson: ...))
// ====================================================================

/// "2026-10-14 00:00:00" -> DateTime. Dart menerima spasi sebagai pemisah.
DateTime? _date(Object? v) {
  if (v == null) return null;
  return DateTime.tryParse('$v'.trim());
}

/// "-7.257926" -> -7.257926
double? _coord(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse('$v'.trim());
}

/// null, kosong, atau "-" -> null.
String? _clean(Object? v) {
  if (v == null) return null;
  final s = '$v'.trim();
  return (s.isEmpty || s == '-') ? null : s;
}

// ====================================================================
// LIST
// ====================================================================
@JsonSerializable(createToJson: false)
class SurveyHistoryModel {
  @JsonKey(defaultValue: '')
  final String key;

  // Di list namanya noPermohonan, di detail noPelayanan.
  @JsonKey(name: 'noPermohonan', defaultValue: '-')
  final String noPelayanan;

  @JsonKey(fromJson: _clean)
  final String? noFormulir;

  @JsonKey(defaultValue: '-')
  final String npwpd;

  @JsonKey(defaultValue: '-')
  final String namaPemohon;

  @JsonKey(fromJson: _clean)
  final String? alamatPemohon;

  @JsonKey(fromJson: _date)
  final DateTime? tanggalPermohonan;

  @JsonKey(name: 'kategoriPenyelenggaraan', defaultValue: '-')
  final String kategori;

  @JsonKey(defaultValue: '-')
  final String jenisProduk;

  @JsonKey(defaultValue: '-')
  final String jenisReklame;

  @JsonKey(defaultValue: '-')
  final String materi;

  @JsonKey(defaultValue: '-')
  final String lokPenyelenggaraan;

  @JsonKey(defaultValue: '-')
  final String statusPermohonan;

  @JsonKey(defaultValue: '-')
  final String statusProses;

  @JsonKey(defaultValue: 0)
  final int jumlahSisi;

  @JsonKey(fromJson: _date)
  final DateTime? tglSurvey;

  const SurveyHistoryModel({
    required this.key,
    required this.noPelayanan,
    this.noFormulir,
    required this.npwpd,
    required this.namaPemohon,
    this.alamatPemohon,
    this.tanggalPermohonan,
    required this.kategori,
    required this.jenisProduk,
    required this.jenisReklame,
    required this.materi,
    required this.lokPenyelenggaraan,
    required this.statusPermohonan,
    required this.statusProses,
    required this.jumlahSisi,
    this.tglSurvey,
  });

  factory SurveyHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$SurveyHistoryModelFromJson(json);
}

// ====================================================================
// DETAIL
// ====================================================================
@JsonSerializable(createToJson: false)
class SurveyHistoryDetailModel {
  @JsonKey(defaultValue: '')
  final String key;

  @JsonKey(defaultValue: '-')
  final String noPelayanan;

  @JsonKey(fromJson: _clean)
  final String? noFormulir;

  @JsonKey(defaultValue: '-')
  final String npwpd;

  @JsonKey(fromJson: _clean)
  final String? katPenyelenggaraan;

  @JsonKey(fromJson: _clean)
  final String? kategoriPenyelenggaraanNama;

  @JsonKey(defaultValue: '-')
  final String statusPermohonan;

  @JsonKey(defaultValue: '-')
  final String statusProses;

  @JsonKey(defaultValue: 0)
  final int jumlahSisi;

  @JsonKey(fromJson: _clean)
  final String? laporanPdfUrl;

  final HistoryPetugasModel? petugas;

  @JsonKey(defaultValue: [])
  final List<HistorySisiModel> sisiList;

  const SurveyHistoryDetailModel({
    required this.key,
    required this.noPelayanan,
    this.noFormulir,
    required this.npwpd,
    this.katPenyelenggaraan,
    this.kategoriPenyelenggaraanNama,
    required this.statusPermohonan,
    required this.statusProses,
    required this.jumlahSisi,
    this.laporanPdfUrl,
    this.petugas,
    required this.sisiList,
  });

  factory SurveyHistoryDetailModel.fromJson(Map<String, dynamic> json) =>
      _$SurveyHistoryDetailModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class HistoryPetugasModel {
  final HistoryPegawaiModel? petugasUtama;

  @JsonKey(defaultValue: [])
  final List<HistoryPegawaiModel> pembantu;

  // Di JSON bernama "foto" (selfie check-in petugas).
  @JsonKey(name: 'foto')
  final HistoryCheckinModel? checkin;

  const HistoryPetugasModel({
    this.petugasUtama,
    required this.pembantu,
    this.checkin,
  });

  factory HistoryPetugasModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryPetugasModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class HistoryPegawaiModel {
  @JsonKey(defaultValue: '')
  final String nip;

  @JsonKey(defaultValue: '-')
  final String nama;

  const HistoryPegawaiModel({required this.nip, required this.nama});

  factory HistoryPegawaiModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryPegawaiModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class HistoryCheckinModel {
  @JsonKey(fromJson: _clean)
  final String? imageUrl;

  @JsonKey(fromJson: _coord)
  final double? latitude;

  @JsonKey(fromJson: _coord)
  final double? longitude;

  @JsonKey(fromJson: _clean)
  final String? alamat;

  @JsonKey(name: 'insDate', fromJson: _date)
  final DateTime? waktu;

  const HistoryCheckinModel({
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.alamat,
    this.waktu,
  });

  factory HistoryCheckinModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryCheckinModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class HistorySisiModel {
  @JsonKey(defaultValue: 0)
  final int seq;

  @JsonKey(fromJson: _date)
  final DateTime? tglSurvey;

  @JsonKey(name: 'insByNama', fromJson: _clean)
  final String? petugasNama;

  @JsonKey(name: 'insDate', fromJson: _date)
  final DateTime? diinputPada;

  @JsonKey(fromJson: _clean)
  final String? kecamatan;
  @JsonKey(fromJson: _clean)
  final String? kelurahan;
  @JsonKey(fromJson: _clean)
  final String? lokPenyelenggaraan;
  @JsonKey(fromJson: _clean)
  final String? lokasiTertentu;
  @JsonKey(fromJson: _clean)
  final String? noImb;

  @JsonKey(fromJson: _coord)
  final double? latitude;
  @JsonKey(fromJson: _coord)
  final double? longitude;

  final double? panjang;
  final double? lebar;
  final double? tinggi;

  @JsonKey(fromJson: _clean)
  final String? jenisReklame;
  @JsonKey(fromJson: _clean)
  final String? jenisProduk;
  @JsonKey(fromJson: _clean)
  final String? letakReklame;
  @JsonKey(fromJson: _clean)
  final String? statusTanah;
  @JsonKey(fromJson: _clean)
  final String? sudutPandang;

  @JsonKey(fromJson: _clean)
  final String? materiReklame;
  @JsonKey(fromJson: _clean)
  final String? ketSisi;
  @JsonKey(fromJson: _clean)
  final String? ketSurvey;

  @JsonKey(defaultValue: [])
  final List<HistoryFotoModel> fotos;

  const HistorySisiModel({
    required this.seq,
    this.tglSurvey,
    this.petugasNama,
    this.diinputPada,
    this.kecamatan,
    this.kelurahan,
    this.lokPenyelenggaraan,
    this.lokasiTertentu,
    this.noImb,
    this.latitude,
    this.longitude,
    this.panjang,
    this.lebar,
    this.tinggi,
    this.jenisReklame,
    this.jenisProduk,
    this.letakReklame,
    this.statusTanah,
    this.sudutPandang,
    this.materiReklame,
    this.ketSisi,
    this.ketSurvey,
    required this.fotos,
  });

  factory HistorySisiModel.fromJson(Map<String, dynamic> json) =>
      _$HistorySisiModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class HistoryFotoModel {
  @JsonKey(defaultValue: '')
  final String key;

  @JsonKey(defaultValue: '')
  final String imageUrl;

  @JsonKey(fromJson: _clean)
  final String? keterangan;

  const HistoryFotoModel({
    required this.key,
    required this.imageUrl,
    this.keterangan,
  });

  factory HistoryFotoModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryFotoModelFromJson(json);
}

// ====================================================================
// MAPPER KE ENTITY
// ====================================================================
extension SurveyHistoryModelX on SurveyHistoryModel {
  SurveyHistoryEntity toEntity() => SurveyHistoryEntity(
    key: key,
    noPelayanan: noPelayanan,
    noFormulir: noFormulir,
    npwpd: npwpd,
    namaPemohon: namaPemohon,
    alamatPemohon: alamatPemohon,
    tanggalPermohonan: tanggalPermohonan,
    kategori: kategori,
    jenisProduk: jenisProduk,
    jenisReklame: jenisReklame,
    materi: materi,
    lokPenyelenggaraan: lokPenyelenggaraan,
    statusPermohonan: statusPermohonan,
    statusProses: statusProses,
    jumlahSisi: jumlahSisi,
    tglSurvey: tglSurvey,
  );
}

extension SurveyHistoryDetailModelX on SurveyHistoryDetailModel {
  SurveyHistoryDetailEntity toEntity() => SurveyHistoryDetailEntity(
    key: key,
    noPelayanan: noPelayanan,
    noFormulir: noFormulir,
    npwpd: npwpd,
    kategori: kategoriPenyelenggaraanNama ?? katPenyelenggaraan ?? '-',
    statusPermohonan: statusPermohonan,
    statusProses: statusProses,
    jumlahSisi: jumlahSisi,
    laporanPdfUrl: laporanPdfUrl,
    petugas: (petugas ?? const HistoryPetugasModel(pembantu: [])).toEntity(),
    sisiList: sisiList.map((e) => e.toEntity()).toList(),
  );
}

extension HistoryPetugasModelX on HistoryPetugasModel {
  HistoryPetugasEntity toEntity() => HistoryPetugasEntity(
    utama: (petugasUtama ?? const HistoryPegawaiModel(nip: '', nama: '-'))
        .toEntity(),
    pembantu: pembantu.map((e) => e.toEntity()).toList(),
    checkin: checkin?.toEntity(),
  );
}

extension HistoryPegawaiModelX on HistoryPegawaiModel {
  HistoryPegawaiEntity toEntity() => HistoryPegawaiEntity(nip: nip, nama: nama);
}

extension HistoryCheckinModelX on HistoryCheckinModel {
  HistoryCheckinEntity toEntity() => HistoryCheckinEntity(
    imageUrl: imageUrl,
    latitude: latitude,
    longitude: longitude,
    alamat: alamat,
    waktu: waktu,
  );
}

extension HistorySisiModelX on HistorySisiModel {
  HistorySisiEntity toEntity() => HistorySisiEntity(
    seq: seq,
    tglSurvey: tglSurvey,
    petugasNama: petugasNama,
    diinputPada: diinputPada,
    kecamatan: kecamatan,
    kelurahan: kelurahan,
    lokPenyelenggaraan: lokPenyelenggaraan,
    lokasiTertentu: lokasiTertentu,
    noImb: noImb,
    latitude: latitude,
    longitude: longitude,
    panjang: panjang,
    lebar: lebar,
    tinggi: tinggi,
    jenisReklame: jenisReklame,
    jenisProduk: jenisProduk,
    letakReklame: letakReklame,
    statusTanah: statusTanah,
    sudutPandang: sudutPandang,
    materiReklame: materiReklame,
    ketSisi: ketSisi,
    ketSurvey: ketSurvey,
    fotos: fotos.map((e) => e.toEntity()).toList(),
  );
}

extension HistoryFotoModelX on HistoryFotoModel {
  HistoryFotoEntity toEntity() =>
      HistoryFotoEntity(key: key, imageUrl: imageUrl, keterangan: keterangan);
}
