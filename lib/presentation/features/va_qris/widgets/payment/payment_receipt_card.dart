import 'package:bapendacore/core/utils/app_formatters_utils.dart';
import 'package:bapendacore/core/utils/currency_formatter.dart';
import 'package:bapendacore/core/utils/date_format_id.dart';
import 'package:bapendacore/domain/entities/va_qris/payment_session_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../../../../../core/utils/tax_period_label.dart';

class PaymentReceiptCard extends StatelessWidget {
  const PaymentReceiptCard({super.key, required this.session});

  final PaymentSessionEntity session;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final periodText = session.periods.map((p) => p.label).join(', ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.subtleBorder),
      ),
      child: Column(
        children: [
          _Row(label: 'Wajib pajak', value: session.taxpayerName),
          _Row(label: 'NOP', value: AppFormatters.nop(session.nop)),
          _Row(label: 'Masa pajak', value: periodText),
          _Row(label: 'Metode', value: session.method.label),
          _Row(label: 'Referensi', value: session.reference),
          _Row(
            label: 'Waktu',
            value: '${formatTanggalId(now)}, ${formatJamId(now)}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppThemeColors.subtleBorder),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppThemeColors.secondaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: bold ? 15 : 12.5,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: bold ? AppThemeColors.brown : AppThemeColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
