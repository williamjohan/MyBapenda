import 'package:equatable/equatable.dart';

import '../profile/foto_profil_entity.dart';
import '../profile/jenis_kontak.dart';

class UserEntity extends Equatable {
  final String nip;
  final String nama;
  final String alamat;
  final String hp;
  final String email;
  final bool isValidEmail;
  final bool isValidWa;
  final String jenisPegawai;
  final String aktif;
  final String tglLahir;
  final String bidang;
  final String jabatan;
  final String golongan;

  /// null = pegawai belum punya foto profil.
  final FotoProfilEntity? foto;

  const UserEntity({
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

  UserEntity copyWith({
    String? hp,
    String? email,
    bool? isValidEmail,
    bool? isValidWa,
    FotoProfilEntity? foto,
  }) => UserEntity(
    nip: nip,
    nama: nama,
    alamat: alamat,
    hp: hp ?? this.hp,
    email: email ?? this.email,
    isValidEmail: isValidEmail ?? this.isValidEmail,
    isValidWa: isValidWa ?? this.isValidWa,
    jenisPegawai: jenisPegawai,
    aktif: aktif,
    tglLahir: tglLahir,
    bidang: bidang,
    jabatan: jabatan,
    golongan: golongan,
    foto: foto ?? this.foto,
  );

  /// Nilai kontak sekarang (email / no WA).
  String kontak(JenisKontak jenis) => jenis == JenisKontak.email ? email : hp;

  /// Kontak sudah diverifikasi lewat OTP.
  bool kontakTerverifikasi(JenisKontak jenis) =>
      jenis == JenisKontak.email ? isValidEmail : isValidWa;

  @override
  List<Object?> get props => [
    nip,
    nama,
    alamat,
    hp,
    email,
    isValidEmail,
    isValidWa,
    jenisPegawai,
    aktif,
    tglLahir,
    bidang,
    jabatan,
    golongan,
    foto,
  ];
}
