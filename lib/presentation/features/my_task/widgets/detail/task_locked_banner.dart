import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';

class TaskLockedBanner extends StatelessWidget {
  const TaskLockedBanner({super.key, required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.warningSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            size: 20,
            color: AppThemeColors.gold,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Belum bisa dikerjakan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppThemeColors.gold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message ?? 'Syarat pengerjaan tugas ini belum terpenuhi.',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppThemeColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}