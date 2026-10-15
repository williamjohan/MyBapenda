import 'package:bapendacore/domain/entities/va_qris/tax_type_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/app_colors_new.dart';
import 'reference_mask_formatter.dart';
import 'tax_type_field.dart';

/// Form pilih jenis pajak + input nomor referensi (No SKPD / NOP).
/// Label, hint, keyboard, panjang dan mask input mengikuti [selectedTaxType]
/// yang aturannya datang dari API. NOP boleh diketik / ditempel dengan atau
/// tanpa titik; titik ditambahkan otomatis oleh [ReferenceMaskFormatter].
class NopInputCard extends StatelessWidget {
  const NopInputCard({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.taxTypes,
    required this.selectedTaxType,
    required this.onTaxTypeChanged,
    this.errorText,
    this.enabled = true,
  });

  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final List<TaxTypeEntity> taxTypes;
  final TaxTypeEntity? selectedTaxType;
  final ValueChanged<TaxTypeEntity> onTaxTypeChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final type = selectedTaxType;
    final maxLength = type?.referenceLength;
    final digitsOnly = type?.digitsOnly ?? false;
    final mask = type?.mask;
    final label = type?.referenceLabel ?? 'Nomor referensi';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jenis pajak',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.titleText,
            ),
          ),
          const SizedBox(height: 10),
          TaxTypeField(
            taxTypes: taxTypes,
            selected: type,
            enabled: enabled,
            onChanged: onTaxTypeChanged,
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final length = value.text.length;
              // Mask / angka: yang dihitung digitnya saja, pemisah diabaikan
              final counted = mask != null || digitsOnly
                  ? ReferenceMaskFormatter.digitsOf(value.text).length
                  : length;
              final isComplete = maxLength == null
                  ? value.text.trim().isNotEmpty
                  : counted == maxLength;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppThemeColors.titleText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: controller,
                    enabled: enabled && type != null,
                    keyboardType: digitsOnly
                        ? TextInputType.number
                        : TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) {
                      if (isComplete) onSubmitted();
                    },
                    inputFormatters: [
                      if (mask != null)
                        ReferenceMaskFormatter(mask)
                      else ...[
                        if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
                        if (!digitsOnly)
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        if (maxLength != null)
                          LengthLimitingTextInputFormatter(maxLength),
                      ],
                    ],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: AppThemeColors.primaryText,
                    ),
                    decoration: InputDecoration(
                      hintText: type?.hint,
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w400,
                        color: AppThemeColors.tertiaryText,
                      ),
                      errorText: errorText,
                      errorMaxLines: 3,
                      filled: true,
                      fillColor: AppThemeColors.defaultBackground,
                      prefixIcon: Icon(
                        digitsOnly
                            ? Icons.pin_outlined
                            : Icons.receipt_long_outlined,
                        color: AppThemeColors.gold,
                      ),
                      suffixIcon: length > 0 && enabled
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              color: AppThemeColors.tertiaryText,
                              onPressed: controller.clear,
                            )
                          : null,
                      border: _border(AppThemeColors.defaultBorder),
                      enabledBorder: _border(AppThemeColors.defaultBorder),
                      disabledBorder: _border(AppThemeColors.defaultBorder),
                      focusedBorder: _border(
                        AppThemeColors.primary,
                        width: 1.6,
                      ),
                      errorBorder: _border(AppThemeColors.danger),
                      focusedErrorBorder: _border(
                        AppThemeColors.danger,
                        width: 1.6,
                      ),
                    ),
                  ),
                  if (maxLength != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (isComplete) ...[
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: AppThemeColors.success,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            isComplete
                                ? '$label lengkap'
                                : mask != null
                                ? 'Ketik angka saja, titik ditambahkan otomatis'
                                : 'Masukkan $maxLength digit $label',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isComplete
                                  ? AppThemeColors.success
                                  : AppThemeColors.secondaryText,
                              fontWeight: isComplete
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        Text(
                          '$counted/$maxLength digit',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppThemeColors.tertiaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
