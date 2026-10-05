import 'package:bapendacore/core/utils/currency_formatter.dart';
import 'package:bapendacore/core/utils/date_format_id.dart';
import 'package:bapendacore/domain/entities/va_qris/tax_period_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../../../../../core/utils/tax_period_label.dart';

class PaidPeriodTile extends StatelessWidget {
  const PaidPeriodTile({super.key, required this.period});

  final TaxPeriodEntity period;

  @override
  Widget build(BuildContext context) {
    final paidAt = period.paidAt;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeColors.subtleBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppThemeColors.successSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 20,
              color: AppThemeColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period.label,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.titleText,
                  ),
                ),
                if (paidAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Dibayar ${formatTanggalId(paidAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppThemeColors.secondaryText,
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppThemeColors.primaryText,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Lunas',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppThemeColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
