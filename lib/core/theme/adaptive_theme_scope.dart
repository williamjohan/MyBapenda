import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_theme_utils.dart';
import 'theme_mode_cubit.dart';

/// Membungkus halaman yang sudah mendukung dark mode.
///
/// Dark mode sengaja tidak dipasang global di MaterialApp: halaman lama masih
/// memakai warna terang hardcoded dan akan rusak (teks terang di kartu putih).
/// Bottom sheet & dialog yang dibuka dari dalam scope ikut memakai tema ini.
class AdaptiveThemeScope extends StatelessWidget {
  final Widget child;

  const AdaptiveThemeScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeModeCubit>().state;
    return Theme(
      data: AppThemeUtils.themeFor(
        mode,
        MediaQuery.platformBrightnessOf(context),
      ),
      child: child,
    );
  }
}
