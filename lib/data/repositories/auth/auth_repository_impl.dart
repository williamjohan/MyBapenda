import 'package:bapendacore/core/storage/app_secure_storage.dart';
import 'package:bapendacore/data/datasources/auth/auth_remote_datasource.dart';
import 'package:bapendacore/data/models/auth/auth_model.dart';
import 'package:bapendacore/domain/entities/auth/auth_entity.dart';
import 'package:bapendacore/domain/repositories/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AppSecureStorage _securePreference;

  AuthRepositoryImpl(this._remoteDataSource, this._securePreference);

  @override
  Future<AuthResponseEntity> login({
    required String nip,
    required String password,
  }) async {
    final requestModel = AuthRequestModel(nip: nip, password: password);
    final responseModel = await _remoteDataSource.login(requestModel);

    if (responseModel.token != null && responseModel.token!.isNotEmpty) {
      await _securePreference.saveAccessToken(responseModel.token!);
    }
    await _securePreference.saveMustChangePassword(
      responseModel.isResetPassword,
    );

    return responseModel.toEntity();
  }

  @override
  Future<bool> getCurrentSession() async {
    final token = await _securePreference.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<bool> getMustChangePassword() =>
      _securePreference.getMustChangePassword();

  @override
  Future<void> logout() => _securePreference.clearSessionData();
}
