import 'package:bapendacore/domain/entities/my_task/task_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../../logic/task_priority_logic.dart';
import 'my_task_empty_state.dart';
import 'task_card.dart';
import 'task_card_skeleton.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({
    super.key,
    required this.tasks,
    required this.isLoading,
    required this.onRefresh,
    required this.onTapTask,
    required this.emptyTitle,
    required this.emptyMessage,
    this.groupPriority = false,
  });

  final List<TaskEntity> tasks;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final ValueChanged<TaskEntity> onTapTask;
  final String emptyTitle;
  final String emptyMessage;

  /// Pisahkan "Perlu segera dikerjakan" dari tugas lain (tab Aktif).
  final bool groupPriority;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => const TaskCardSkeleton(),
      );
    }

    return RefreshIndicator(
      color: AppThemeColors.primary,
      onRefresh: onRefresh,
      child: tasks.isEmpty
          ? CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: MyTaskEmptyState(
                    title: emptyTitle,
                    message: emptyMessage,
                  ),
                ),
              ],
            )
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
              children: _buildChildren(),
            ),
    );
  }

  List<Widget> _buildChildren() {
    final priority = groupPriority
        ? tasks.where(TaskPriorityLogic.isPriority).toList()
        : <TaskEntity>[];
    final others = groupPriority
        ? tasks.where((t) => !TaskPriorityLogic.isPriority(t)).toList()
        : tasks;

    final children = <Widget>[];

    void addCards(List<TaskEntity> list) {
      for (final task in list) {
        children
          ..add(TaskCard(task: task, onTap: () => onTapTask(task)))
          ..add(const SizedBox(height: 10));
      }
    }

    if (priority.isNotEmpty) {
      children.add(
        _SectionLabel(
          text: 'Perlu segera dikerjakan (${priority.length})',
          color: AppThemeColors.danger,
          icon: Icons.priority_high_rounded,
        ),
      );
      addCards(priority);
    }
    if (others.isNotEmpty) {
      if (priority.isNotEmpty) {
        children.add(
          _SectionLabel(
            text: 'Tugas lainnya (${others.length})',
            color: AppThemeColors.secondaryText,
          ),
        );
      }
      addCards(others);
    }
    return children;
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.color, this.icon});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
