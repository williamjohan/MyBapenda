import 'package:flutter/material.dart';

import '../../../../../core/theme/theme_kit.dart';

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
    final palette = context.palette;

    return Container(
      color: palette.surfaceMuted,
      child: TabBar(
        controller: controller,
        labelColor: palette.accent,
        unselectedLabelColor: palette.textSecondary,
        indicatorColor: palette.brand,
        indicatorWeight: 3,
        dividerColor: palette.borderStrong,
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
    final palette = context.palette;
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: showAlert ? palette.danger : palette.borderStrong,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: showAlert ? Colors.white : palette.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
