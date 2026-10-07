import 'package:bapendacore/presentation/shared/widgets/bapenda_image.dart';
import 'package:flutter/material.dart';

class PhotoPreview extends StatelessWidget {
  final String path;
  final double ratio; 
  final Rect? box; 
  final double radius;
  final double maxHeight;

  const PhotoPreview({
    super.key,
    required this.path,
    required this.ratio,
    this.box,
    this.radius = 14,
    this.maxHeight = 360,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: AspectRatio(
          aspectRatio: ratio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                BapendaImage(path: path, cacheWidth: 1000),
                if (box != null)
                  Positioned.fill(
                    child: CustomPaint(painter: _BoxPainter(box!)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BoxPainter extends CustomPainter {
  final Rect box;
  _BoxPainter(this.box);

  static const _brand = Color(0xFFE09A2B);

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTRB(
      box.left * size.width,
      box.top * size.height,
      box.right * size.width,
      box.bottom * size.height,
    );

    // gelapin area luar kotak
    final dim = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRect(r);
    canvas.drawPath(dim, Paint()..color = Colors.black.withValues(alpha: 0.35));

    // garis kotak
    canvas.drawRect(
      r,
      Paint()
        ..color = _brand
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // titik sudut
    for (final p in [r.topLeft, r.topRight, r.bottomLeft, r.bottomRight]) {
      canvas.drawCircle(p, 6, Paint()..color = Colors.white);
      canvas.drawCircle(p, 4.5, Paint()..color = _brand);
    }
  }

  @override
  bool shouldRepaint(_BoxPainter old) => old.box != box;
}
