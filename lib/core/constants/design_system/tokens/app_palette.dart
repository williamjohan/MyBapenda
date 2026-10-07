import 'package:flutter/material.dart';

import '../../app_colors_new.dart';

/// Token warna semantik yang mengikuti light/dark mode.
///
/// Dipakai halaman yang sudah mendukung dark mode (Home, Absensi, Laporan)
/// lewat `context.palette`. Halaman lama masih memakai [AppThemeColors]
/// langsung dan selalu terang.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color borderStrong;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Aksen emas (ikon menu, label section).
  final Color accent;
  final Color accentSoft;

  /// Gradient header halaman (oranye/emas).
  final List<Color> headerGradient;

  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;

  final Color shadow;

  /// Opasitas gambar pola di kartu menu.
  final double patternOpacity;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentSoft,
    required this.headerGradient,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.shadow,
    required this.patternOpacity,
  });

  static const AppPalette light = AppPalette(
    background: Color(0xFFF5F6F8),
    surface: AppThemeColors.defaultSurface,
    surfaceMuted: AppThemeColors.defaultBackground,
    border: AppThemeColors.subtleBorder,
    borderStrong: AppThemeColors.defaultBorder,
    textPrimary: AppThemeColors.primaryText,
    textSecondary: AppThemeColors.secondaryText,
    textTertiary: AppThemeColors.tertiaryText,
    accent: AppThemeColors.gold,
    accentSoft: AppThemeColors.primarySoft,
    headerGradient: [Color(0xFFE59C00), Color(0xFFA65A00)],
    success: AppThemeColors.success,
    successSoft: AppThemeColors.successSoft,
    warning: AppThemeColors.warning,
    warningSoft: AppThemeColors.warningSoft,
    danger: AppThemeColors.danger,
    dangerSoft: AppThemeColors.dangerSoft,
    shadow: Color(0x0D000000),
    patternOpacity: 1,
  );

  static const AppPalette dark = AppPalette(
    background: Color(0xFF0F1115),
    surface: Color(0xFF1B1D22),
    surfaceMuted: Color(0xFF15171B),
    border: Color(0xFF2A2D33),
    borderStrong: Color(0xFF3A3E46),
    textPrimary: Color(0xFFF3F4F6),
    textSecondary: Color(0xFFB0B4BC),
    textTertiary: Color(0xFF7C828D),
    accent: Color(0xFFFFB547),
    accentSoft: Color(0xFF3A2A12),
    headerGradient: [Color(0xFFB87A00), Color(0xFF6B3A00)],
    success: Color(0xFF34D399),
    successSoft: Color(0xFF0F2E22),
    warning: Color(0xFFFBBF24),
    warningSoft: Color(0xFF33280A),
    danger: Color(0xFFF87171),
    dangerSoft: Color(0xFF3A1418),
    shadow: Color(0x4D000000),
    patternOpacity: 0.06,
  );

  LinearGradient get headerLinearGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: headerGradient,
  );

  List<BoxShadow> get cardShadow => [
    BoxShadow(color: shadow, blurRadius: 14, offset: const Offset(0, 6)),
  ];

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? accentSoft,
    List<Color>? headerGradient,
    Color? success,
    Color? successSoft,
    Color? warning,
    Color? warningSoft,
    Color? danger,
    Color? dangerSoft,
    Color? shadow,
    double? patternOpacity,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      headerGradient: headerGradient ?? this.headerGradient,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      shadow: shadow ?? this.shadow,
      patternOpacity: patternOpacity ?? this.patternOpacity,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      headerGradient: [
        for (var i = 0; i < headerGradient.length; i++)
          Color.lerp(headerGradient[i], other.headerGradient[i], t)!,
      ],
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      patternOpacity:
          patternOpacity + (other.patternOpacity - patternOpacity) * t,
    );
  }
}

extension AppPaletteX on BuildContext {
  /// Fallback ke [AppPalette.light] bila tema tidak membawa extension.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
