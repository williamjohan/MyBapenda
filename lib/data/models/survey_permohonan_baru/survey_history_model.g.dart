// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurveyHistoryModel _$SurveyHistoryModelFromJson(Map<String, dynamic> json) =>
    SurveyHistoryModel(
      key: json['key'] as String? ?? '',
      noPelayanan: json['noPermohonan'] as String? ?? '-',
      noFormulir: _clean(json['noFormulir']),
      npwpd: json['npwpd'] as String? ?? '-',
      namaPemohon: json['namaPemohon'] as String? ?? '-',
      alamatPemohon: _clean(json['alamatPemohon']),
      tanggalPermohonan: _date(json['tanggalPermohonan']),
      kategori: json['kategoriPenyelenggaraan'] as String? ?? '-',
      jenisProduk: json['jenisProduk'] as String? ?? '-',
      jenisReklame: json['jenisReklame'] as String? ?? '-',
      materi: json['materi'] as String? ?? '-',
      lokPenyelenggaraan: json['lokPenyelenggaraan'] as String? ?? '-',
      statusPermohonan: json['statusPermohonan'] as String? ?? '-',
      statusProses: json['statusProses'] as String? ?? '-',
      jumlahSisi: (json['jumlahSisi'] as num?)?.toInt() ?? 0,
      tglSurvey: _date(json['tglSurvey']),
    );

SurveyHistoryDetailModel _$SurveyHistoryDetailModelFromJson(
        Map<String, dynamic> json) =>
    SurveyHistoryDetailModel(
      key: json['key'] as String? ?? '',
      noPelayanan: json['noPelayanan'] as String? ?? '-',
      noFormulir: _clean(json['noFormulir']),
      npwpd: json['npwpd'] as String? ?? '-',
      katPenyelenggaraan: _clean(json['katPenyelenggaraan']),
      kategoriPenyelenggaraanNama: _clean(json['kategoriPenyelenggaraanNama']),
      statusPermohonan: json['statusPermohonan'] as String? ?? '-',
      statusProses: json['statusProses'] as String? ?? '-',
      jumlahSisi: (json['jumlahSisi'] as num?)?.toInt() ?? 0,
      laporanPdfUrl: _clean(json['laporanPdfUrl']),
      petugas: json['petugas'] == null
          ? null
          : HistoryPetugasModel.fromJson(
              json['petugas'] as Map<String, dynamic>),
      sisiList: (json['sisiList'] as List<dynamic>?)
              ?.map((e) => HistorySisiModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

HistoryPetugasModel _$HistoryPetugasModelFromJson(Map<String, dynamic> json) =>
    HistoryPetugasModel(
      petugasUtama: json['petugasUtama'] == null
          ? null
          : HistoryPegawaiModel.fromJson(
              json['petugasUtama'] as Map<String, dynamic>),
      pembantu: (json['pembantu'] as List<dynamic>?)
              ?.map((e) =>
                  HistoryPegawaiModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      checkin: json['foto'] == null
          ? null
          : HistoryCheckinModel.fromJson(json['foto'] as Map<String, dynamic>),
    );

HistoryPegawaiModel _$HistoryPegawaiModelFromJson(Map<String, dynamic> json) =>
    HistoryPegawaiModel(
      nip: json['nip'] as String? ?? '',
      nama: json['nama'] as String? ?? '-',
    );

HistoryCheckinModel _$HistoryCheckinModelFromJson(Map<String, dynamic> json) =>
    HistoryCheckinModel(
      imageUrl: _clean(json['imageUrl']),
      latitude: _coord(json['latitude']),
      longitude: _coord(json['longitude']),
      alamat: _clean(json['alamat']),
      waktu: _date(json['insDate']),
    );

HistorySisiModel _$HistorySisiModelFromJson(Map<String, dynamic> json) =>
    HistorySisiModel(
      seq: (json['seq'] as num?)?.toInt() ?? 0,
      tglSurvey: _date(json['tglSurvey']),
      petugasNama: _clean(json['insByNama']),
      diinputPada: _date(json['insDate']),
      kecamatan: _clean(json['kecamatan']),
      kelurahan: _clean(json['kelurahan']),
      lokPenyelenggaraan: _clean(json['lokPenyelenggaraan']),
      lokasiTertentu: _clean(json['lokasiTertentu']),
      noImb: _clean(json['noImb']),
      latitude: _coord(json['latitude']),
      longitude: _coord(json['longitude']),
      panjang: (json['panjang'] as num?)?.toDouble(),
      lebar: (json['lebar'] as num?)?.toDouble(),
      tinggi: (json['tinggi'] as num?)?.toDouble(),
      jenisReklame: _clean(json['jenisReklame']),
      jenisProduk: _clean(json['jenisProduk']),
      letakReklame: _clean(json['letakReklame']),
      statusTanah: _clean(json['statusTanah']),
      sudutPandang: _clean(json['sudutPandang']),
      materiReklame: _clean(json['materiReklame']),
      ketSisi: _clean(json['ketSisi']),
      ketSurvey: _clean(json['ketSurvey']),
      fotos: (json['fotos'] as List<dynamic>?)
              ?.map((e) => HistoryFotoModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

HistoryFotoModel _$HistoryFotoModelFromJson(Map<String, dynamic> json) =>
    HistoryFotoModel(
      key: json['key'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      keterangan: _clean(json['keterangan']),
    );
