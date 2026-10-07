// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laporan_pegawai_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LaporanPegawaiModel _$LaporanPegawaiModelFromJson(Map<String, dynamic> json) =>
    LaporanPegawaiModel(
      key: json['key'] as String,
      idLaporan: (json['idLaporan'] as num).toInt(),
      idRoster: (json['idRoster'] as num).toInt(),
      tanggalLaporan: json['tanggalLaporan'] as String,
      insDate: json['insDate'] as String,
      jawaban: (json['jawaban'] as List<dynamic>)
          .map((e) => JawabanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      kehadiran: (json['kehadiran'] as List<dynamic>)
          .map((e) => KehadiranModel.fromJson(e as Map<String, dynamic>))
          .toList(),
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
      'kehadiran': instance.kehadiran.map((e) => e.toJson()).toList(),
    };

JawabanModel _$JawabanModelFromJson(Map<String, dynamic> json) => JawabanModel(
      idPertanyaan: (json['idPertanyaan'] as num).toInt(),
      pertanyaan: json['pertanyaan'] as String,
      jawaban: json['jawaban'] as String?,
    );

Map<String, dynamic> _$JawabanModelToJson(JawabanModel instance) =>
    <String, dynamic>{
      'idPertanyaan': instance.idPertanyaan,
      'pertanyaan': instance.pertanyaan,
      'jawaban': instance.jawaban,
    };

KehadiranModel _$KehadiranModelFromJson(Map<String, dynamic> json) =>
    KehadiranModel(
      key: json['key'] as String,
      jamMasuk: json['jamMasuk'] as String,
      jamPulang: json['jamPulang'] as String?,
      keterangan: json['keterangan'] as String,
      fotoUrl: json['fotoUrl'] as String?,
    );

Map<String, dynamic> _$KehadiranModelToJson(KehadiranModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'jamMasuk': instance.jamMasuk,
      'jamPulang': instance.jamPulang,
      'keterangan': instance.keterangan,
      'fotoUrl': instance.fotoUrl,
    };
