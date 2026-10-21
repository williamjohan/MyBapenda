import 'package:mybapenda/core/utils/currency_formatter.dart';
import 'package:mybapenda/domain/entities/va_qris/payment_session_entity.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../core/theme/theme_kit.dart';
import '../../utils/va_qris_ui_helper.dart';

/// Gambar QRIS yang dibagikan ke wajib pajak (dirender di luar layar lalu
/// disimpan jadi PNG). Selalu tema terang berlatar putih agar mudah di-scan
/// dan terbaca di WhatsApp, apa pun tema aplikasi petugas.
class QrisShareCard extends StatelessWidget {
  const QrisShareCard({super.key, required this.session});

  final PaymentSessionEntity session;

  static const double width = 360;

  @override
  Widget build(BuildContext context) {
    const palette = AppPalette.light;
    final nmid = VaQrisUiHelper.nmid(session.nmid);

    return Container(
      width: width,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bapenda Kota Surabaya',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Pembayaran Pajak Daerah via QRIS',
            style: TextStyle(fontSize: 12.5, color: palette.textSecondary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.brand, width: 2),
            ),
            child: QrImageView(
              data: session.qrisPayload ?? '',
              version: QrVersions.auto,
              size: 240,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
          ),
          if (nmid != null) ...[
            const SizedBox(height: 8),
            Text(
              'NMID: $nmid',
              style: TextStyle(fontSize: 12, color: palette.textTertiary),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row(
                  label: 'Wajib pajak',
                  value: VaQrisUiHelper.teks(session.taxpayerName),
                ),
                _Row(
                  label: session.referenceLabel,
                  value: session.referenceNumber,
                ),
                if (session.periods.isNotEmpty)
                  _Row(
                    label: 'Masa pajak',
                    value: VaQrisUiHelper.daftarMasa(session),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Total bayar',
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nominal besar mengecil, tidak meluber
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          CurrencyFormatter.toIdr(session.total),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: palette.brandStrong,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Berlaku sampai '
            '${VaQrisUiHelper.batasWaktu(session.expiresAt)}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: palette.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    const palette = AppPalette.light;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TextStyle(fontSize: 12.5, color: palette.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
