import 'package:bapendacore/core/utils/app_formatters_utils.dart';
import 'package:bapendacore/domain/entities/my_task/task_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../../../va_qris/widgets/common/va_qris_hero_header.dart';
import '../../utils/task_type_style.dart';

/// Ringkasan tugas di atas form, supaya petugas tahu sedang mengerjakan apa.
class TaskWorkSummary extends StatelessWidget {
  const TaskWorkSummary({super.key, required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    return VaQrisHeroHeader(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: task.type.softColor,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(task.type.icon, color: task.type.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.type.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: task.type.color,
                    ),
                  ),
                  Text(
                    task.taxpayerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppThemeColors.titleText,
                    ),
                  ),
                  Text(
                    AppFormatters.nop(task.nop),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppThemeColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
