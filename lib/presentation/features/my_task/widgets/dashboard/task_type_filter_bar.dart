import 'package:bapendacore/domain/entities/my_task/task_type.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';

/// Filter jenis tugas (null = semua). Bisa digeser horizontal.
class TaskTypeFilterBar extends StatelessWidget {
  const TaskTypeFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TaskType? selected;
  final ValueChanged<TaskType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppThemeColors.defaultBackground,
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        children: [
          _FilterChip(
            label: 'Semua',
            isSelected: selected == null,
            onTap: () => onChanged(null),
          ),
          for (final type in TaskType.values) ...[
            const SizedBox(width: 8),
            _FilterChip(
              label: type.shortLabel,
              isSelected: selected == type,
              onTap: () => onChanged(selected == type ? null : type),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppThemeColors.primary : AppThemeColors.defaultSurface,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? AppThemeColors.primary : AppThemeColors.defaultBorder,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppThemeColors.secondaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
