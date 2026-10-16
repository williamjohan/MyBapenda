// lib/presentation/shared/widgets/bapenda_status_chip.dart
import 'package:flutter/material.dart';
import 'package:bapendacore/core/constants/design_system/tokens/app_palette.dart';

enum BapendaStatusTone { success, warning, info, danger, neutral }

class StatusChip extends StatelessWidget {
  final String label;
  final BapendaStatusTone tone;

  const StatusChip({
    super.key,
    required this.label,
    this.tone = BapendaStatusTone.neutral,
  });

  (Color bg, Color fg) _colors(BuildContext context) => switch (tone) {
    BapendaStatusTone.success => (
      context.palette.successSoft,
      context.palette.success,
    ),
    BapendaStatusTone.warning => (
      context.palette.accentSoft,
      context.palette.accent,
    ),
    BapendaStatusTone.info => (
      context.palette.statusProsesSoft,
      context.palette.statusProses,
    ),
    BapendaStatusTone.danger => (
      context.palette.dangerSoft,
      context.palette.danger,
    ),
    BapendaStatusTone.neutral => (
      context.palette.border,
      context.palette.textSecondary,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
