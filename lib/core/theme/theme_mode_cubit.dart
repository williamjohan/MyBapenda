import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../storage/app_preference.dart';
import '../storage/app_secure_storage.dart';

/// Sumber kebenaran mode tampilan (Sistem / Terang / Gelap).
///
/// Disimpan ke [AppPreferences] per profil pengguna (NIP dari
/// [AppSecureStorage]). Panggil [syncWithCurrentUser] setiap status login
/// berubah — sudah dilakukan otomatis di `main.dart`.
///
/// Modul lain sebaiknya memakai `AppThemeUtils` / `context.isDarkMode`
/// (lihat `core/theme/theme_kit.dart`) daripada membaca cubit ini langsung.
@lazySingleton
class ThemeModeCubit extends Cubit<ThemeMode> {
  final AppPreferences _preferences;
  final AppSecureStorage _secureStorage;

  /// NIP pemilik preferensi aktif, null = tamu (belum login).
  String? _userKey;

  ThemeModeCubit(this._preferences, this._secureStorage)
    : super(decode(_preferences.getThemeMode()));

  String? get userKey => _userKey;

  /// Muat preferensi milik user yang sedang login (atau tamu bila logout).
  Future<void> syncWithCurrentUser() async {
    _userKey = await _secureStorage.getCurrentNip();
    if (isClosed) return;
    emit(decode(_preferences.getThemeMode(userKey: _userKey)));
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await _preferences.setThemeMode(mode.name, userKey: _userKey);
  }

  static ThemeMode decode(String value) => ThemeMode.values.firstWhere(
    (m) => m.name == value,
    orElse: () => ThemeMode.system,
  );
}
