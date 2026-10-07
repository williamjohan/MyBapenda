import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/design_system/tokens/app_theme.dart';
import 'theme_mode_cubit.dart';

/// Util tema light/dark yang bisa dipakai modul mana pun.
///
/// Preferensi tersimpan per profil pengguna di AppPreferences (lihat
/// [ThemeModeCubit]). Contoh pemakaian di modul baru:
///
/// ```dart
/// import 'package:bapendacore/core/theme/theme_kit.dart';
///
/// // 1. Bungkus halaman di route agar ikut light/dark:
/// builder: (_, __) => const AdaptiveThemeScope(child: MyPage()),
///
/// // 2. Pakai warna semantik di widget:
/// color: context.palette.surface,
/// if (context.isDarkMode) ...
///
/// // 3. Ubah mode:
/// context.toggleThemeMode();
/// AppThemeUtils.setMode(context, ThemeMode.system);
/// ```
class AppThemeUtils {
  const AppThemeUtils._();

  /// Mode yang dipilih user (bisa [ThemeMode.system]).
  static ThemeMode modeOf(BuildContext context, {bool listen = true}) => listen
      ? context.watch<ThemeModeCubit>().state
      : context.read<ThemeModeCubit>().state;

  /// true bila tema yang sedang aktif di [context] gelap.
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Terjemahkan mode → gelap/terang (system mengikuti kecerahan HP).
  static bool resolveIsDark(ThemeMode mode, Brightness platformBrightness) =>
      switch (mode) {
        ThemeMode.dark => true,
        ThemeMode.light => false,
        ThemeMode.system => platformBrightness == Brightness.dark,
      };

  /// ThemeData aplikasi untuk mode tertentu.
  static ThemeData themeFor(ThemeMode mode, Brightness platformBrightness) =>
      resolveIsDark(mode, platformBrightness) ? AppTheme.appDark : AppTheme.app;

  /// Simpan mode ke profil pengguna aktif.
  static Future<void> setMode(BuildContext context, ThemeMode mode) =>
      context.read<ThemeModeCubit>().setMode(mode);

  /// Balik terang ↔ gelap berdasarkan tema yang sedang tampil.
  static Future<void> toggle(BuildContext context) =>
      setMode(context, isDark(context) ? ThemeMode.light : ThemeMode.dark);
}

/// Pintasan [AppThemeUtils] dari BuildContext.
/// Warna semantik tersedia lewat `context.palette` (app_palette.dart).
extension AppThemeContextX on BuildContext {
  bool get isDarkMode => AppThemeUtils.isDark(this);

  ThemeMode get themeMode => AppThemeUtils.modeOf(this);

  Future<void> setThemeMode(ThemeMode mode) =>
      AppThemeUtils.setMode(this, mode);

  Future<void> toggleThemeMode() => AppThemeUtils.toggle(this);
}
