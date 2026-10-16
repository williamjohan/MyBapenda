import 'package:bapendacore/data/models/profile/profile_model.dart';
import 'package:bapendacore/domain/entities/users/user_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  final String nip;
  final String nama;
  final String alamat;
  final String hp;
  @JsonKey(name: 'email', defaultValue: '')
  final String email;
  @JsonKey(name: 'isValidEmail', defaultValue: false)
  final bool isValidEmail;
  @JsonKey(name: 'isValidWa', defaultValue: false)
  final bool isValidWa;
  final String jenisPegawai;
  final String aktif;
  final String tglLahir;
  final String bidang;
  final String jabatan;
  final String golongan;

  /// null = pegawai belum punya foto profil.
  @JsonKey(name: 'foto')
  final FotoProfilModel? foto;

  const UserModel({
    required this.nip,
    required this.nama,
    required this.alamat,
    required this.hp,
    required this.email,
    this.isValidEmail = false,
    this.isValidWa = false,
    required this.jenisPegawai,
    required this.aktif,
    required this.tglLahir,
    required this.bidang,
    required this.jabatan,
    required this.golongan,
    this.foto,
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
      isValidEmail: isValidEmail,
      isValidWa: isValidWa,
      jenisPegawai: jenisPegawai,
      aktif: aktif,
      tglLahir: tglLahir,
      bidang: bidang,
      jabatan: jabatan,
      golongan: golongan,
      foto: foto?.toEntity(),
    );
  }
}
