// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cari_nor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CariNorModel _$CariNorModelFromJson(Map<String, dynamic> json) => CariNorModel(
      idNor: json['idNor'] as String,
      idPersil: json['idPersil'] as String,
      nopPbb: json['nopPbb'] as String,
      idJenisBangunan: (json['idJenisBangunan'] as num).toInt(),
      jenisBangunan: json['jenisBangunan'] as String,
      idJalan: (json['idJalan'] as num).toInt(),
      namaJalan: json['namaJalan'] as String,
      noAlamat: json['noAlamat'] as String,
    );
