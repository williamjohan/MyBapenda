import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../common/va_qris_primary_button.dart';

class PaymentActionBar extends StatelessWidget {
  const PaymentActionBar({
    super.key,
    required this.shareLabel,
    required this.onShare,
    required this.onSimulateSuccess,
    this.isExpired = false,
  });

  final String shareLabel;
  final VoidCallback onShare;
  final VoidCallback onSimulateSuccess;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface,
        border: const Border(top: BorderSide(color: AppThemeColors.subtleBorder)),
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
                  foregroundColor: AppThemeColors.gold,
                  side: BorderSide(
                    color: isExpired
                        ? AppThemeColors.defaultBorder
                        : AppThemeColors.primary,
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
            // TODO(tech-debt): tombol simulasi hanya untuk demo UI. Hapus
            // setelah status pembayaran datang dari backend (polling/push).
            if (kDebugMode) ...[
              const SizedBox(height: 8),
              VaQrisPrimaryButton(
                label: 'Simulasi: pembayaran berhasil',
                icon: Icons.bug_report_outlined,
                onPressed: isExpired ? null : onSimulateSuccess,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
