import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_history/survey_history_list_state.dart';
import 'package:flutter/material.dart';
import 'history_format.dart';

class HistoryFilterBar extends StatelessWidget {
  final HistoryRangePreset selected;
  final DateTimeRange range;
  final ValueChanged<HistoryRangePreset> onPreset;
  final VoidCallback onPickCustom;

  const HistoryFilterBar({
    super.key,
    required this.selected,
    required this.range,
    required this.onPreset,
    required this.onPickCustom,
  });

  @override
  Widget build(BuildContext context) {
    final custom = selected == HistoryRangePreset.custom;

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        children: [
          _Chip(
            label: '7 Hari',
            active: selected == HistoryRangePreset.days7,
            onTap: () => onPreset(HistoryRangePreset.days7),
          ),
          _Chip(
            label: '30 Hari',
            active: selected == HistoryRangePreset.days30,
            onTap: () => onPreset(HistoryRangePreset.days30),
          ),
          _Chip(
            label: 'Bulan Ini',
            active: selected == HistoryRangePreset.thisMonth,
            onTap: () => onPreset(HistoryRangePreset.thisMonth),
          ),
          _Chip(
            icon: Icons.calendar_month_outlined,
            label: custom ? HistoryFmt.range(range) : 'Pilih Tanggal',
            active: custom,
            onTap: onPickCustom,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFB8680F);
    final fg = active ? accent : const Color(0xFF52606D);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFFF4E5) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active
                  ? accent.withValues(alpha: 0.45)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
