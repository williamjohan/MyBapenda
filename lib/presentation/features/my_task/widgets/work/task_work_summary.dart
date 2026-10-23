import 'package:mybapenda/domain/entities/my_task/my_task_entity.dart'; // [UBAH] dulu task_entity.dart
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../../../va_qris/widgets/common/va_qris_hero_header.dart';
import '../../utils/task_type_style.dart';

class TaskWorkSummary extends StatelessWidget {
  const TaskWorkSummary({super.key, required this.task});

  final MyTaskEntity task; 

  @override
  Widget build(BuildContext context) {
    final jenis = task.jenisType;
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
                color: jenis.softColor,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(jenis.icon, color: jenis.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.jenisNama, // [UBAH] dulu task.type.label
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: jenis.color,
                    ),
                  ),
                  Text(
                    task.namaWp, // [UBAH] dulu task.taxpayerName
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppThemeColors.titleText,
                    ),
                  ),
                  Text(
                    task.npwpd,
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
