import 'package:bapendacore/core/constants/app_colors_new.dart';
import 'package:flutter/material.dart';
/// Design System Shadows
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get small => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get large => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get oranges => [
    BoxShadow(
      color: AppThemeColors.primary.withValues(alpha: 0.8),
      blurRadius: 5,
      offset: const Offset(0, 0),
    ),
  ];

  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get loginCard => [
    BoxShadow(
      color: AppThemeColors.blackPrimary.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get searchMapCard => [
    BoxShadow(
      color: AppThemeColors.blackPrimary.withValues(alpha: 0.01),
      blurRadius: 10,
      offset: const Offset(0, 8),
    ),
  ];
}
