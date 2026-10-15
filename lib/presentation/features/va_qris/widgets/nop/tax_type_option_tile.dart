import 'package:bapendacore/domain/entities/va_qris/tax_type_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import 'tax_type_visual.dart';

/// Kartu satu jenis pajak di [TaxTypeSheet]. Nama panjang dibiarkan wrap.
class TaxTypeOptionTile extends StatelessWidget {
  const TaxTypeOptionTile({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final TaxTypeEntity type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppThemeColors.primary
              : AppThemeColors.defaultBorder,
          width: isSelected ? 1.6 : 1,
        ),
      ),
      child: Material(
        color: isSelected
            ? AppThemeColors.primarySoft
            : AppThemeColors.defaultSurface,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppThemeColors.primary
                        : AppThemeColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    type.icon,
                    size: 24,
                    color: isSelected ? Colors.white : AppThemeColors.brown,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.name,
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppThemeColors.brown
                              : AppThemeColors.titleText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        type.inputHint,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppThemeColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          key: ValueKey('on'),
                          color: AppThemeColors.primary,
                        )
                      : const Icon(
                          Icons.radio_button_unchecked_rounded,
                          key: ValueKey('off'),
                          color: AppThemeColors.tertiaryText,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
