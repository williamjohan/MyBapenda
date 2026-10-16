// lib/data/models/profile/profile_model.dart
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/profile/foto_profil_entity.dart';
import '../../../domain/entities/profile/kontak_profil_entity.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class FotoProfilModel {
  @JsonKey(name: 'fotoUrl', defaultValue: '')
  final String fotoUrl;
  @JsonKey(name: 'namaFile', defaultValue: '')
  final String namaFile;
  @JsonKey(name: 'ukuranFile', defaultValue: '')
  final String ukuranFile;
  @JsonKey(name: 'tipeFile', defaultValue: '')
  final String tipeFile;
  @JsonKey(name: 'contentType', defaultValue: '')
  final String contentType;

  const FotoProfilModel({
    required this.fotoUrl,
    required this.namaFile,
    required this.ukuranFile,
    required this.tipeFile,
    required this.contentType,
  });

  factory FotoProfilModel.fromJson(Map<String, dynamic> json) =>
      _$FotoProfilModelFromJson(json);

  Map<String, dynamic> toJson() => _$FotoProfilModelToJson(this);
}

extension FotoProfilModelX on FotoProfilModel {
  FotoProfilEntity toEntity() => FotoProfilEntity(
    fotoUrl: fotoUrl,
    namaFile: namaFile,
    ukuranFile: ukuranFile,
    tipeFile: tipeFile,
    contentType: contentType,
  );
}

@JsonSerializable()
class KirimOtpKontakRequestModel {
  /// 1 = Email, 2 = WhatsApp.
  @JsonKey(name: 'kontak')
  final int kontak;

  /// Kosong = verifikasi kontak yang sekarang.
  @JsonKey(name: 'tujuan')
  final String tujuan;

  const KirimOtpKontakRequestModel({
    required this.kontak,
    required this.tujuan,
  });

  factory KirimOtpKontakRequestModel.fromJson(Map<String, dynamic> json) =>
      _$KirimOtpKontakRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$KirimOtpKontakRequestModelToJson(this);
}

@JsonSerializable()
class VerifikasiOtpKontakRequestModel {
  @JsonKey(name: 'kontak')
  final int kontak;
  @JsonKey(name: 'tujuan')
  final String tujuan;
  @JsonKey(name: 'kode')
  final String kode;

  const VerifikasiOtpKontakRequestModel({
    required this.kontak,
    required this.tujuan,
    required this.kode,
  });

  factory VerifikasiOtpKontakRequestModel.fromJson(Map<String, dynamic> json) =>
      _$VerifikasiOtpKontakRequestModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$VerifikasiOtpKontakRequestModelToJson(this);
}

@JsonSerializable()
class KirimOtpKontakResponseModel {
  @JsonKey(name: 'sisaBerlakuDetik', defaultValue: 0)
  final int sisaBerlakuDetik;
  @JsonKey(name: 'sisaJedaKirimDetik', defaultValue: 0)
  final int sisaJedaKirimDetik;

  const KirimOtpKontakResponseModel({
    required this.sisaBerlakuDetik,
    required this.sisaJedaKirimDetik,
  });

  factory KirimOtpKontakResponseModel.fromJson(Map<String, dynamic> json) =>
      _$KirimOtpKontakResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$KirimOtpKontakResponseModelToJson(this);
}

extension KirimOtpKontakResponseModelX on KirimOtpKontakResponseModel {
  KirimOtpEntity toEntity() => KirimOtpEntity(
    sisaBerlakuDetik: sisaBerlakuDetik,
    sisaJedaKirimDetik: sisaJedaKirimDetik,
  );
}

@JsonSerializable()
class KontakProfilModel {
  @JsonKey(name: 'hp', defaultValue: '')
  final String hp;
  @JsonKey(name: 'email', defaultValue: '')
  final String email;
  @JsonKey(name: 'isValidEmail', defaultValue: false)
  final bool isValidEmail;
  @JsonKey(name: 'isValidWa', defaultValue: false)
  final bool isValidWa;

  const KontakProfilModel({
    required this.hp,
    required this.email,
    required this.isValidEmail,
    required this.isValidWa,
  });

  factory KontakProfilModel.fromJson(Map<String, dynamic> json) =>
      _$KontakProfilModelFromJson(json);

  Map<String, dynamic> toJson() => _$KontakProfilModelToJson(this);
}

extension KontakProfilModelX on KontakProfilModel {
  KontakProfilEntity toEntity() => KontakProfilEntity(
    hp: hp,
    email: email,
    isValidEmail: isValidEmail,
    isValidWa: isValidWa,
  );
}

/// Payload multipart `ganti-foto` (field `FileDataFormFile`).
class GantiFotoPayloadModel {
  final String fotoPath;

  const GantiFotoPayloadModel({required this.fotoPath});

  Future<FormData> toFormData() async => FormData()
    ..files.add(
      MapEntry(
        'FileDataFormFile',
        await MultipartFile.fromFile(
          fotoPath,
          filename: fotoPath.split(RegExp(r'[/\\]')).last,
        ),
      ),
    );
}
