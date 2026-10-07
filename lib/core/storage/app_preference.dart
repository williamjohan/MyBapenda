import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class AppPreferences {
  final SharedPreferences _prefs;

  AppPreferences(this._prefs);

  // KEYS
  static const String _keyIsFirstTime = 'is_first_time';
  static const String _keyUserProfile = 'user_profile_data_json';
  static const String _keyProfilePicturePath = 'profile_picture_local_path';

  // Settings Keys
  static const String _keyIsDarkMode = 'is_dark_mode';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language_code';
  static const String _keyNotification = 'is_notification_on';
  static const String _keyIsRememberMe = 'is_remember_me_checked';

  // =============================================================
  // LOGOUT (Hanya menghapus data non-sensitif)
  // Token akan dihapus terpisah melalui AppSecureStorage
  // =============================================================

  Future<void> clearUserData() async {
    await Future.wait([
      _prefs.remove(_keyUserProfile),
      _prefs.remove(_keyProfilePicturePath),
    ]);
    // Settingan (Dark Mode/Bahasa/Intro) tidak dihapus biar UX bagus
  }

  // =============================================================
  // USER PROFILE CACHE
  // =============================================================

  Future<void> saveUserProfile(String jsonString) async {
    await _prefs.setString(_keyUserProfile, jsonString);
  }

  // Mengambil profil (akan di-decode di Repository)
  String? getUserProfile() {
    return _prefs.getString(_keyUserProfile);
  }

  Future<void> saveProfilePicturePath(String path) async {
    await _prefs.setString(_keyProfilePicturePath, path);
  }

  String? getProfilePicturePath() {
    return _prefs.getString(_keyProfilePicturePath);
  }

  // =============================================================
  // SETTINGS & CONFIG
  // =============================================================

  // ONBOARDING
  bool isFirstTime() => _prefs.getBool(_keyIsFirstTime) ?? true;

  Future<void> setFirstTimeDone() async {
    await _prefs.setBool(_keyIsFirstTime, false);
  }

  // THEME MODE PER PROFIL PENGGUNA ('system' | 'light' | 'dark')
  //
  // Disimpan per NIP (`theme_mode_<nip>`) agar tiap pegawai punya tampilan
  // sendiri di HP yang sama. [userKey] null = belum login (preferensi tamu).
  // Tidak ikut dihapus clearUserData() → pulih saat user yang sama login lagi.

  String getThemeMode({String? userKey}) =>
      _prefs.getString(_themeKeyFor(userKey)) ??
      // User baru: warisi pilihan tamu (mis. diatur sebelum login).
      _prefs.getString(_keyThemeMode) ??
      'system';

  Future<void> setThemeMode(String value, {String? userKey}) async {
    await _prefs.setString(_themeKeyFor(userKey), value);
  }

  static String _themeKeyFor(String? userKey) =>
      (userKey == null || userKey.isEmpty)
      ? _keyThemeMode
      : '${_keyThemeMode}_$userKey';

  bool isDarkMode() => _prefs.getBool(_keyIsDarkMode) ?? false;

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_keyIsDarkMode, value);
  }

  // NOTIFICATION
  bool isNotificationOn() => _prefs.getBool(_keyNotification) ?? true;

  Future<void> setNotification(bool value) async {
    await _prefs.setBool(_keyNotification, value);
  }

  // LANGUAGE
  String getLanguage() => _prefs.getString(_keyLanguage) ?? 'Indonesia';

  Future<void> setLanguage(String value) async {
    await _prefs.setString(_keyLanguage, value);
  }

  // =============================================================
  // UTILITY
  // =============================================================

  /// Hapus SELURUH isi SharedPreferences (Gunakan hanya untuk skenario ekstrem / Force Reset)
  Future<void> clearAllSettings() async {
    await _prefs.clear();
  }

  /// Menyimpan status checkbox "Ingat Saya"
  Future<void> setRememberMe(bool value) async {
    await _prefs.setBool(_keyIsRememberMe, value);
  }

  /// Mengambil status checkbox "Ingat Saya" (Default: false)
  bool isRememberMe() {
    return _prefs.getBool(_keyIsRememberMe) ?? false;
  }
}
