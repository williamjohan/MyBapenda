import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';

class BillingEmptyState extends StatelessWidget {
  const BillingEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

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
                color: AppThemeColors.successSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppThemeColors.success),
            ),
            const SizedBox(height: 16),
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
