import 'package:flutter/material.dart';

import '../../../../../core/theme/theme_kit.dart';

/// Panduan langkah pembayaran. Satu-satunya tempat angka berurutan dipakai
/// karena isinya memang urutan langkah.
class PaymentGuideSection extends StatelessWidget {
  const PaymentGuideSection({
    super.key,
    required this.title,
    required this.steps,
  });

  final String title;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor: palette.accent,
          collapsedIconColor: palette.textTertiary,
          leading: Icon(Icons.help_outline_rounded, color: palette.accent),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
          children: [
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: palette.accentSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: palette.brandStrong,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        steps[i],
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
