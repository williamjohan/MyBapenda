import 'package:bapendacore/domain/entities/va_qris/payment_session_entity.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../../core/constants/app_colors_new.dart';
import 'payment_expired_overlay.dart';

class QrisCodeCard extends StatelessWidget {
  const QrisCodeCard({
    super.key,
    required this.session,
    required this.isExpired,
    required this.onRegenerate,
  });

  final PaymentSessionEntity session;
  final bool isExpired;
  final VoidCallback onRegenerate;

  static const double _qrSize = 240;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeColors.subtleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Scan untuk membayar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppThemeColors.titleText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gunakan m-banking atau e-wallet yang mendukung QRIS',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppThemeColors.secondaryText),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: _qrSize + 28,
            height: _qrSize + 28,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppThemeColors.primary,
                      width: 2,
                    ),
                  ),
                  child: QrImageView(
                    // TODO(tech-debt): isi dengan payload QRIS asli dari backend.
                    data: session.qrisPayload ?? 'INVALID',
                    version: QrVersions.auto,
                    size: _qrSize,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ),
                if (isExpired)
                  Positioned.fill(
                    child: PaymentExpiredOverlay(onRegenerate: onRegenerate),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Bapenda Kota Surabaya',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.primaryText,
            ),
          ),
          const SizedBox(height: 2),
          // TODO(tech-debt): nama merchant & NMID dari backend.
          const Text(
            'NMID: dummy',
            style: TextStyle(fontSize: 12, color: AppThemeColors.tertiaryText),
          ),
        ],
      ),
    );
  }
}
