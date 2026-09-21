import 'dart:convert';

import 'package:bapendacore/core/storage/app_secure_storage.dart';
import 'package:bapendacore/data/datasources/auth/auth_remote_datasource.dart';
import 'package:bapendacore/data/models/auth/auth_model.dart';
import 'package:bapendacore/data/models/users/user_model.dart';
import 'package:bapendacore/domain/entities/auth/auth_entity.dart';
import 'package:bapendacore/domain/entities/users/user_entity.dart';
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

    if (responseModel.token == null || responseModel.token!.isEmpty) {
      throw Exception('Token login tidak ditemukan');
    }

    await _securePreference.saveAccessToken(responseModel.token!);

    await _securePreference.saveMustChangePassword(
      responseModel.isResetPassword,
    );
    await _securePreference.saveCurrentNip(nip);

    final profileModel = await _remoteDataSource.getProfile(nip: nip);

    await _securePreference.saveUserProfile(jsonEncode(profileModel.toJson()));

    return responseModel.toEntity();
  }

  @override
  Future<UserEntity?> getCurrentUserProfile() async {
    final json = await _securePreference.getUserProfile();

    if (json == null || json.isEmpty) {
      return null;
    }

    final map = jsonDecode(json) as Map<String, dynamic>;

    return UserModel.fromJson(map).toEntity();
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
