import 'package:bapendacore/core/utils/currency_formatter.dart';
import 'package:bapendacore/core/utils/date_format_id.dart';
import 'package:bapendacore/domain/entities/va_qris/tax_period_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/theme_kit.dart';

class PaidPeriodTile extends StatelessWidget {
  const PaidPeriodTile({super.key, required this.period});

  final TaxPeriodEntity period;

  @override
  Widget build(BuildContext context) {
    final paidAt = period.paidAt;
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: palette.successSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, size: 20, color: palette.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period.label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                ),
                if (paidAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Dibayar ${formatTanggalId(paidAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.toIdr(period.total),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Lunas',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: palette.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
