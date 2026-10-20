import 'package:flutter/material.dart';
import '../../../../../core/theme/theme_kit.dart';

enum VaQrisBannerTone { info, warning, danger }

class VaQrisInfoBanner extends StatelessWidget {
  const VaQrisInfoBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.tone = VaQrisBannerTone.info,
  });

  final String message;
  final IconData icon;
  final VaQrisBannerTone tone;

  Color _background(AppPalette palette) => switch (tone) {
    VaQrisBannerTone.info => palette.accentSoft,
    VaQrisBannerTone.warning => palette.warningSoft,
    VaQrisBannerTone.danger => palette.dangerSoft,
  };

  Color _foreground(AppPalette palette) => switch (tone) {
    VaQrisBannerTone.info => palette.brandStrong,
    VaQrisBannerTone.warning => palette.accent,
    VaQrisBannerTone.danger => palette.danger,
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = _foreground(palette);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _background(palette),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12.5, height: 1.4, color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
