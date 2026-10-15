// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      nip: json['nip'] as String,
      nama: json['nama'] as String,
      alamat: json['alamat'] as String,
      hp: json['hp'] as String,
      email: json['email'] as String,
      jenisPegawai: json['jenisPegawai'] as String,
      aktif: json['aktif'] as String,
      tglLahir: json['tglLahir'] as String,
      bidang: json['bidang'] as String,
      jabatan: json['jabatan'] as String,
      golongan: json['golongan'] as String,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'nip': instance.nip,
      'nama': instance.nama,
      'alamat': instance.alamat,
      'hp': instance.hp,
      'email': instance.email,
      'jenisPegawai': instance.jenisPegawai,
      'aktif': instance.aktif,
      'tglLahir': instance.tglLahir,
      'bidang': instance.bidang,
      'jabatan': instance.jabatan,
      'golongan': instance.golongan,
    };
