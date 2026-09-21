import 'package:bapendacore/domain/entities/users/user_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String nip;
  final String nama;
  final String alamat;
  final String hp;
  final String email;
  final String jenisPegawai;
  final String aktif;
  final String tglLahir;
  final String bidang;
  final String jabatan;
  final String golongan;

  const UserModel({
    required this.nip,
    required this.nama,
    required this.alamat,
    required this.hp,
    required this.email,
    required this.jenisPegawai,
    required this.aktif,
    required this.tglLahir,
    required this.bidang,
    required this.jabatan,
    required this.golongan,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

extension UserModelX on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      nip: nip,
      nama: nama,
      alamat: alamat,
      hp: hp,
      email: email,
      jenisPegawai: jenisPegawai,
      aktif: aktif,
      tglLahir: tglLahir,
      bidang: bidang,
      jabatan: jabatan,
      golongan: golongan,
    );
  }
}
