import 'package:bapendacore/core/utils/app_formatters_utils.dart';
import 'package:bapendacore/domain/entities/my_task/task_entity.dart';
import 'package:bapendacore/domain/entities/my_task/task_status.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../../logic/task_priority_logic.dart';
import '../../utils/task_deadline_label.dart';
import '../../utils/task_type_style.dart';
import 'task_status_chip.dart';

/// Card ringkas satu tugas (info awal, tanpa membuka detail).
/// Tugas mendesak/terlambat diberi aksen warna dan latar agar terlihat dulu.
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.onTap});

  final TaskEntity task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final urgency = TaskPriorityLogic.urgencyOf(task);
    final accent = _accent(urgency);
    final isPriority = TaskPriorityLogic.isPriority(task);

    return Material(
      color: _background(urgency),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isPriority ? accent : AppThemeColors.defaultBorder,
          width: isPriority ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(task: task),
                      const SizedBox(height: 10),
                      Text(
                        task.taxpayerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppThemeColors.titleText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _IconLine(
                        icon: Icons.pin_outlined,
                        text: AppFormatters.nop(task.nop),
                      ),
                      const SizedBox(height: 3),
                      _IconLine(
                        icon: Icons.place_outlined,
                        text: '${task.objectName}, ${task.address}',
                        maxLines: 2,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                          height: 1,
                          color: AppThemeColors.subtleBorder,
                        ),
                      ),
                      _DeadlineRow(task: task, urgency: urgency),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _accent(TaskUrgency urgency) {
    switch (task.status) {
      case TaskStatus.selesai:
        return AppThemeColors.success;
      case TaskStatus.kedaluwarsa:
        return AppThemeColors.disabled;
      case TaskStatus.aktif:
        return switch (urgency) {
          TaskUrgency.overdue => AppThemeColors.danger,
          TaskUrgency.urgent => AppThemeColors.primary,
          TaskUrgency.soon => AppThemeColors.warning,
          TaskUrgency.normal => AppThemeColors.information,
        };
    }
  }

  Color _background(TaskUrgency urgency) {
    return switch (urgency) {
      TaskUrgency.overdue => AppThemeColors.dangerSoft,
      TaskUrgency.urgent => AppThemeColors.primarySoft,
      _ => AppThemeColors.defaultSurface,
    };
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: task.type.softColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(task.type.icon, size: 22, color: task.type.color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.type.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: task.type.color,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                task.taskNumber,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppThemeColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        TaskStatusChip(task: task),
      ],
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text, this.maxLines = 1});

  final IconData icon;
  final String text;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 15, color: AppThemeColors.tertiaryText),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.3,
              color: AppThemeColors.secondaryText,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeadlineRow extends StatelessWidget {
  const _DeadlineRow({required this.task, required this.urgency});

  final TaskEntity task;
  final TaskUrgency urgency;

  @override
  Widget build(BuildContext context) {
    final isAlert =
        urgency == TaskUrgency.overdue || urgency == TaskUrgency.urgent;
    final color = urgency == TaskUrgency.overdue
        ? AppThemeColors.danger
        : isAlert
        ? AppThemeColors.brown
        : AppThemeColors.secondaryText;

    return Row(
      children: [
        Icon(Icons.schedule_rounded, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          taskDeadlineLabel(task),
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isAlert ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
        if (task.status == TaskStatus.aktif) ...[
          const Text(
            '  \u2022  ',
            style: TextStyle(color: AppThemeColors.tertiaryText),
          ),
          Expanded(
            child: Text(
              taskDeadlineDateTime(task),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppThemeColors.tertiaryText,
              ),
            ),
          ),
        ] else
          const Spacer(),
        const Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: AppThemeColors.tertiaryText,
        ),
      ],
    );
  }
}
