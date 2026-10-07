import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';

/// Pembungkus satu bagian form: nomor langkah (berubah jadi centang saat
/// lengkap), judul, keterangan, dan isi.
class FormSectionCard extends StatelessWidget {
  const FormSectionCard({
    super.key,
    required this.step,
    required this.title,
    required this.isDone,
    required this.child,
    this.subtitle,
  });

  final int step;
  final String title;
  final String? subtitle;
  final bool isDone;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? AppThemeColors.success.withValues(alpha: 0.4) : AppThemeColors.subtleBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDone ? AppThemeColors.success : AppThemeColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: isDone
                    ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                    : Text(
                        '$step',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppThemeColors.brown,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppThemeColors.titleText,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
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
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
