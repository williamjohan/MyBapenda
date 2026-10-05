import 'package:bapendacore/core/constants/app_colors_new.dart';
import 'package:flutter/material.dart';

class HistoryCardShimmer extends StatefulWidget {
  const HistoryCardShimmer({super.key});

  @override
  State<HistoryCardShimmer> createState() => _HistoryCardShimmerState();
}

class _HistoryCardShimmerState extends State<HistoryCardShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.35 + (_controller.value * 0.2);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppThemeColors.defaultSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppThemeColors.defaultBorder),
            boxShadow: [
              BoxShadow(
                color: AppThemeColors.primary.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(opacity, width: 58, height: 58, radius: 18),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(opacity, width: 90, height: 8, radius: 4),
                        const SizedBox(height: 8),
                        _box(
                          opacity,
                          width: double.infinity,
                          height: 13,
                          radius: 6,
                        ),
                        const SizedBox(height: 6),
                        _box(opacity, width: 160, height: 13, radius: 6),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  _box(opacity, width: 72, height: 28, radius: 14),
                ],
              ),

              const SizedBox(height: 16),

              _box(opacity, width: double.infinity, height: 1, radius: 1),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(opacity, width: 72, height: 9, radius: 4),
                        const SizedBox(height: 6),
                        _box(opacity, width: 110, height: 11, radius: 5),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _box(opacity, width: 62, height: 9, radius: 4),
                        const SizedBox(height: 6),
                        _box(opacity, width: 84, height: 11, radius: 5),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _box(
                      opacity,
                      width: double.infinity,
                      height: 42,
                      radius: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _box(opacity, width: 42, height: 42, radius: 14),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _box(
    double opacity, {
    required double width,
    required double height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppThemeColors.shimmer.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
