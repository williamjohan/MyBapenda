import 'package:bapendacore/domain/entities/va_qris/tax_billing_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/theme_kit.dart';
import '../../utils/va_qris_ui_helper.dart';

/// Ringkasan wajib pajak di header tagihan: nama + nomor referensi menonjol,
/// objek & alamat di kotak inset. Nama kosong dari API tampil "-".
class TaxpayerSummaryCard extends StatelessWidget {
  const TaxpayerSummaryCard({super.key, required this.billing});

  final TaxBillingEntity billing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Wajib pajak',
                  style: TextStyle(fontSize: 12, color: palette.textTertiary),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: palette.accentSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  billing.taxType,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: palette.brandStrong,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            VaQrisUiHelper.teks(billing.taxpayerName),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            VaQrisUiHelper.nomorReferensi(
              billing.referenceLabel,
              billing.referenceNumber,
            ),
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w600,
              color: palette.accent,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              children: [
                _DetailLine(
                  icon: Icons.storefront_outlined,
                  text: billing.objectName,
                ),
                const SizedBox(height: 8),
                _DetailLine(icon: Icons.place_outlined, text: billing.address),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: palette.accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            VaQrisUiHelper.teks(text),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: palette.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
