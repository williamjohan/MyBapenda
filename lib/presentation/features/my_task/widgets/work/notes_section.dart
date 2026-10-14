import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import 'form_section_card.dart';

/// Keterangan bebas dari petugas.
class NotesSection extends StatefulWidget {
  const NotesSection({
    super.key,
    required this.step,
    required this.initial,
    required this.onChanged,
    this.isRequired = false,
    this.minLength = 0,
  });

  final int step;
  final String initial;
  final ValueChanged<String> onChanged;
  final bool isRequired;
  final int minLength;

  static const int maxLength = 500;

  @override
  State<NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
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
    final min = widget.minLength < 1 ? 1 : widget.minLength;
    final isDone = !widget.isRequired || _controller.text.trim().length >= min;

    return FormSectionCard(
      step: widget.step,
      title: 'Keterangan',
      subtitle: widget.isRequired ? 'Wajib diisi' : 'Opsional',
      isDone: isDone && _controller.text.trim().isNotEmpty,
      child: TextField(
        controller: _controller,
        onChanged: (v) {
          setState(() {});
          widget.onChanged(v);
        },
        maxLines: 4,
        minLines: 3,
        maxLength: NotesSection.maxLength,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(fontSize: 14.5, height: 1.4),
        decoration: InputDecoration(
          hintText: 'Tulis catatan lapangan (kondisi objek, kendala, dll.)',
          hintStyle: const TextStyle(color: AppThemeColors.tertiaryText),
          filled: true,
          fillColor: AppThemeColors.defaultBackground,
          contentPadding: const EdgeInsets.all(14),
          border: _border(AppThemeColors.defaultBorder),
          enabledBorder: _border(AppThemeColors.defaultBorder),
          focusedBorder: _border(AppThemeColors.primary, width: 1.6),
        ),
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
