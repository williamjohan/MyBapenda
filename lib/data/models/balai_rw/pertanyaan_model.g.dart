// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pertanyaan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PertanyaanModel _$PertanyaanModelFromJson(Map<String, dynamic> json) =>
    PertanyaanModel(
      key: json['key'] as String,
      idPertanyaan: (json['idPertanyaan'] as num).toInt(),
      idKategori: (json['idKategori'] as num).toInt(),
      namaKategori: json['namaKategori'] as String,
      pertanyaan: json['pertanyaan'] as String,
      tipeJawaban: json['tipeJawaban'] as String,
      seq: (json['seq'] as num).toInt(),
      aktif: json['aktif'] as bool,
    );

Map<String, dynamic> _$PertanyaanModelToJson(PertanyaanModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'idPertanyaan': instance.idPertanyaan,
      'idKategori': instance.idKategori,
      'namaKategori': instance.namaKategori,
      'pertanyaan': instance.pertanyaan,
      'tipeJawaban': instance.tipeJawaban,
      'seq': instance.seq,
      'aktif': instance.aktif,
    };
