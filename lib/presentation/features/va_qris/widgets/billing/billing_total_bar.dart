import 'package:mybapenda/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/theme_kit.dart';
import '../common/va_qris_primary_button.dart';

/// Bar tetap di bawah layar: rincian pokok, denda, lainnya, potongan, total,
/// dan tombol konfirmasi.
class BillingTotalBar extends StatelessWidget {
  const BillingTotalBar({
    super.key,
    required this.selectedCount,
    required this.principal,
    required this.penalty,
    required this.onConfirm,
    this.other = 0,
    this.otherLabel,
    this.discount = 0,
    this.isLoading = false,
  });

  final int selectedCount;
  final int principal;
  final int penalty;
  final VoidCallback onConfirm;

  /// Komponen tambahan, mis. jaminan bongkar (Reklame).
  final int other;
  final String? otherLabel;

  /// Potongan (intensifikasi).
  final int discount;
  final bool isLoading;

  int get _total => principal + penalty + other - discount;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedCount > 0;
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
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
                            color: palette.danger,
                          ),
                        ],
                        if (other > 0) ...[
                          const SizedBox(height: 4),
                          _AmountRow(
                            label: otherLabel ?? 'Lainnya',
                            amount: other,
                          ),
                        ],
                        if (discount > 0) ...[
                          const SizedBox(height: 4),
                          _AmountRow(
                            label: 'Potongan',
                            amount: -discount,
                            color: palette.success,
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1, color: palette.border),
                        ),
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
            Row(
              children: [
                Text(
                  'Total bayar',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: palette.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  hasSelection ? CurrencyFormatter.toIdr(_total) : 'Rp0',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: hasSelection
                        ? palette.brandStrong
                        : palette.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            VaQrisPrimaryButton(
              label: 'Konfirmasi pembayaran',
              icon: Icons.check_circle_outline_rounded,
              isLoading: isLoading,
              onPressed: hasSelection ? onConfirm : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.amount, this.color});

  final String label;
  final int amount;

  /// null = warna teks sekunder.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? context.palette.textSecondary;

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
