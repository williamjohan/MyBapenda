import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';

/// Penutup QR/VA saat waktu pembayaran habis.
class PaymentExpiredOverlay extends StatelessWidget {
  const PaymentExpiredOverlay({super.key, required this.onRegenerate});

  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer_off_outlined,
            size: 40,
            color: AppThemeColors.danger,
          ),
          const SizedBox(height: 10),
          const Text(
            'Waktu pembayaran habis',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.titleText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Buat ulang agar wajib pajak bisa membayar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppThemeColors.secondaryText),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRegenerate,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Buat ulang'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppThemeColors.gold,
              side: const BorderSide(color: AppThemeColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
