import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../shared/widgets/section_label.dart';

/// Kartu pilih tahun (panah kiri/kanan) + grid 12 bulan.
/// Bulan setelah bulan berjalan tidak bisa dipilih.
class PeriodePickerCard extends StatelessWidget {
  final int tahun;
  final int bulan;
  final DateTime now;
  final int minTahun;
  final bool enabled;
  final void Function(int tahun, int bulan) onChanged;

  const PeriodePickerCard({
    super.key,
    required this.tahun,
    required this.bulan,
    required this.now,
    required this.minTahun,
    required this.onChanged,
    this.enabled = true,
  });

  bool _isFuture(int t, int b) =>
      t > now.year || (t == now.year && b > now.month);

  void _gantiTahun(int delta) {
    final next = tahun + delta;
    // Bila bulan terpilih jadi "masa depan" di tahun baru, mundur ke bulan berjalan.
    onChanged(next, _isFuture(next, bulan) ? now.month : bulan);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SurfaceCard(
      withPattern: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel(
            text: 'Pilih Periode',
            icon: Icons.calendar_month_rounded,
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              children: [
                _YearArrow(
                  icon: Icons.chevron_left_rounded,
                  tooltip: 'Tahun sebelumnya',
                  onTap: enabled && tahun > minTahun
                      ? () => _gantiTahun(-1)
                      : null,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Tahun',
                        style: TextStyle(
                          color: palette.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '$tahun',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _YearArrow(
                  icon: Icons.chevron_right_rounded,
                  tooltip: 'Tahun berikutnya',
                  onTap: enabled && tahun < now.year
                      ? () => _gantiTahun(1)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              for (var b = 1; b <= 12; b++)
                _MonthChip(
                  label: DateFormat('MMMM', 'id_ID').format(DateTime(2000, b)),
                  selected: b == bulan,
                  isCurrent: tahun == now.year && b == now.month,
                  enabled: enabled && !_isFuture(tahun, b),
                  onTap: () => onChanged(tahun, b),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _YearArrow extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _YearArrow({required this.icon, required this.tooltip, this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon, size: 28),
      color: palette.accent,
      disabledColor: palette.borderStrong,
    );
  }
}

class _MonthChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isCurrent;
  final bool enabled;
  final VoidCallback onTap;

  const _MonthChip({
    required this.label,
    required this.selected,
    required this.isCurrent,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final Color fg = selected
        ? Colors.white
        : enabled
        ? palette.textPrimary
        : palette.textTertiary.withValues(alpha: 0.5);

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? onTap : null,
          child: Ink(
            decoration: BoxDecoration(
              gradient: selected ? palette.headerLinearGradient : null,
              color: selected ? null : palette.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? Colors.transparent
                    : isCurrent
                    ? palette.accent
                    : palette.border,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isCurrent && !selected)
                  Positioned(
                    top: 6,
                    right: 8,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: palette.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
