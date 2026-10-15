import 'package:bapendacore/domain/entities/users/user_entity.dart';
import 'package:dartz/dartz.dart';

import '../../../core/errors/failure.dart';
import '../../entities/auth/auth_entity.dart';
import '../../entities/auth/lupa_password_metode.dart';

abstract class AuthRepository {
  Future<AuthResponseEntity> login({
    required String nip,
    required String password,
  });
  Future<void> logout();
  Future<bool> getCurrentSession();
  Future<bool> getMustChangePassword();
  Future<UserEntity?> getCurrentUserProfile();

  /// Ambil profil terbaru dari server lalu perbarui cache lokal.
  Future<Either<Failure, UserEntity>> getProfile();
  Future<Either<Failure, bool>> lupaPassword({
    required String nip,
    required LupaPasswordMetode metode,
    required String tujuan,
  });
  Future<Either<Failure, bool>> resetPassword({
    required String newPassword,
    required String confirmationPassword,
  });
}
