import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';

/// Placeholder saat daftar tugas dimuat.
class TaskCardSkeleton extends StatelessWidget {
  const TaskCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeColors.subtleBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Bar(width: 38, height: 38, radius: 10),
              SizedBox(width: 10),
              _Bar(width: 140, height: 14),
            ],
          ),
          SizedBox(height: 14),
          _Bar(width: 200, height: 14),
          SizedBox(height: 8),
          _Bar(width: 150, height: 11),
          SizedBox(height: 8),
          _Bar(width: 240, height: 11),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.width, required this.height, this.radius = 6});

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppThemeColors.shimmer,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
