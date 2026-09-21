import 'package:bapendacore/domain/entities/users/user_entity.dart';

import '../../entities/auth/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthResponseEntity> login({
    required String nip,
    required String password,
  });
  Future<void> logout();
  Future<bool> getCurrentSession();
  Future<bool> getMustChangePassword();
  Future<UserEntity?> getCurrentUserProfile();
}
