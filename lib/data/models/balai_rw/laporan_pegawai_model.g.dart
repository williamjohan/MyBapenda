// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laporan_pegawai_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LaporanPegawaiModel _$LaporanPegawaiModelFromJson(Map<String, dynamic> json) =>
    LaporanPegawaiModel(
      key: json['key'] as String? ?? '',
      idLaporan: (json['idLaporan'] as num?)?.toInt() ?? 0,
      idRoster: (json['idRoster'] as num?)?.toInt() ?? 0,
      tanggalLaporan: json['tanggalLaporan'] as String? ?? '',
      insDate: json['insDate'] as String? ?? '',
      jawaban: (json['jawaban'] as List<dynamic>?)
              ?.map((e) => JawabanModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      checkin: json['checkin'] == null
          ? null
          : AbsenModel.fromJson(json['checkin'] as Map<String, dynamic>),
      checkout: json['checkout'] == null
          ? null
          : AbsenModel.fromJson(json['checkout'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LaporanPegawaiModelToJson(
        LaporanPegawaiModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'idLaporan': instance.idLaporan,
      'idRoster': instance.idRoster,
      'tanggalLaporan': instance.tanggalLaporan,
      'insDate': instance.insDate,
      'jawaban': instance.jawaban.map((e) => e.toJson()).toList(),
      'checkin': instance.checkin?.toJson(),
      'checkout': instance.checkout?.toJson(),
    };

JawabanModel _$JawabanModelFromJson(Map<String, dynamic> json) => JawabanModel(
      idPertanyaan: (json['idPertanyaan'] as num).toInt(),
      pertanyaan: json['pertanyaan'] as String? ?? '',
      jawaban: json['jawaban'] as String?,
    );

Map<String, dynamic> _$JawabanModelToJson(JawabanModel instance) =>
    <String, dynamic>{
      'idPertanyaan': instance.idPertanyaan,
      'pertanyaan': instance.pertanyaan,
      'jawaban': instance.jawaban,
    };

AbsenModel _$AbsenModelFromJson(Map<String, dynamic> json) => AbsenModel(
      key: json['key'] as String? ?? '',
      jam: json['jam'] as String? ?? '',
      keterangan: json['keterangan'] as String?,
      fotoUrl: json['fotoUrl'] as String?,
    );

Map<String, dynamic> _$AbsenModelToJson(AbsenModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'jam': instance.jam,
      'keterangan': instance.keterangan,
      'fotoUrl': instance.fotoUrl,
    };
