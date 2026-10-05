import 'package:bapendacore/core/utils/currency_formatter.dart';
import 'package:bapendacore/domain/entities/va_qris/payment_method.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import 'payment_method_option_tile.dart';

/// Bottom sheet pilihan metode. Mengembalikan [PaymentMethod] yang dipilih,
/// atau `null` jika ditutup.
class PaymentMethodSheet extends StatelessWidget {
  const PaymentMethodSheet({
    super.key,
    required this.total,
    required this.periodCount,
  });

  final int total;
  final int periodCount;

  static Future<PaymentMethod?> show(
    BuildContext context, {
    required int total,
    required int periodCount,
  }) {
    return showModalBottomSheet<PaymentMethod>(
      context: context,
      backgroundColor: AppThemeColors.defaultBackground,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PaymentMethodSheet(total: total, periodCount: periodCount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih metode pembayaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppThemeColors.titleText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$periodCount masa pajak, total ${CurrencyFormatter.toIdr(total)}',
              style: const TextStyle(
                fontSize: 13,
                color: AppThemeColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            PaymentMethodOptionTile(
              icon: Icons.qr_code_2_rounded,
              title: 'QRIS',
              description: 'Wajib pajak scan dengan m-banking atau e-wallet.',
              onTap: () => Navigator.of(context).pop(PaymentMethod.qris),
            ),
            const SizedBox(height: 10),
            PaymentMethodOptionTile(
              icon: Icons.account_balance_outlined,
              title: 'VA Bank Jatim',
              description: 'Wajib pajak transfer ke nomor Virtual Account.',
              onTap: () =>
                  Navigator.of(context).pop(PaymentMethod.vaBankJatim),
            ),
          ],
        ),
      ),
    );
  }
}
