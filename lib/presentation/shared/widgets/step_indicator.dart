// lib/presentation/shared/widgets/step_indicator.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StepIndicator extends StatelessWidget {
  final List<String> labels;
  final int currentIndex; 

  const StepIndicator({
    super.key,
    required this.labels,
    required this.currentIndex,
  });

  static const Color _brand = Color(0xFFB8680F);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          _StepNode(
            label: labels[i],
            number: i + 1,
            done: i < currentIndex,
            active: i == currentIndex,
          ),
          if (i != labels.length - 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 13),
                child: Container(
                  height: 2,
                  color: i < currentIndex ? _brand : const Color(0xFFE4E7EB),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _StepNode extends StatelessWidget {
  final String label;
  final int number;
  final bool done;
  final bool active;

  const _StepNode({
    required this.label,
    required this.number,
    required this.done,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFFB8680F);
    final filled = done || active;

    return SizedBox(
      width: 56,
      child: Column(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? brand : Colors.white,
              border: Border.all(
                color: filled ? brand : const Color(0xFFCBD2D9),
                width: 1.5,
              ),
            ),
            child: done
                ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                : Text(
                    '$number',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : const Color(0xFF9AA5B1),
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? const Color(0xFF1F2933) : const Color(0xFF9AA5B1),
            ),
          ),
        ],
      ),
    );
  }
}
