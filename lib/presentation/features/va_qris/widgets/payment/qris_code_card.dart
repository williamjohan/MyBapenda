import 'package:mybapenda/domain/entities/va_qris/payment_session_entity.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../../core/theme/theme_kit.dart';
import '../../utils/va_qris_ui_helper.dart';
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
    final palette = context.palette;
    final nmid = VaQrisUiHelper.nmid(session.nmid);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
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
          Text(
            'Scan untuk membayar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gunakan m-banking atau e-wallet yang mendukung QRIS',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: palette.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: _qrSize + 28,
            height: _qrSize + 28,
            child: Stack(
              children: [
                // Latar QR tetap putih di mode gelap agar mudah di-scan.
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: palette.brand, width: 2),
                  ),
                  child: QrImageView(
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
          Text(
            'Bapenda Kota Surabaya',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
          if (nmid != null) ...[
            const SizedBox(height: 2),
            Text(
              'NMID: $nmid',
              style: TextStyle(fontSize: 12, color: palette.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}
