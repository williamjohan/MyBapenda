import 'package:bapendacore/core/utils/app_formatters_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/app_colors_new.dart';
import '../../../../../core/utils/va_qris_constants.dart';

class NopInputCard extends StatelessWidget {
  const NopInputCard({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.errorText,
    this.enabled = true,
  });

  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.subtleBorder),
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final length = value.text.length;
          final isComplete = length == kNopLength;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nomor Objek Pajak (NOP)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppThemeColors.titleText,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                enabled: enabled,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) {
                  if (isComplete) onSubmitted();
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(kNopLength),
                ],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppThemeColors.primaryText,
                ),
                decoration: InputDecoration(
                  hintText: '18 digit tanpa spasi atau titik',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w400,
                    color: AppThemeColors.tertiaryText,
                  ),
                  errorText: errorText,
                  filled: true,
                  fillColor: AppThemeColors.defaultBackground,
                  prefixIcon: const Icon(
                    Icons.pin_outlined,
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
                  focusedBorder: _border(AppThemeColors.primary, width: 1.6),
                  errorBorder: _border(AppThemeColors.danger),
                  focusedErrorBorder: _border(AppThemeColors.danger, width: 1.6),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isComplete
                          ? AppFormatters.nop(value.text)
                          : 'Masukkan $kNopLength digit NOP',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isComplete
                            ? AppThemeColors.success
                            : AppThemeColors.secondaryText,
                        fontWeight:
                            isComplete ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  Text(
                    '$length/$kNopLength',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppThemeColors.tertiaryText,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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
