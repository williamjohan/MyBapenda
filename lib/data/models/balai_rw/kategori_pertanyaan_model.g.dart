// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kategori_pertanyaan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KategoriPertanyaanModel _$KategoriPertanyaanModelFromJson(
        Map<String, dynamic> json) =>
    KategoriPertanyaanModel(
      key: json['key'] as String,
      idKategori: (json['idKategori'] as num).toInt(),
      namaKategori: json['namaKategori'] as String,
      aktif: json['aktif'] as bool,
    );

Map<String, dynamic> _$KategoriPertanyaanModelToJson(
        KategoriPertanyaanModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'idKategori': instance.idKategori,
      'namaKategori': instance.namaKategori,
      'aktif': instance.aktif,
    };
