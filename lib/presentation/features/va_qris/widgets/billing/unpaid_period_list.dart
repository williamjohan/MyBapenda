import 'package:mybapenda/domain/entities/va_qris/tax_period_entity.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/theme_kit.dart';
import '../common/billing_empty_state.dart';
import 'unpaid_period_tile.dart';

/// Daftar masa belum lunas. Masa bisa dicentang yang mana saja (tidak harus
/// berurutan), plus tombol "Pilih semua" / "Batal semua".
class UnpaidPeriodList extends StatelessWidget {
  const UnpaidPeriodList({
    super.key,
    required this.periods,
    required this.selectedKeys,
    required this.onToggle,
    required this.onToggleAll,
  });

  /// Sudah terurut dari masa pajak terlama.
  final List<TaxPeriodEntity> periods;
  final Set<String> selectedKeys;
  final ValueChanged<TaxPeriodEntity> onToggle;
  final VoidCallback onToggleAll;

  @override
  Widget build(BuildContext context) {
    if (periods.isEmpty) {
      return const BillingEmptyState(
        icon: Icons.check_rounded,
        title: 'Tidak ada tagihan',
        message: 'Semua masa pajak wajib pajak ini sudah lunas.',
      );
    }

    final allSelected = periods.every((p) => selectedKeys.contains(p.key));

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      itemCount: periods.length + 1,
      separatorBuilder: (_, i) => SizedBox(height: i == 0 ? 2 : 10),
      itemBuilder: (context, i) {
        if (i == 0) {
          return _SelectAllHeader(
            selectedCount: periods
                .where((p) => selectedKeys.contains(p.key))
                .length,
            total: periods.length,
            allSelected: allSelected,
            onPressed: onToggleAll,
          );
        }
        final period = periods[i - 1];
        return UnpaidPeriodTile(
          period: period,
          isSelected: selectedKeys.contains(period.key),
          onTap: () => onToggle(period),
        );
      },
    );
  }
}

class _SelectAllHeader extends StatelessWidget {
  const _SelectAllHeader({
    required this.selectedCount,
    required this.total,
    required this.allSelected,
    required this.onPressed,
  });

  final int selectedCount;
  final int total;
  final bool allSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      children: [
        Expanded(
          child: Text(
            '$selectedCount dari $total masa dipilih',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: palette.textSecondary,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: palette.accent,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          icon: Icon(
            allSelected ? Icons.remove_done_rounded : Icons.done_all_rounded,
            size: 18,
          ),
          label: Text(
            allSelected ? 'Batal semua' : 'Pilih semua',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
