import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors_new.dart';

class BillingTabBar extends StatelessWidget {
  const BillingTabBar({
    super.key,
    required this.controller,
    required this.unpaidCount,
    required this.paidCount,
  });

  final TabController controller;
  final int unpaidCount;
  final int paidCount;

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
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          _CountTab(label: 'Belum dibayar', count: unpaidCount, isAlert: true),
          _CountTab(label: 'Sudah dibayar', count: paidCount),
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
    final showAlert = isAlert && count > 0;
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: showAlert ? AppThemeColors.danger : AppThemeColors.grey4,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: showAlert ? Colors.white : AppThemeColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
