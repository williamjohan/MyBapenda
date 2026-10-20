// lib/domain/usecases/profile/profile_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failure.dart';
import '../../entities/profile/foto_profil_entity.dart';
import '../../entities/profile/jenis_kontak.dart';
import '../../entities/profile/kontak_profil_entity.dart';
import '../../repositories/profile/i_profile_repository.dart';

@lazySingleton
class ProfileUseCase {
  final IProfileRepository _repository;

  ProfileUseCase(this._repository);

  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _waRegex = RegExp(r'^08\d{8,12}$');

  static const panjangOtp = 6;

  Future<Either<Failure, FotoProfilEntity>> gantiFoto(String fotoPath) =>
      _repository.gantiFoto(fotoPath);

  Future<Either<Failure, KirimOtpEntity>> kirimOtpKontak({
    required JenisKontak kontak,
    required String tujuan,
  }) => _repository.kirimOtpKontak(kontak: kontak, tujuan: tujuan);

  Future<Either<Failure, KontakProfilEntity>> verifikasiOtpKontak({
    required JenisKontak kontak,
    required String tujuan,
    required String kode,
  }) => _repository.verifikasiOtpKontak(
    kontak: kontak,
    tujuan: tujuan,
    kode: kode,
  );

  /// Tujuan yang dikirim ke API: sama dengan kontak sekarang = kosong
  /// (backend memperlakukannya sebagai verifikasi kontak yang sekarang).
  String tujuanKirim({required String input, required String sekarang}) {
    final v = input.trim();
    return v.toLowerCase() == sekarang.trim().toLowerCase() ? '' : v;
  }

  /// Pesan error format tujuan, atau null bila valid.
  /// `tujuan` kosong boleh: artinya verifikasi kontak yang sekarang.
  String? validasiTujuan(JenisKontak kontak, String tujuan) {
    final v = tujuan.trim();
    if (v.isEmpty) return null;
    return switch (kontak) {
      JenisKontak.email =>
        _emailRegex.hasMatch(v) ? null : 'Format email tidak valid.',
      JenisKontak.whatsapp =>
        _waRegex.hasMatch(v)
            ? null
            : 'No. WhatsApp harus diawali 08 dan berisi 10-14 digit.',
    };
  }

  /// Pesan error kode OTP, atau null bila valid.
  String? validasiKode(String kode) =>
      RegExp(r'^\d+$').hasMatch(kode.trim()) && kode.trim().length == panjangOtp
      ? null
      : 'Kode OTP harus $panjangOtp digit angka.';
}
