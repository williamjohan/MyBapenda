import 'package:bapendacore/domain/entities/va_qris/tax_type_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import 'tax_type_sheet.dart';
import 'tax_type_visual.dart';

/// Field jenis pajak: ikon + nama lengkap (wrap s/d 2 baris). Diketuk
/// membuka [TaxTypeSheet].
class TaxTypeField extends StatelessWidget {
  const TaxTypeField({
    super.key,
    required this.taxTypes,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final List<TaxTypeEntity> taxTypes;
  final TaxTypeEntity? selected;
  final ValueChanged<TaxTypeEntity> onChanged;
  final bool enabled;

  Future<void> _open(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final picked = await TaxTypeSheet.show(
      context,
      taxTypes: taxTypes,
      selected: selected,
    );
    if (picked != null && picked.id != selected?.id) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final type = selected;

    return Material(
      color: AppThemeColors.defaultBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? () => _open(context) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppThemeColors.defaultBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppThemeColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  type?.icon ?? Icons.category_outlined,
                  size: 22,
                  color: AppThemeColors.gold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type?.name ?? 'Pilih jenis pajak',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: type == null
                            ? AppThemeColors.tertiaryText
                            : AppThemeColors.primaryText,
                      ),
                    ),
                    if (type != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        type.inputHint,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppThemeColors.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.expand_more_rounded,
                color: enabled
                    ? AppThemeColors.gold
                    : AppThemeColors.tertiaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
