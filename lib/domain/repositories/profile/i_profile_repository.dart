// lib/domain/repositories/profile/i_profile_repository.dart
import 'package:dartz/dartz.dart';

import '../../../core/errors/failure.dart';
import '../../entities/profile/foto_profil_entity.dart';
import '../../entities/profile/jenis_kontak.dart';
import '../../entities/profile/kontak_profil_entity.dart';

abstract class IProfileRepository {
  /// Unggah foto profil baru (JPG/PNG, maks 2 MB).
  Future<Either<Failure, FotoProfilEntity>> gantiFoto(String fotoPath);

  /// Kirim / kirim ulang OTP. `tujuan` kosong = verifikasi kontak sekarang.
  Future<Either<Failure, KirimOtpEntity>> kirimOtpKontak({
    required JenisKontak kontak,
    required String tujuan,
  });

  /// Verifikasi OTP; `kontak` & `tujuan` harus sama dengan saat kirim OTP.
  Future<Either<Failure, KontakProfilEntity>> verifikasiOtpKontak({
    required JenisKontak kontak,
    required String tujuan,
    required String kode,
  });
}
