// lib/presentation/shared/widgets/bapenda_marker_box.dart
import 'package:flutter/material.dart';

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

class MarkerBox extends StatefulWidget {
  final Widget child;
  final Rect initialRect;
  final ValueChanged<Rect>? onChanged;
  final ValueChanged<bool>? onInteracting;
  final double minSize;

  const MarkerBox({
    super.key,
    required this.child,
    this.initialRect = const Rect.fromLTWH(0.28, 0.2, 0.44, 0.4),
    this.onChanged,
    this.onInteracting,
    this.minSize = 0.12,
  });

  @override
  State<MarkerBox> createState() => _MarkerBoxState();
}

class _MarkerBoxState extends State<MarkerBox> {
  static const Color _brand = Color(0xFFE09A2B);
  static const double _handle = 28;

  late Rect _rect = widget.initialRect;

  void _commit(Rect r) {
    setState(() => _rect = r);
    widget.onChanged?.call(r);
  }

  void _move(Size s, Offset d) {
    final w = _rect.width, h = _rect.height;
    final l = (_rect.left + d.dx / s.width).clamp(0.0, 1 - w).toDouble();
    final t = (_rect.top + d.dy / s.height).clamp(0.0, 1 - h).toDouble();
    _commit(Rect.fromLTWH(l, t, w, h));
  }

  void _resize(Size s, Offset d, _Corner c) {
    final dx = d.dx / s.width;
    final dy = d.dy / s.height;
    var l = _rect.left, t = _rect.top, r = _rect.right, b = _rect.bottom;
    final m = widget.minSize;

    switch (c) {
      case _Corner.topLeft:
        l += dx;
        t += dy;
      case _Corner.topRight:
        r += dx;
        t += dy;
      case _Corner.bottomLeft:
        l += dx;
        b += dy;
      case _Corner.bottomRight:
        r += dx;
        b += dy;
    }

    l = l.clamp(0.0, r - m).toDouble();
    t = t.clamp(0.0, b - m).toDouble();
    r = r.clamp(l + m, 1.0).toDouble();
    b = b.clamp(t + m, 1.0).toDouble();
    _commit(Rect.fromLTRB(l, t, r, b));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final size = Size(c.maxWidth, c.maxHeight);
        final px = Rect.fromLTRB(
          _rect.left * size.width,
          _rect.top * size.height,
          _rect.right * size.width,
          _rect.bottom * size.height,
        );

        Widget handle(_Corner corner, Offset pos) => Positioned(
          left: pos.dx - _handle / 2,
          top: pos.dy - _handle / 2,
          width: _handle,
          height: _handle,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (d) => _resize(size, d.delta, corner),
            onPanStart: (_) => widget.onInteracting?.call(true),
            onPanEnd: (_) => widget.onInteracting?.call(false),
            onPanCancel: () => widget.onInteracting?.call(false),
            child: Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _brand,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            IgnorePointer(child: CustomPaint(painter: _DimPainter(px))),
            // Area kotak (drag untuk geser)
            Positioned.fromRect(
              rect: px,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (d) => _move(size, d.delta),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: _brand, width: 2.5),
                  ),
                ),
              ),
            ),
            handle(_Corner.topLeft, px.topLeft),
            handle(_Corner.topRight, px.topRight),
            handle(_Corner.bottomLeft, px.bottomLeft),
            handle(_Corner.bottomRight, px.bottomRight),
          ],
        );
      },
    );
  }
}

/// Gelapin area di luar kotak biar reklamenya makin fokus.
class _DimPainter extends CustomPainter {
  final Rect hole;
  _DimPainter(this.hole);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRect(hole);
    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(_DimPainter old) => old.hole != hole;
}
