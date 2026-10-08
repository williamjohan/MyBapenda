// lib/presentation/shared/utils/foto_stamp_util.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class FotoStampUtil {
  FotoStampUtil._();

  static Future<String> stamp({
    required String sourcePath,
    required String title,
    required List<String> lines,
  }) async {
    final bytes = await File(sourcePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 1280);
    final frame = await codec.getNextFrame();
    final src = frame.image;
    codec.dispose();

    final w = src.width.toDouble();
    final h = src.height.toDouble();
    final pad = w * 0.04;
    final maxW = w - pad * 2;

    TextPainter tp(String text, double size, FontWeight weight) => TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: size,
          fontWeight: weight,
          height: 1.3,
          shadows: const [Shadow(blurRadius: 4, color: Colors.black87)],
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: maxW);

    final painters = <TextPainter>[
      tp(title, w * 0.038, FontWeight.w800),
      for (final l in lines) tp(l, w * 0.03, FontWeight.w500),
    ];

    final gap = w * 0.008;
    final textH =
        painters.fold<double>(0, (s, p) => s + p.height) +
        gap * (painters.length - 1);
    final gradH = textH + pad * 2.2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImage(src, Offset.zero, Paint());

    final rect = Rect.fromLTWH(0, h - gradH, w, gradH);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
          Colors.black.withValues(alpha: 0.0),
          Colors.black.withValues(alpha: 0.8),
        ]),
    );

    var y = h - pad * 0.8 - textH;
    for (final p in painters) {
      p.paint(canvas, Offset(pad, y));
      y += p.height + gap;
      p.dispose();
    }

    final out = await recorder.endRecording().toImage(src.width, src.height);
    final data = await out.toByteData(format: ui.ImageByteFormat.png);
    src.dispose();
    out.dispose();
    if (data == null) throw Exception('Gagal membuat foto bercap');

    final file = File(
      '${Directory.systemTemp.path}/stamp_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(data.buffer.asUint8List());
    return file.path;
  }
}
