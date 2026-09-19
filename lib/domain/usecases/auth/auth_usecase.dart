import 'package:bapendacore/domain/entities/auth/auth_entity.dart';
import 'package:bapendacore/domain/repositories/auth/auth_repository.dart';
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
}
