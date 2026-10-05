import 'package:bapendacore/domain/entities/va_qris/tax_period_entity.dart';
import 'package:flutter/material.dart';

import '../../logic/period_selection_logic.dart';
import '../common/billing_empty_state.dart';
import '../common/va_qris_info_banner.dart';
import 'unpaid_period_tile.dart';

class UnpaidPeriodList extends StatelessWidget {
  const UnpaidPeriodList({
    super.key,
    required this.periods,
    required this.selectedCount,
    required this.onToggle,
  });

  /// Sudah terurut dari masa pajak terlama.
  final List<TaxPeriodEntity> periods;
  final int selectedCount;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    if (periods.isEmpty) {
      return const BillingEmptyState(
        icon: Icons.check_rounded,
        title: 'Tidak ada tagihan',
        message: 'Semua masa pajak wajib pajak ini sudah lunas.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      itemCount: periods.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        if (i == 0) {
          return const VaQrisInfoBanner(
            message:
                'Pembayaran harus berurutan, mulai dari masa pajak terlama.',
          );
        }
        final index = i - 1;
        return UnpaidPeriodTile(
          period: periods[index],
          isSelected: PeriodSelectionLogic.isSelected(index, selectedCount),
          isEnabled: PeriodSelectionLogic.isEnabled(index, selectedCount),
          onTap: () => onToggle(index),
        );
      },
    );
  }
}
