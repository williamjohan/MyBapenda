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

  /// Status proses bisnis (mis. pengiriman surat). `*Soft` untuk latar chip.
  final Color statusSukses;
  final Color statusSuksesSoft;
  final Color statusProses;
  final Color statusProsesSoft;
  final Color statusGagal;
  final Color statusGagalSoft;
  final Color statusBatal;
  final Color statusBatalSoft;

  /// Peringatan tenggat (badge SLA).
  final Color statusWarning;
  final Color statusWarningSoft;

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
    required this.statusSukses,
    required this.statusSuksesSoft,
    required this.statusProses,
    required this.statusProsesSoft,
    required this.statusGagal,
    required this.statusGagalSoft,
    required this.statusBatal,
    required this.statusBatalSoft,
    required this.statusWarning,
    required this.statusWarningSoft,
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
    statusSukses: AppThemeColors.success,
    statusSuksesSoft: AppThemeColors.successSoft,
    statusProses: AppThemeColors.information,
    statusProsesSoft: AppThemeColors.informationSoft,
    statusGagal: AppThemeColors.danger,
    statusGagalSoft: AppThemeColors.dangerSoft,
    statusBatal: Color(0xFF6B7280),
    statusBatalSoft: Color(0xFFEEF0F3),
    statusWarning: Color(0xFFD97706),
    statusWarningSoft: AppThemeColors.warningSoft,
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
    statusSukses: Color(0xFF34D399),
    statusSuksesSoft: Color(0xFF0F2E22),
    statusProses: Color(0xFF38BDC8),
    statusProsesSoft: Color(0xFF0C2A2E),
    statusGagal: Color(0xFFF87171),
    statusGagalSoft: Color(0xFF3A1418),
    statusBatal: Color(0xFF9CA3AF),
    statusBatalSoft: Color(0xFF26282D),
    statusWarning: Color(0xFFFBBF24),
    statusWarningSoft: Color(0xFF33280A),
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
    Color? statusSukses,
    Color? statusSuksesSoft,
    Color? statusProses,
    Color? statusProsesSoft,
    Color? statusGagal,
    Color? statusGagalSoft,
    Color? statusBatal,
    Color? statusBatalSoft,
    Color? statusWarning,
    Color? statusWarningSoft,
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
      statusSukses: statusSukses ?? this.statusSukses,
      statusSuksesSoft: statusSuksesSoft ?? this.statusSuksesSoft,
      statusProses: statusProses ?? this.statusProses,
      statusProsesSoft: statusProsesSoft ?? this.statusProsesSoft,
      statusGagal: statusGagal ?? this.statusGagal,
      statusGagalSoft: statusGagalSoft ?? this.statusGagalSoft,
      statusBatal: statusBatal ?? this.statusBatal,
      statusBatalSoft: statusBatalSoft ?? this.statusBatalSoft,
      statusWarning: statusWarning ?? this.statusWarning,
      statusWarningSoft: statusWarningSoft ?? this.statusWarningSoft,
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
      statusSukses: Color.lerp(statusSukses, other.statusSukses, t)!,
      statusSuksesSoft: Color.lerp(
        statusSuksesSoft,
        other.statusSuksesSoft,
        t,
      )!,
      statusProses: Color.lerp(statusProses, other.statusProses, t)!,
      statusProsesSoft: Color.lerp(
        statusProsesSoft,
        other.statusProsesSoft,
        t,
      )!,
      statusGagal: Color.lerp(statusGagal, other.statusGagal, t)!,
      statusGagalSoft: Color.lerp(statusGagalSoft, other.statusGagalSoft, t)!,
      statusBatal: Color.lerp(statusBatal, other.statusBatal, t)!,
      statusBatalSoft: Color.lerp(statusBatalSoft, other.statusBatalSoft, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusWarningSoft: Color.lerp(
        statusWarningSoft,
        other.statusWarningSoft,
        t,
      )!,
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
