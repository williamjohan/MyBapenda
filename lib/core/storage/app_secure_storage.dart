import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../utils/app_logger.dart';

@lazySingleton
class AppSecureStorage {
  final FlutterSecureStorage _secureStorage;

  AppSecureStorage(this._secureStorage);

  // =============================================================
  // KEYS DEFINITION
  // =============================================================
  // Keys untuk Session
  static const String _keyAccessToken = 'SECURE_ACCESS_TOKEN';
  static const String _keyRefreshToken = 'SECURE_REFRESH_TOKEN';

  // Keys untuk Remember Me
  static const String _keyRememberNip = 'SECURE_REMEMBER_NIP';
  static const String _keyRememberPassword = 'SECURE_REMEMBER_PASSWORD';

  // Keys ubah password paksa (force change password)
  static const String _keyMustChangePassword = 'SECURE_MUST_CHANGE_PASSWORD';

  // Keys untuk menyimpan data user profile
  static const String _keyCurrentNip = 'SECURE_CURRENT_NIP';
  static const String _keyUserProfile = 'SECURE_USER_PROFILE';

  // =============================================================
  // 1. TOKEN MANAGEMENT (SESSION)
  // =============================================================

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _keyAccessToken);
  }

  /// Menggunakan containsKey untuk performa optimal (benar-benar tidak me-load string)
  Future<bool> hasAccessToken() async {
    return await _secureStorage.containsKey(key: _keyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  Future<void> saveCurrentNip(String nip) async {
    await _secureStorage.write(key: _keyCurrentNip, value: nip);
  }

  Future<String?> getCurrentNip() async {
    return _secureStorage.read(key: _keyCurrentNip);
  }

  Future<void> saveUserProfile(String json) async {
    await _secureStorage.write(key: _keyUserProfile, value: json);
  }

  Future<String?> getUserProfile() async {
    return _secureStorage.read(key: _keyUserProfile);
  }

  Future<void> clearUserProfile() async {
    await _secureStorage.delete(key: _keyUserProfile);
  }

  // =============================================================
  // 2. REMEMBER ME CREDENTIALS
  // =============================================================

  Future<void> saveRememberMeCredentials({
    required String nip,
    required String password,
  }) async {
    await _secureStorage.write(key: _keyRememberNip, value: nip);

    await _secureStorage.write(key: _keyRememberPassword, value: password);
  }

  Future<String?> getRememberMeNip() async {
    return await _secureStorage.read(key: _keyRememberNip);
  }

  Future<String?> getRememberMePassword() async {
    return await _secureStorage.read(key: _keyRememberPassword);
  }

  Future<void> clearRememberMeCredentials() async {
    await _secureStorage.delete(key: _keyRememberNip);
    await _secureStorage.delete(key: _keyRememberPassword);
  }

  // =============================================================
  // 3. MUST CHANGE PASSWORD
  // =============================================================
  Future<void> saveMustChangePassword(bool value) async {
    AppLogger.info(
      '🔍 DEBUG saveMustChangePassword dipanggil dengan value=$value\n${StackTrace.current}',
    );
    if (value) {
      await _secureStorage.write(key: _keyMustChangePassword, value: 'true');
    } else {
      await _secureStorage.delete(key: _keyMustChangePassword);
    }
  }

  Future<bool> getMustChangePassword() async {
    final value = await _secureStorage.read(key: _keyMustChangePassword);
    return value == 'true';
  }

  // =============================================================
  // 3. SECURITY UTILITY
  // =============================================================

  /// Menghapus data Sesi saja (Wajib dipanggil saat Logout).
  /// Menggunakan delete spesifik agar data Remember Me tidak ikut terhapus.
  Future<void> clearSessionData() async {
    await _secureStorage.delete(key: _keyAccessToken);
    await _secureStorage.delete(key: _keyRefreshToken);
    await _secureStorage.delete(key: _keyMustChangePassword);
    await _secureStorage.delete(key: _keyCurrentNip);
    await _secureStorage.delete(key: _keyUserProfile);
  }

  /// Menghapus SELURUH data (Sesi + Kredensial).
  /// Gunakan dengan hati-hati, misalnya saat user ganti device/reset app.
  Future<void> clearAllSecureData() async {
    await _secureStorage.deleteAll();
  }
}
