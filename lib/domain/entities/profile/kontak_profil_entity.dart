// lib/domain/entities/profile/kontak_profil_entity.dart
import 'package:equatable/equatable.dart';

/// Kontak pegawai terbaru setelah OTP terverifikasi.
class KontakProfilEntity extends Equatable {
  final String hp;
  final String email;
  final bool isValidEmail;
  final bool isValidWa;

  const KontakProfilEntity({
    required this.hp,
    required this.email,
    required this.isValidEmail,
    required this.isValidWa,
  });

  @override
  List<Object?> get props => [hp, email, isValidEmail, isValidWa];
}

/// Hasil kirim OTP: masa berlaku kode & jeda sebelum boleh kirim ulang.
class KirimOtpEntity extends Equatable {
  final int sisaBerlakuDetik;
  final int sisaJedaKirimDetik;

  const KirimOtpEntity({
    required this.sisaBerlakuDetik,
    required this.sisaJedaKirimDetik,
  });

  @override
  List<Object?> get props => [sisaBerlakuDetik, sisaJedaKirimDetik];
}
