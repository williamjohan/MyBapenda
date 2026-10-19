import 'package:equatable/equatable.dart';

// ---------------------------------------------------------------------------
// LIST
// ---------------------------------------------------------------------------
class SurveyHistoryEntity extends Equatable {
  final String key;
  final String noPelayanan;
  final String? noFormulir;
  final String npwpd;
  final String namaPemohon;
  final String? alamatPemohon;
  final DateTime? tanggalPermohonan;
  final String kategori;
  final String jenisProduk;
  final String jenisReklame;
  final String materi;
  final String lokPenyelenggaraan;
  final String statusPermohonan;
  final String statusProses;
  final int jumlahSisi;
  final DateTime? tglSurvey;

  const SurveyHistoryEntity({
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

  @override
  List<Object?> get props => [
    key,
    noPelayanan,
    noFormulir,
    npwpd,
    namaPemohon,
    alamatPemohon,
    tanggalPermohonan,
    kategori,
    jenisProduk,
    jenisReklame,
    materi,
    lokPenyelenggaraan,
    statusPermohonan,
    statusProses,
    jumlahSisi,
    tglSurvey,
  ];
}

// ---------------------------------------------------------------------------
// DETAIL
// ---------------------------------------------------------------------------
class SurveyHistoryDetailEntity extends Equatable {
  final String key;
  final String noPelayanan;
  final String? noFormulir;
  final String npwpd;
  final String kategori;
  final String statusPermohonan;
  final String statusProses;
  final int jumlahSisi;
  final String? laporanPdfUrl;
  final HistoryPetugasEntity petugas;
  final List<HistorySisiEntity> sisiList;

  const SurveyHistoryDetailEntity({
    required this.key,
    required this.noPelayanan,
    this.noFormulir,
    required this.npwpd,
    required this.kategori,
    required this.statusPermohonan,
    required this.statusProses,
    required this.jumlahSisi,
    this.laporanPdfUrl,
    required this.petugas,
    required this.sisiList,
  });

  @override
  List<Object?> get props => [
    key,
    noPelayanan,
    noFormulir,
    npwpd,
    kategori,
    statusPermohonan,
    statusProses,
    jumlahSisi,
    laporanPdfUrl,
    petugas,
    sisiList,
  ];
}

class HistoryPetugasEntity extends Equatable {
  final HistoryPegawaiEntity utama;
  final List<HistoryPegawaiEntity> pembantu;
  final HistoryCheckinEntity? checkin;

  const HistoryPetugasEntity({
    required this.utama,
    this.pembantu = const [],
    this.checkin,
  });

  @override
  List<Object?> get props => [utama, pembantu, checkin];
}

class HistoryPegawaiEntity extends Equatable {
  final String nip;
  final String nama;

  const HistoryPegawaiEntity({required this.nip, required this.nama});

  /// "NAMA (NIP)", sama dengan field `tampil` dari BE.
  String get tampil => '$nama ($nip)';

  @override
  List<Object?> get props => [nip, nama];
}

/// Selfie petugas saat check-in.
class HistoryCheckinEntity extends Equatable {
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final String? alamat;
  final DateTime? waktu;

  const HistoryCheckinEntity({
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.alamat,
    this.waktu,
  });

  bool get hasCoordinate => latitude != null && longitude != null;

  @override
  List<Object?> get props => [imageUrl, latitude, longitude, alamat, waktu];
}

class HistorySisiEntity extends Equatable {
  final int seq;
  final DateTime? tglSurvey;
  final String? petugasNama;
  final DateTime? diinputPada;

  // Lokasi
  final String? kecamatan;
  final String? kelurahan;
  final String? lokPenyelenggaraan;
  final String? lokasiTertentu;
  final String? noImb;
  final double? latitude;
  final double? longitude;

  // Ukuran & jenis
  final double? panjang;
  final double? lebar;
  final double? tinggi;
  final String? jenisReklame;
  final String? jenisProduk;
  final String? letakReklame;
  final String? statusTanah;
  final String? sudutPandang;

  // Keterangan
  final String? materiReklame;
  final String? ketSisi;
  final String? ketSurvey;

  final List<HistoryFotoEntity> fotos;

  const HistorySisiEntity({
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
    this.fotos = const [],
  });

  bool get hasCoordinate => latitude != null && longitude != null;

  @override
  List<Object?> get props => [
    seq,
    tglSurvey,
    petugasNama,
    diinputPada,
    kecamatan,
    kelurahan,
    lokPenyelenggaraan,
    lokasiTertentu,
    noImb,
    latitude,
    longitude,
    panjang,
    lebar,
    tinggi,
    jenisReklame,
    jenisProduk,
    letakReklame,
    statusTanah,
    sudutPandang,
    materiReklame,
    ketSisi,
    ketSurvey,
    fotos,
  ];
}

class HistoryFotoEntity extends Equatable {
  final String key;
  final String imageUrl;
  final String? keterangan;

  const HistoryFotoEntity({
    required this.key,
    required this.imageUrl,
    this.keterangan,
  });

  @override
  List<Object?> get props => [key, imageUrl, keterangan];
}
