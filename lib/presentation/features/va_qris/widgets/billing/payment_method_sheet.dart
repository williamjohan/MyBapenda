import 'package:mybapenda/core/utils/currency_formatter.dart';
import 'package:mybapenda/domain/entities/va_qris/payment_method.dart';
import 'package:mybapenda/domain/entities/va_qris/payment_nominal_check_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/theme_kit.dart';
import 'payment_method_option_tile.dart';

/// Bottom sheet pilihan metode. Mengembalikan [PaymentMethod] yang dipilih,
/// atau `null` jika ditutup. Metode yang tidak diizinkan [nominalCheck]
/// tampil nonaktif beserta alasannya.
class PaymentMethodSheet extends StatelessWidget {
  const PaymentMethodSheet({
    super.key,
    required this.total,
    required this.periodCount,
    this.nominalCheck,
  });

  final int total;
  final int periodCount;

  /// null = belum/gagal dicek, semua metode aktif.
  final PaymentNominalCheckEntity? nominalCheck;

  static Future<PaymentMethod?> show(
    BuildContext context, {
    required int total,
    required int periodCount,
    PaymentNominalCheckEntity? nominalCheck,
  }) {
    return showModalBottomSheet<PaymentMethod>(
      context: context,
      backgroundColor: context.palette.surfaceMuted,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PaymentMethodSheet(
        total: total,
        periodCount: periodCount,
        nominalCheck: nominalCheck,
      ),
    );
  }

  bool _isAllowed(PaymentMethod method) =>
      nominalCheck?.isAllowed(method) ?? true;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih metode pembayaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$periodCount masa pajak, total ${CurrencyFormatter.toIdr(total)}',
              style: TextStyle(fontSize: 13, color: palette.textSecondary),
            ),
            const SizedBox(height: 16),
            PaymentMethodOptionTile(
              icon: Icons.qr_code_2_rounded,
              title: 'QRIS',
              description: 'Wajib pajak scan dengan m-banking atau e-wallet.',
              enabled: _isAllowed(PaymentMethod.qris),
              disabledReason: nominalCheck?.messageFor(PaymentMethod.qris),
              onTap: () => Navigator.of(context).pop(PaymentMethod.qris),
            ),
            const SizedBox(height: 10),
            PaymentMethodOptionTile(
              icon: Icons.account_balance_outlined,
              title: 'VA Bank Jatim',
              description: 'Wajib pajak transfer ke nomor Virtual Account.',
              enabled: _isAllowed(PaymentMethod.vaBankJatim),
              disabledReason: nominalCheck?.messageFor(
                PaymentMethod.vaBankJatim,
              ),
              onTap: () => Navigator.of(context).pop(PaymentMethod.vaBankJatim),
            ),
          ],
        ),
      ),
    );
  }
}
