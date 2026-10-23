import 'package:mybapenda/domain/entities/my_task/my_task_entity.dart';
import 'package:flutter/material.dart';
import '../../../va_qris/widgets/common/va_qris_hero_header.dart';
import '../../utils/task_deadline_label.dart';
import '../../utils/task_type_style.dart';
import '../dashboard/task_status_chip.dart';

class TaskDetailHeader extends StatelessWidget {
  const TaskDetailHeader({
    super.key,
    required this.task,
  }); // [UBAH] MyTaskEntity

  final MyTaskEntity task;

  @override
  Widget build(BuildContext context) {
    final jenis = task.jenisType;
    return VaQrisHeroHeader(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(jenis.icon, size: 30, color: jenis.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.jenisNama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.noSkpd,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TaskStatusChip(task: task),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        taskDeadlineLabel(task),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
