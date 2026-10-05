import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';

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

  Color get _background => switch (tone) {
    VaQrisBannerTone.info => AppThemeColors.primarySoft,
    VaQrisBannerTone.warning => AppThemeColors.warningSoft,
    VaQrisBannerTone.danger => AppThemeColors.dangerSoft,
  };

  Color get _foreground => switch (tone) {
    VaQrisBannerTone.info => AppThemeColors.brown,
    VaQrisBannerTone.warning => AppThemeColors.gold,
    VaQrisBannerTone.danger => AppThemeColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: _foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
