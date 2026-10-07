import 'package:bapendacore/core/constants/app_colors_new.dart';
import 'package:bapendacore/core/constants/design_system/tokens/app_palette.dart';
import 'package:bapendacore/core/constants/design_system/tokens/app_radius.dart';
import 'package:bapendacore/core/constants/design_system/tokens/app_spacing.dart';
import 'package:bapendacore/core/constants/design_system/tokens/app_typography.dart';
import 'package:flutter/material.dart';

/// Main App Theme
class AppTheme {
  AppTheme._();

  // ==========================================================
  // Tema aktif aplikasi (dipakai MaterialApp & AdaptiveThemeScope)
  //
  // Sengaja sama dengan konfigurasi lama di main.dart agar halaman yang
  // belum mendukung dark mode tidak berubah tampilannya.
  // ==========================================================

  static final ThemeData app = _build(Brightness.light, AppPalette.light);

  static final ThemeData appDark = _build(Brightness.dark, AppPalette.dark);

  static ThemeData _build(Brightness brightness, AppPalette palette) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppThemeColors.primary,
        brightness: brightness,
        surface: palette.surface,
      ),
      scaffoldBackgroundColor: palette.background,
      dividerColor: palette.border,
      extensions: [palette],
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppThemeColors.primary,
      scaffoldBackgroundColor: AppThemeColors.defaultBackground,
      colorScheme: const ColorScheme.light(
        primary: AppThemeColors.primary,
        primaryContainer: AppThemeColors.yellow,
        secondary: AppThemeColors.secondary,
        secondaryContainer: AppThemeColors.secondaryLight,
        surface: AppThemeColors.defaultSurface,
        error: AppThemeColors.danger,
        onPrimary: Colors.white,
        onSecondary: AppThemeColors.primaryText,
        onSurface: AppThemeColors.primaryText,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppThemeColors.primary,
        foregroundColor: Colors.white,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppThemeColors.primary,
        unselectedItemColor: AppThemeColors.secondaryText,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(
          color: AppThemeColors.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
        color: AppThemeColors.defaultSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppThemeColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
          textStyle: AppTypography.labelLarge.copyWith(
            color: AppThemeColors.textOnPrimary,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppThemeColors.primary,
          side: const BorderSide(color: AppThemeColors.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
          textStyle: AppTypography.labelLarge.copyWith(
            color: AppThemeColors.primary,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppThemeColors.primary,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppThemeColors.defaultBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppThemeColors.defaultBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppThemeColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppThemeColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppThemeColors.danger, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppThemeColors.secondaryText,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppThemeColors.tertiaryText,
        ),
        prefixIconColor: AppThemeColors.secondaryText,
        suffixIconColor: AppThemeColors.secondaryText,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppThemeColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppThemeColors.primarySoft,
        selectedColor: AppThemeColors.primary,
        labelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.fullRadius),
      ),
      dividerTheme: const DividerThemeData(
        color: AppThemeColors.subtleBorder,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppThemeColors.primaryText,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smRadius),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
