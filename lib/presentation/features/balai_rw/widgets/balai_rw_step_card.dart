// lib/presentation/features/balai_rw/widgets/balai_rw_step_card.dart
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:bapendacore/presentation/shared/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/bapenda_image.dart';

enum BalaiRwStepState {
  done, // sudah dikerjakan
  active, // langkah berikutnya (koordinator)
  locked, // belum bisa, menunggu langkah sebelumnya
  pending, // belum dikerjakan, dilihat oleh non-koordinator
}

class BalaiRwStepCard extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final BalaiRwStepState state;
  final String? thumbPath;
  final String? actionLabel; // null = tanpa tombol
  final IconData? actionIcon;
  final bool actionPrimary;
  final VoidCallback? onAction;
  final VoidCallback? onTap;
  final bool isLast;

  const BalaiRwStepCard({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.state,
    this.thumbPath,
    this.actionLabel,
    this.actionIcon,
    this.actionPrimary = false,
    this.onAction,
    this.onTap,
    this.isLast = false,
  });

  static const _brand = Color(0xFFB8680F);
  static const _green = Color(0xFF1B8A4B);
  static const _line = Color(0xFFE4E7EB);

  @override
  Widget build(BuildContext context) {
    final (chipLabel, chipTone) = switch (state) {
      BalaiRwStepState.done => ('Selesai', BapendaStatusTone.success),
      BalaiRwStepState.active => ('Berikutnya', BapendaStatusTone.warning),
      BalaiRwStepState.locked => ('Terkunci', BapendaStatusTone.neutral),
      BalaiRwStepState.pending => ('Belum', BapendaStatusTone.neutral),
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                _dot(),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: state == BalaiRwStepState.done ? _green : _line,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Opacity(
                opacity: state == BalaiRwStepState.locked ? 0.6 : 1,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2933),
                                  ),
                                ),
                              ),
                              StatusChip(
                                label: chipLabel,
                                tone: chipTone,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  subtitle,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    height: 1.4,
                                    color: const Color(0xFF7B8794),
                                  ),
                                ),
                              ),
                              if (thumbPath != null) ...[
                                const SizedBox(width: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: BapendaImage(
                                    path: thumbPath!,
                                    width: 56,
                                    height: 56,
                                    cacheWidth: 160,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (actionLabel != null) ...[
                            const SizedBox(height: 12),
                            Button(
                              label: actionLabel!,
                              icon: actionIcon,
                              height: 42,
                              variant: actionPrimary
                                  ? BapendaButtonVariant.primary
                                  : BapendaButtonVariant.outlined,
                              onPressed: onAction,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() {
    final done = state == BalaiRwStepState.done;
    final active = state == BalaiRwStepState.active;
    final locked = state == BalaiRwStepState.locked;

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? _green : (active ? _brand : Colors.white),
        border: Border.all(
          color: done ? _green : (active ? _brand : const Color(0xFFCBD2D9)),
          width: 1.5,
        ),
      ),
      child: done
          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : locked
          ? const Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: Color(0xFF9AA5B1),
            )
          : Text(
              '$number',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : const Color(0xFF9AA5B1),
              ),
            ),
    );
  }
}
