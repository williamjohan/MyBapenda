// lib/presentation/features/camera/widgets/camera_error_view.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors_new.dart'; // Sesuaikan path

class CameraErrorView extends StatelessWidget {
  final String message;
  final bool isPermanentlyDenied;
  final VoidCallback? onRetry;
  final VoidCallback? onOpenSettings;

  const CameraErrorView({
    super.key,
    required this.message,
    this.isPermanentlyDenied = false,
    this.onRetry,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppThemeColors.dangerSoft, // Merah redup
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppThemeColors.danger,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Terjadi Kesalahan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppThemeColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppThemeColors.secondaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            
            if (isPermanentlyDenied && onOpenSettings != null)
              ElevatedButton.icon(
                onPressed: onOpenSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Buka Pengaturan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              )
            else if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}