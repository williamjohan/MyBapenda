import 'package:bapendacore/core/utils/currency_formatter.dart';
import 'package:bapendacore/core/utils/date_format_id.dart';
import 'package:bapendacore/domain/entities/va_qris/tax_period_entity.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors_new.dart';
import '../../../../../core/utils/tax_period_label.dart';

/// Satu baris masa pajak yang belum dibayar. Jika ada denda, tampil sebagai
/// segmen terpisah (warna merah lembut) di bawah baris pokok pajak.
class UnpaidPeriodTile extends StatelessWidget {
  const UnpaidPeriodTile({
    super.key,
    required this.period,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  final TaxPeriodEntity period;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1 : 0.6,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppThemeColors.primary
                : AppThemeColors.defaultBorder,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.5),
          child: Material(
            color: isSelected
                ? AppThemeColors.primarySoft
                : AppThemeColors.defaultSurface,
            child: InkWell(
              onTap: isEnabled ? onTap : null,
              child: Column(
                children: [
                  _MainRow(
                    period: period,
                    isSelected: isSelected,
                    isEnabled: isEnabled,
                    onTap: onTap,
                  ),
                  if (period.hasPenalty) _PenaltySegment(period: period),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MainRow extends StatelessWidget {
  const _MainRow({
    required this.period,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  final TaxPeriodEntity period;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 14, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: isSelected,
            onChanged: isEnabled ? (_) => onTap() : null,
            activeColor: AppThemeColors.primary,
            side: const BorderSide(color: AppThemeColors.tertiaryText, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        period.label,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppThemeColors.titleText,
                        ),
                      ),
                      _StatusChip(period: period),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Jatuh tempo ${formatTanggalId(period.dueDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppThemeColors.secondaryText,
                    ),
                  ),
                  if (!isEnabled) ...[
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 13,
                          color: AppThemeColors.tertiaryText,
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Lunasi masa pajak sebelumnya dulu',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppThemeColors.tertiaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Pokok pajak',
                  style: TextStyle(fontSize: 11, color: AppThemeColors.tertiaryText),
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.toIdr(period.principal),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PenaltySegment extends StatelessWidget {
  const _PenaltySegment({required this.period});

  final TaxPeriodEntity period;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppThemeColors.dangerSoft,
        border: Border(
          top: BorderSide(
            color: AppThemeColors.danger.withValues(alpha: 0.18),
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: AppThemeColors.danger,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Denda keterlambatan ${period.lateMonths} bulan',
              style: const TextStyle(
                fontSize: 12.5,
                color: AppThemeColors.danger,
              ),
            ),
          ),
          Text(
            CurrencyFormatter.toIdr(period.penalty),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.period});

  final TaxPeriodEntity period;

  @override
  Widget build(BuildContext context) {
    final late = period.lateMonths > 0;
    final background =
        late ? AppThemeColors.dangerSoft : AppThemeColors.warningSoft;
    final foreground = late ? AppThemeColors.danger : AppThemeColors.gold;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        late ? 'Terlambat ${period.lateMonths} bln' : 'Bulan ini',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
