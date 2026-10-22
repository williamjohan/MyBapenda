// lib/presentation/features/reklame/widgets/reklame_survey_baru_card.dart
import 'package:flutter/material.dart';

class ReklameSurveyBaruCard extends StatelessWidget {
  final int? total;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ReklameSurveyBaruCard({
    super.key,
    required this.total,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE09A2B), Color(0xFFB8680F)],
                  ),
                ),
                child: total == null
                    ? const Icon(
                        Icons.assignment_outlined,
                        color: Colors.white,
                        size: 26,
                      )
                    : Padding(
                        padding: const EdgeInsets.all(6),
                        child: FittedBox(
                          // angka 3 digit tetap muat
                          child: Text(
                            '$total',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2933),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7B8794),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B7C0)),
            ],
          ),
        ),
      ),
    );
  }
}
