import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../../../../../core/theme/theme_kit.dart';

/// Blok gradient di bawah app bar. Konten utama tiap layar (intro NOP,
/// ringkasan wajib pajak, total bayar) diletakkan di sini.
class VaQrisHeroHeader extends StatelessWidget {
  const VaQrisHeroHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 4, 16, 22),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        // Mode gelap: warna gradient header palette (seperti Home/Absensi),
        // arah tetap atas-bawah agar menyatu dengan VaQrisAppBar.
        gradient: context.isDarkMode
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: context.palette.headerGradient,
              )
            : AppThemeColors.headerGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: child,
    );
  }
}
