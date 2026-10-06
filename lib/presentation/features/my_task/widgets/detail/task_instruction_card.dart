import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';

class TaskInstructionCard extends StatelessWidget {
  const TaskInstructionCard({super.key, required this.instruction});

  final String instruction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.sticky_note_2_outlined,
            size: 20,
            color: AppThemeColors.brown,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Instruksi supervisor',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppThemeColors.brown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  instruction,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppThemeColors.brown,
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
