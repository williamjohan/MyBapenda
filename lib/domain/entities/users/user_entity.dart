import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
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

  const UserEntity({
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

  @override
  List<Object?> get props => [
    nip,
    nama,
    alamat,
    hp,
    email,
    jenisPegawai,
    aktif,
    tglLahir,
    bidang,
    jabatan,
    golongan,
  ];
}
