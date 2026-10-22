import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mybapenda/core/constants/design_system/tokens/app_palette.dart';

class _Satuan extends StatelessWidget {
  final String text;

  const _Satuan(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 14),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: context.palette.textSecondary,
        ),
      ),
    );
  }
}

InputDecoration _dec(
  BuildContext context,
  String? hint, {
  String? suffixText,
  bool readOnly = false,
}) => InputDecoration(
  hintText: hint,
  suffixIcon: suffixText == null ? null : _Satuan(suffixText),
  suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
  hintStyle: TextStyle(fontSize: 13, color: context.palette.textTertiary),
  isDense: true,
  filled: true,
  fillColor: readOnly ? context.palette.border : context.palette.surfaceMuted,
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: context.palette.border),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: context.palette.border),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: readOnly ? context.palette.border : context.palette.accent,
      width: 1.4,
    ),
  ),
);

Widget _labeled(
  BuildContext context,
  String label,
  Widget field, {
  bool mandatory = false,
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: context.palette.textSecondary,
        ),
        children: [
          TextSpan(text: label),
          if (mandatory)
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: context.palette.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    ),
    const SizedBox(height: 6),
    field,
  ],
);

TextStyle _valueStyle(BuildContext context) =>
    TextStyle(fontSize: 13.5, color: context.palette.textPrimary);

class BapendaTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? suffixText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final bool readOnly;
  final bool mandatory;
  final ValueChanged<String>? onChanged;

  const BapendaTextField({
    super.key,
    required this.label,
    this.hint,
    this.suffixText,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.mandatory = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _labeled(
      context,
      label,
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        maxLines: maxLines,
        readOnly: readOnly,
        onChanged: onChanged,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        style: _valueStyle(context),
        decoration: _dec(
          context,
          hint,
          suffixText: suffixText,
          readOnly: readOnly,
        ),
      ),
      mandatory: mandatory,
    );
  }
}

class BapendaDropdownField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;
  final bool mandatory;

  const BapendaDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint = 'Pilih',
    this.mandatory = false,
  });

  @override
  Widget build(BuildContext context) {
    return _labeled(
      context,
      label,
      DropdownButtonFormField<T>(
        // ignore: deprecated_member_use
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        style: _valueStyle(context),
        decoration: _dec(context, hint),
        items: [
          for (final e in items.entries)
            DropdownMenuItem<T>(value: e.key, child: Text(e.value)),
        ],
        onChanged: onChanged,
      ),
      mandatory: mandatory,
    );
  }
}

class BapendaDateField extends StatelessWidget {
  final String label;
  final String valueText;
  final VoidCallback onTap;
  final bool mandatory;

  const BapendaDateField({
    super.key,
    required this.label,
    required this.valueText,
    required this.onTap,
    this.mandatory = false,
  });

  @override
  Widget build(BuildContext context) {
    return _labeled(
      context,
      label,
      InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: InputDecorator(
          decoration: _dec(context, null).copyWith(
            suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
          ),
          child: Text(valueText, style: _valueStyle(context)),
        ),
      ),
      mandatory: mandatory,
    );
  }
}

/// Input angka: hanya 0-9, titik, dan koma.
class BapendaNumberField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? suffixText;
  final TextEditingController? controller;
  final bool readOnly;
  final bool mandatory;

  const BapendaNumberField({
    super.key,
    required this.label,
    this.hint,
    this.suffixText,
    this.controller,
    this.readOnly = false,
    this.mandatory = false,
  });

  @override
  Widget build(BuildContext context) {
    return BapendaTextField(
      label: label,
      hint: hint,
      suffixText: suffixText,
      controller: controller,
      readOnly: readOnly,
      mandatory: mandatory,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
    );
  }
}

class BapendaTimeField extends StatelessWidget {
  final String label;
  final String? valueText;
  final String hint;
  final VoidCallback? onTap;
  final bool mandatory;

  const BapendaTimeField({
    super.key,
    required this.label,
    required this.onTap,
    this.valueText,
    this.hint = 'Pilih jam',
    this.mandatory = false,
  });

  @override
  Widget build(BuildContext context) {
    return _labeled(
      context,
      label,
      InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: InputDecorator(
          decoration: _dec(
            context,
            null,
            readOnly: onTap == null,
          ).copyWith(suffixIcon: const Icon(Icons.schedule_rounded, size: 18)),
          child: Text(
            valueText ?? hint,
            style: valueText == null
                ? _valueStyle(
                    context,
                  ).copyWith(color: context.palette.textTertiary)
                : _valueStyle(context),
          ),
        ),
      ),
      mandatory: mandatory,
    );
  }
}
