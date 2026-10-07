// lib/presentation/shared/widgets/bapenda_form_fields.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

InputDecoration _dec(
  String? hint, {
  String? suffixText,
  bool readOnly = false,
}) => InputDecoration(
  hintText: hint,
  suffixText: suffixText,
  hintStyle: GoogleFonts.plusJakartaSans(
    fontSize: 13,
    color: const Color(0xFF9AA5B1),
  ),
  isDense: true,
  filled: true,
  fillColor: readOnly ? const Color(0xFFEEF0F3) : const Color(0xFFF7F8FA),
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFE4E7EB)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFE4E7EB)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: readOnly ? const Color(0xFFE4E7EB) : const Color(0xFFB8680F),
      width: 1.4,
    ),
  ),
);

Widget _labeled(String label, Widget field) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF52606D),
      ),
    ),
    const SizedBox(height: 6),
    field,
  ],
);

TextStyle get _valueStyle =>
    GoogleFonts.plusJakartaSans(fontSize: 13.5, color: const Color(0xFF1F2933));

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
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _labeled(
      label,
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        maxLines: maxLines,
        readOnly: readOnly,
        onChanged: onChanged,
        style: _valueStyle,
        decoration: _dec(hint, suffixText: suffixText, readOnly: readOnly),
      ),
    );
  }
}

class BapendaDropdownField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final Map<T, String> items; // value -> label
  final ValueChanged<T?> onChanged;

  const BapendaDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint = 'Pilih',
  });

  @override
  Widget build(BuildContext context) {
    return _labeled(
      label,
      DropdownButtonFormField<T>(
        // ignore: deprecated_member_use
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        style: _valueStyle,
        decoration: _dec(hint),
        items: [
          for (final e in items.entries)
            DropdownMenuItem<T>(value: e.key, child: Text(e.value)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

/// Field tanggal: tampilannya mirip text field, tap buka date picker.
class BapendaDateField extends StatelessWidget {
  final String label;
  final String valueText;
  final VoidCallback onTap;

  const BapendaDateField({
    super.key,
    required this.label,
    required this.valueText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _labeled(
      label,
      InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: InputDecorator(
          decoration: _dec(null).copyWith(
            suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
          ),
          child: Text(valueText, style: _valueStyle),
        ),
      ),
    );
  }
}

/// Input angka: hanya 0-9, titik, dan koma. Karakter lain (termasuk hasil
/// paste) otomatis dibuang.
class BapendaNumberField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? suffixText;
  final TextEditingController? controller;
  final bool readOnly;

  const BapendaNumberField({
    super.key,
    required this.label,
    this.hint,
    this.suffixText,
    this.controller,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return BapendaTextField(
      label: label,
      hint: hint,
      suffixText: suffixText,
      controller: controller,
      readOnly: readOnly,
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

  const BapendaTimeField({
    super.key,
    required this.label,
    required this.onTap,
    this.valueText,
    this.hint = 'Pilih jam',
  });

  @override
  Widget build(BuildContext context) {
    return _labeled(
      label,
      InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: InputDecorator(
          decoration: _dec(
            null,
            readOnly: onTap == null,
          ).copyWith(suffixIcon: const Icon(Icons.schedule_rounded, size: 18)),
          child: Text(
            valueText ?? hint,
            style: valueText == null
                ? _valueStyle.copyWith(color: const Color(0xFF9AA5B1))
                : _valueStyle,
          ),
        ),
      ),
    );
  }
}
