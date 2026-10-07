import 'package:flutter/material.dart';

import '../../../core/constants/design_system/tokens/app_palette.dart';

/// Judul section bergaya "MENU LAYANAN" di Home: ikon emas + teks kapital.
class SectionLabel extends StatelessWidget {
  final String text;
  final IconData icon;
  final Widget? trailing;

  const SectionLabel({
    super.key,
    required this.text,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      children: [
        Icon(icon, size: 16, color: palette.accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              height: 1,
              color: palette.textSecondary,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Kartu permukaan standar (gaya kartu menu Home), mengikuti light/dark.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool withPattern;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.withPattern = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: palette.surface,
        image: withPattern
            ? DecorationImage(
                image: const AssetImage('assets/images/pattern_type.png'),
                alignment: Alignment.topCenter,
                fit: BoxFit.fitWidth,
                opacity: palette.patternOpacity,
              )
            : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
        boxShadow: palette.cardShadow,
      ),
      child: child,
    );
  }
}
