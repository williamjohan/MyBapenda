// lib/presentation/shared/widgets/bapenda_status_chip.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum BapendaStatusTone { success, warning, info, danger, neutral }

class StatusChip extends StatelessWidget {
  final String label;
  final BapendaStatusTone tone;

  const StatusChip({
    super.key,
    required this.label,
    this.tone = BapendaStatusTone.neutral,
  });

  (Color bg, Color fg) get _colors => switch (tone) {
        BapendaStatusTone.success => (const Color(0xFFE6F6EC), const Color(0xFF1B8A4B)),
        BapendaStatusTone.warning => (const Color(0xFFFFF3DC), const Color(0xFFB8680F)),
        BapendaStatusTone.info => (const Color(0xFFE3F1FD), const Color(0xFF1769AA)),
        BapendaStatusTone.danger => (const Color(0xFFFDE8E8), const Color(0xFFC62828)),
        BapendaStatusTone.neutral => (const Color(0xFFEEF0F3), const Color(0xFF5B6470)),
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}