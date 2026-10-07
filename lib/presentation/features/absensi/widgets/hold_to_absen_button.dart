import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';

/// Tombol fingerprint yang harus DITAHAN sampai ring penuh untuk absen.
/// Lepas sebelum penuh = batal (ring kembali ke nol).
class HoldToAbsenButton extends StatefulWidget {
  final bool isBusy;
  final VoidCallback onCompleted;

  /// true saat jari menekan, false saat dilepas / selesai.
  final ValueChanged<bool>? onHoldChanged;

  final double size;
  final Duration holdDuration;

  const HoldToAbsenButton({
    super.key,
    required this.isBusy,
    required this.onCompleted,
    this.onHoldChanged,
    this.size = 128,
    this.holdDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<HoldToAbsenButton> createState() => _HoldToAbsenButtonState();
}

class _HoldToAbsenButtonState extends State<HoldToAbsenButton>
    with TickerProviderStateMixin {
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: widget.holdDuration,
    reverseDuration: const Duration(milliseconds: 250),
  )..addStatusListener(_onHoldStatus);

  /// Denyut halus saat idle sebagai petunjuk tombol bisa ditekan.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  bool _pressed = false;

  void _onHoldStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    HapticFeedback.heavyImpact();
    _setPressed(false);
    widget.onCompleted();
    _hold.value = 0;
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
    widget.onHoldChanged?.call(value);
  }

  void _start() {
    if (widget.isBusy) return;
    HapticFeedback.selectionClick();
    _setPressed(true);
    _hold.forward();
  }

  void _release() {
    if (!_pressed) return;
    _setPressed(false);
    if (_hold.status != AnimationStatus.completed) _hold.reverse();
  }

  @override
  void dispose() {
    _hold.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final size = widget.size;
    final inner = size - 28;

    return Semantics(
      button: true,
      label: 'Tombol absen',
      hint: 'Tahan untuk absen',
      // Pembaca layar: tekan lama = selesai menahan.
      onLongPress: widget.isBusy ? null : widget.onCompleted,
      child: Listener(
        onPointerDown: (_) => _start(),
        onPointerUp: (_) => _release(),
        onPointerCancel: (_) => _release(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_hold, _pulse]),
          builder: (context, _) {
            final idle = !_pressed && !widget.isBusy;
            final glow = idle ? 0.25 + _pulse.value * 0.2 : 0.45;

            return SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size.square(size),
                    painter: _RingPainter(
                      progress: _hold.value,
                      track: palette.border,
                      colors: palette.headerGradient,
                    ),
                  ),
                  AnimatedScale(
                    scale: _pressed ? 0.94 : 1,
                    duration: const Duration(milliseconds: 120),
                    child: Container(
                      width: inner,
                      height: inner,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: palette.headerLinearGradient,
                        boxShadow: [
                          BoxShadow(
                            color: palette.headerGradient.first.withValues(
                              alpha: glow,
                            ),
                            blurRadius: 24,
                            spreadRadius: idle ? _pulse.value * 4 : 2,
                          ),
                        ],
                      ),
                      child: widget.isBusy
                          ? Padding(
                              padding: EdgeInsets.all(inner * 0.32),
                              child: const CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.fingerprint_rounded,
                              color: Colors.white,
                              size: inner * 0.52,
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color track;
  final List<Color> colors;

  _RingPainter({
    required this.progress,
    required this.track,
    required this.colors,
  });

  static const double _stroke = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(_stroke / 2);

    canvas.drawArc(
      arcRect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke,
    );

    if (progress <= 0) return;
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: math.pi * 1.5,
          colors: colors,
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = _stroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.track != track || old.colors != colors;
}
