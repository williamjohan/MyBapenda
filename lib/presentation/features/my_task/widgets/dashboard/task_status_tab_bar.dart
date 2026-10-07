import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';

class TaskStatusTabBar extends StatelessWidget {
  const TaskStatusTabBar({
    super.key,
    required this.controller,
    required this.activeCount,
    required this.doneCount,
    required this.expiredCount,
  });

  final TabController controller;
  final int activeCount;
  final int doneCount;
  final int expiredCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppThemeColors.defaultBackground,
      child: TabBar(
        controller: controller,
        labelColor: AppThemeColors.gold,
        unselectedLabelColor: AppThemeColors.secondaryText,
        indicatorColor: AppThemeColors.primary,
        indicatorWeight: 3,
        dividerColor: AppThemeColors.defaultBorder,
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        labelStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          _CountTab(label: 'Aktif', count: activeCount, isAlert: true),
          _CountTab(label: 'Selesai', count: doneCount),
          _CountTab(label: 'Kedaluwarsa', count: expiredCount),
        ],
      ),
    );
  }
}

class _CountTab extends StatelessWidget {
  const _CountTab({
    required this.label,
    required this.count,
    this.isAlert = false,
  });

  final String label;
  final int count;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    final highlight = isAlert && count > 0;
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: highlight ? AppThemeColors.primary : AppThemeColors.grey4,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: highlight ? Colors.white : AppThemeColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
