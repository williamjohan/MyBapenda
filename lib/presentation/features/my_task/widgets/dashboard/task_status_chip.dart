import 'package:bapendacore/domain/entities/my_task/task_entity.dart';
import 'package:bapendacore/domain/entities/my_task/task_status.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../../logic/task_priority_logic.dart';

/// Chip status tugas. Untuk tugas aktif, label mengikuti tingkat urgensi.
class TaskStatusChip extends StatelessWidget {
  const TaskStatusChip({super.key, required this.task});

  final TaskEntity task;

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
    switch (task.status) {
      case TaskStatus.selesai:
        return ('Selesai', AppThemeColors.successSoft, AppThemeColors.success);
      case TaskStatus.kedaluwarsa:
        return ('Kedaluwarsa', AppThemeColors.grey4, AppThemeColors.secondaryText);
      case TaskStatus.aktif:
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
