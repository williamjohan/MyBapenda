import 'package:mybapenda/domain/entities/va_qris/tax_type_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/theme_kit.dart';
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
    final palette = context.palette;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? palette.brand : palette.borderStrong,
          width: isSelected ? 1.6 : 1,
        ),
      ),
      child: Material(
        color: isSelected ? palette.accentSoft : palette.surface,
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
                    color: isSelected ? palette.brand : palette.accentSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    type.icon,
                    size: 24,
                    color: isSelected ? Colors.white : palette.brandStrong,
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
                              ? palette.brandStrong
                              : palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        type.inputHint,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          key: const ValueKey('on'),
                          color: palette.brand,
                        )
                      : Icon(
                          Icons.radio_button_unchecked_rounded,
                          key: const ValueKey('off'),
                          color: palette.textTertiary,
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
