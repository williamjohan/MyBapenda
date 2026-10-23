import 'package:mybapenda/domain/entities/my_task/my_task_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../../logic/task_priority_logic.dart';

class TaskStatusChip extends StatelessWidget {
  const TaskStatusChip({super.key, required this.task}); 

  final MyTaskEntity task;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = _style();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }

  (String, Color, Color) _style() {
    switch (task.statusType) {
      case MyTaskStatus.selesai:
        return ('Selesai', AppThemeColors.successSoft, AppThemeColors.success);
      case MyTaskStatus.terlewat:
        return ('Terlewat', AppThemeColors.dangerSoft, AppThemeColors.danger);
      case MyTaskStatus.unknown:
        // Status baru dari server yang belum dikenal: pakai namanya apa adanya.
        return (
          task.statusNama,
          AppThemeColors.grey4,
          AppThemeColors.secondaryText,
        );
      case MyTaskStatus.berjalan:
        if (!task.bisaDikerjakan) {
          return (
            'Menunggu',
            AppThemeColors.grey4,
            AppThemeColors.secondaryText,
          );
        }
        return switch (TaskPriorityLogic.urgencyOf(task)) {
          TaskUrgency.overdue => (
            'Terlambat',
            AppThemeColors.danger,
            Colors.white,
          ),
          TaskUrgency.urgent => (
            'Mendesak',
            AppThemeColors.primary,
            Colors.white,
          ),
          TaskUrgency.soon => (
            'Segera',
            AppThemeColors.warningSoft,
            AppThemeColors.gold,
          ),
          TaskUrgency.normal => (
            'Aktif',
            AppThemeColors.informationSoft,
            AppThemeColors.information,
          ),
        };
    }
  }
}
