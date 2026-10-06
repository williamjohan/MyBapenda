import 'package:bapendacore/domain/entities/my_task/task_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../../utils/task_deadline_label.dart';
import '../../utils/task_type_style.dart';
import '../../../va_qris/widgets/common/va_qris_hero_header.dart';

/// Ringkasan di atas dashboard: jumlah tugas + tugas aktif terdekat.
/// Kotak "Mendesak" menyala putih agar terlihat pertama.
class MyTaskSummaryHeader extends StatelessWidget {
  const MyTaskSummaryHeader({
    super.key,
    required this.isLoading,
    required this.activeCount,
    required this.priorityCount,
    required this.doneCount,
    required this.nearest,
    required this.onOpenNearest,
  });

  final bool isLoading;
  final int activeCount;
  final int priorityCount;
  final int doneCount;
  final TaskEntity? nearest;
  final VoidCallback onOpenNearest;

  String _n(int v) => isLoading ? '-' : '$v';

  @override
  Widget build(BuildContext context) {
    return VaQrisHeroHeader(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _StatTile(value: _n(activeCount), label: 'Aktif')),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  value: _n(priorityCount),
                  label: 'Mendesak',
                  highlight: !isLoading && priorityCount > 0,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(value: _n(doneCount), label: 'Selesai')),
            ],
          ),
          if (nearest != null) ...[
            const SizedBox(height: 12),
            _NearestBanner(task: nearest!, onTap: onOpenNearest),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: highlight ? Colors.white : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: highlight ? AppThemeColors.danger : Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: highlight
                  ? AppThemeColors.secondaryText
                  : Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _NearestBanner extends StatelessWidget {
  const _NearestBanner({required this.task, required this.onTap});

  final TaskEntity task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: task.type.softColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(task.type.icon, size: 19, color: task.type.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tugas terdekat',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppThemeColors.tertiaryText,
                      ),
                    ),
                    Text(
                      '${task.type.shortLabel}  \u2022  ${taskDeadlineLabel(task)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppThemeColors.titleText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppThemeColors.tertiaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
