import 'package:bapendacore/core/utils/date_format_id.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';

class TaskCompletedBanner extends StatelessWidget {
  const TaskCompletedBanner({super.key, required this.completedAt});

  final DateTime? completedAt;

  @override
  Widget build(BuildContext context) {
    final at = completedAt;
    final text = at == null
        ? 'Hasil tugas ini sudah dikirim.'
        : 'Hasil dikirim pada ${formatTanggalId(at)}, ${formatJamId(at)}.';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeColors.successSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: AppThemeColors.success,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppThemeColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
