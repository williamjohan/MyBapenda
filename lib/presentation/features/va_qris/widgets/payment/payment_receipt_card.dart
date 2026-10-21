import 'package:mybapenda/core/utils/currency_formatter.dart';
import 'package:mybapenda/core/utils/date_format_id.dart';
import 'package:mybapenda/domain/entities/va_qris/payment_session_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/theme_kit.dart';
import '../../utils/va_qris_ui_helper.dart';

class PaymentReceiptCard extends StatelessWidget {
  const PaymentReceiptCard({super.key, required this.session});

  final PaymentSessionEntity session;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final periodText = session.periods.map((p) => p.label).join(', ');
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          _Row(
            label: 'Wajib pajak',
            value: VaQrisUiHelper.teks(session.taxpayerName),
          ),
          _Row(label: session.referenceLabel, value: session.referenceNumber),
          _Row(label: 'Masa pajak', value: periodText),
          _Row(label: 'Metode', value: session.method.label),
          _Row(label: 'Referensi', value: session.reference),
          _Row(
            label: 'Waktu',
            value: '${formatTanggalId(now)}, ${formatJamId(now)}',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: palette.border),
          ),
          _Row(
            label: 'Total dibayar',
            value: CurrencyFormatter.toIdr(session.total),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: TextStyle(fontSize: 12.5, color: palette.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: bold ? 15 : 12.5,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: bold ? palette.brandStrong : palette.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
