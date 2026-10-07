import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../../config/task_extra_field.dart';
import 'form_section_card.dart';

/// Field tambahan yang berbeda antar jenis tugas (dari TaskFormConfig).
class ExtraFieldsSection extends StatelessWidget {
  const ExtraFieldsSection({
    super.key,
    required this.step,
    required this.fields,
    required this.values,
    required this.onChanged,
  });

  final int step;
  final List<TaskExtraField> fields;
  final Map<String, String> values;
  final void Function(String key, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    final isDone = fields
        .where((f) => f.isRequired)
        .every((f) => (values[f.key] ?? '').trim().isNotEmpty);

    return FormSectionCard(
      step: step,
      title: 'Informasi tambahan',
      isDone: isDone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < fields.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _FieldLabel(field: fields[i]),
            const SizedBox(height: 8),
            switch (fields[i].type) {
              TaskExtraFieldType.choice => _ChoiceField(
                field: fields[i],
                value: values[fields[i].key],
                onChanged: (v) => onChanged(fields[i].key, v),
              ),
              TaskExtraFieldType.text => _TextField(
                field: fields[i],
                initial: values[fields[i].key] ?? '',
                onChanged: (v) => onChanged(fields[i].key, v),
              ),
            },
          ],
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.field});

  final TaskExtraField field;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: field.label,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: AppThemeColors.primaryText,
        ),
        children: [
          if (!field.isRequired)
            const TextSpan(
              text: '  (opsional)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppThemeColors.tertiaryText,
              ),
            ),
        ],
      ),
    );
  }
}

class _ChoiceField extends StatelessWidget {
  const _ChoiceField({
    required this.field,
    required this.value,
    required this.onChanged,
  });

  final TaskExtraField field;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in field.options)
          ChoiceChip(
            label: Text(option),
            selected: value == option,
            showCheckmark: false,
            onSelected: (_) => onChanged(option),
            selectedColor: AppThemeColors.primarySoft,
            backgroundColor: AppThemeColors.defaultSurface,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: value == option ? FontWeight.w700 : FontWeight.w500,
              color: value == option
                  ? AppThemeColors.brown
                  : AppThemeColors.secondaryText,
            ),
            side: BorderSide(
              color: value == option
                  ? AppThemeColors.primary
                  : AppThemeColors.defaultBorder,
              width: value == option ? 1.5 : 1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          ),
      ],
    );
  }
}

class _TextField extends StatefulWidget {
  const _TextField({
    required this.field,
    required this.initial,
    required this.onChanged,
  });

  final TaskExtraField field;
  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      style: const TextStyle(fontSize: 14.5, color: AppThemeColors.primaryText),
      decoration: InputDecoration(
        hintText: widget.field.hint,
        hintStyle: const TextStyle(color: AppThemeColors.tertiaryText),
        filled: true,
        fillColor: AppThemeColors.defaultBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: _border(AppThemeColors.defaultBorder),
        enabledBorder: _border(AppThemeColors.defaultBorder),
        focusedBorder: _border(AppThemeColors.primary, width: 1.6),
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
