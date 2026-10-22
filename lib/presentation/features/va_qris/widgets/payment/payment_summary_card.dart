import 'package:mybapenda/core/utils/currency_formatter.dart';
import 'package:mybapenda/domain/entities/va_qris/payment_session_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/theme_kit.dart';

/// Rincian masa pajak yang sedang dibayar (bisa dibuka/ditutup).
class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({super.key, required this.session});

  final PaymentSessionEntity session;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor: palette.accent,
          collapsedIconColor: palette.textTertiary,
          title: Text(
            'Rincian tagihan (${session.periods.length} masa pajak)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
          children: [
            for (final p in session.periods)
              _Line(label: p.label, value: CurrencyFormatter.toIdr(p.total)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: palette.border),
            ),
            _Line(
              label: 'Pokok pajak',
              value: CurrencyFormatter.toIdr(session.principalTotal),
              muted: true,
            ),
            if (session.penaltyTotal > 0)
              _Line(
                label: 'Denda keterlambatan',
                value: CurrencyFormatter.toIdr(session.penaltyTotal),
                color: palette.danger,
              ),
            if (session.otherTotal > 0)
              _Line(
                label: session.periods.first.otherLabel ?? 'Lainnya',
                value: CurrencyFormatter.toIdr(session.otherTotal),
                muted: true,
              ),
            if (session.discountTotal > 0)
              _Line(
                label: 'Potongan',
                value: CurrencyFormatter.toIdr(-session.discountTotal),
                color: palette.success,
              ),
            _Line(
              label: 'Total bayar',
              value: CurrencyFormatter.toIdr(session.total),
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    this.bold = false,
    this.muted = false,
    this.color,
  });

  final String label;
  final String value;
  final bool bold;
  final bool muted;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final resolved =
        color ?? (muted ? palette.textSecondary : palette.textPrimary);
    final weight = bold ? FontWeight.w800 : FontWeight.w500;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: weight,
                color: resolved,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: weight, color: resolved),
          ),
        ],
      ),
    );
  }
}
