import 'package:mybapenda/domain/entities/my_task/my_task_header_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';

class TaskTypeFilterBar extends StatelessWidget {
  const TaskTypeFilterBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<MyTaskFilterEntity> options;
  final String? selected; 
  final ValueChanged<String?> onChanged;

  static const _all = 'semua'; 

  bool _isSelected(String kode) =>
      kode == _all ? selected == null : selected == kode;

  void _tap(String kode) {
    if (kode == _all) return onChanged(null);
    onChanged(selected == kode ? null : kode); 
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppThemeColors.defaultBackground,
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _FilterChip(
              label: options[i].nama,
              isSelected: _isSelected(options[i].kode),
              onTap: () => _tap(options[i].kode),
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
      color: isSelected
          ? AppThemeColors.primary
          : AppThemeColors.defaultSurface,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected
              ? AppThemeColors.primary
              : AppThemeColors.defaultBorder,
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
