import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../../../va_qris/widgets/common/va_qris_primary_button.dart';
import '../../logic/task_validation_logic.dart';

/// Bar bawah: progres kelengkapan, daftar yang belum lengkap, tombol kirim.
class WorkProgressBar extends StatelessWidget {
  const WorkProgressBar({
    super.key,
    required this.progress,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final TaskFormProgress progress;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface,
        border: const Border(top: BorderSide(color: AppThemeColors.subtleBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${progress.done} dari ${progress.total} langkah selesai',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.titleText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.fraction,
                minHeight: 7,
                backgroundColor: AppThemeColors.grey4,
                color: progress.isComplete
                    ? AppThemeColors.success
                    : AppThemeColors.primary,
              ),
            ),
            if (!progress.isComplete) ...[
              const SizedBox(height: 8),
              Text(
                'Belum: ${progress.missing.join(', ')}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: AppThemeColors.secondaryText,
                ),
              ),
            ],
            const SizedBox(height: 12),
            VaQrisPrimaryButton(
              label: 'Kirim hasil tugas',
              icon: Icons.send_rounded,
              isLoading: isSubmitting,
              onPressed: progress.isComplete ? onSubmit : null,
            ),
          ],
        ),
      ),
    );
  }
}
