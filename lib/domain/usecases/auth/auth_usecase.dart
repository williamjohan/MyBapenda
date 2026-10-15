import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/domain/entities/auth/auth_entity.dart';
import 'package:bapendacore/domain/entities/auth/lupa_password_metode.dart';
import 'package:bapendacore/domain/entities/users/user_entity.dart';
import 'package:bapendacore/domain/repositories/auth/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthUseCase {
  final AuthRepository repository;
  AuthUseCase(this.repository);

  Future<AuthResponseEntity> login({
    required String nip,
    required String password,
  }) {
    return repository.login(nip: nip, password: password);
  }

  Future<void> logout() => repository.logout();
  Future<bool> getCurrentSession() => repository.getCurrentSession();
  Future<bool> getMustChangePassword() => repository.getMustChangePassword();

  Future<UserEntity?> getCurrentUserProfile() =>
      repository.getCurrentUserProfile();

  Future<Either<Failure, UserEntity>> getProfile() => repository.getProfile();

  Future<Either<Failure, bool>> lupaPassword({
    required String nip,
    required LupaPasswordMetode metode,
    required String tujuan,
  }) => repository.lupaPassword(nip: nip, metode: metode, tujuan: tujuan);

  Future<Either<Failure, bool>> resetPassword({
    required String newPassword,
    required String confirmationPassword,
  }) => repository.resetPassword(
    newPassword: newPassword,
    confirmationPassword: confirmationPassword,
  );
}
