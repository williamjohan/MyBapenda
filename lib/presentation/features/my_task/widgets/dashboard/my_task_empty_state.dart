import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';

class MyTaskEmptyState extends StatelessWidget {
  const MyTaskEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.assignment_outlined,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppThemeColors.grey4,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: AppThemeColors.tertiaryText),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.titleText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppThemeColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
