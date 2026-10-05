import 'package:bapendacore/domain/entities/va_qris/tax_period_entity.dart';
import 'package:flutter/material.dart';

import '../common/billing_empty_state.dart';
import 'paid_period_tile.dart';

class PaidPeriodList extends StatelessWidget {
  const PaidPeriodList({super.key, required this.periods});

  final List<TaxPeriodEntity> periods;

  @override
  Widget build(BuildContext context) {
    if (periods.isEmpty) {
      return const BillingEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Belum ada pembayaran',
        message: 'Belum ada masa pajak yang dibayar pada tahun ini.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      itemCount: periods.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => PaidPeriodTile(period: periods[i]),
    );
  }
}
