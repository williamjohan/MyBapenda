import 'package:bapendacore/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../common/va_qris_primary_button.dart';

/// Bar tetap di bawah layar: rincian pokok, denda, total, dan tombol
/// konfirmasi.
class BillingTotalBar extends StatelessWidget {
  const BillingTotalBar({
    super.key,
    required this.selectedCount,
    required this.principal,
    required this.penalty,
    required this.onConfirm,
  });

  final int selectedCount;
  final int principal;
  final int penalty;
  final VoidCallback onConfirm;

  int get _total => principal + penalty;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedCount > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface,
        border: const Border(top: BorderSide(color: AppThemeColors.subtleBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: hasSelection
                  ? Column(
                      children: [
                        _AmountRow(
                          label: '$selectedCount masa pajak, pokok',
                          amount: principal,
                        ),
                        if (penalty > 0) ...[
                          const SizedBox(height: 4),
                          _AmountRow(
                            label: 'Denda keterlambatan',
                            amount: penalty,
                            color: AppThemeColors.danger,
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(
                            height: 1,
                            color: AppThemeColors.subtleBorder,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
            Row(
              children: [
                const Text(
                  'Total bayar',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppThemeColors.secondaryText,
                  ),
                ),
                const Spacer(),
                Text(
                  hasSelection ? CurrencyFormatter.toIdr(_total) : 'Rp0',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: hasSelection
                        ? AppThemeColors.brown
                        : AppThemeColors.tertiaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            VaQrisPrimaryButton(
              label: 'Konfirmasi pembayaran',
              icon: Icons.check_circle_outline_rounded,
              onPressed: hasSelection ? onConfirm : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    this.color = AppThemeColors.secondaryText,
  });

  final String label;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 12.5, color: color)),
        ),
        Text(
          CurrencyFormatter.toIdr(amount),
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
