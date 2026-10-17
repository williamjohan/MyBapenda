import 'package:flutter/material.dart';
import '../../../../../core/theme/theme_kit.dart';

class PaymentActionBar extends StatelessWidget {
  const PaymentActionBar({
    super.key,
    required this.shareLabel,
    required this.onShare,
    this.isExpired = false,
  });

  final String shareLabel;
  final VoidCallback onShare;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: isExpired ? null : onShare,
                icon: const Icon(Icons.share_outlined, size: 20),
                label: Text(shareLabel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.accent,
                  side: BorderSide(
                    color: isExpired ? palette.borderStrong : palette.brand,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
