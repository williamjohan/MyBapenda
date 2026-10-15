import 'dart:io';
import 'dart:ui' as ui;

import 'package:bapendacore/core/constants/app_colors_new.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MarkerStampUtil {
  MarkerStampUtil._();

  static Future<Uint8List> _bytes(String source) async {
    if (!source.startsWith('http')) return File(source).readAsBytes();

    final client = HttpClient();
    try {
      final req = await client
          .getUrl(Uri.parse(source))
          .timeout(const Duration(seconds: 20));
      final res = await req.close().timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) {
        throw HttpException('HTTP ${res.statusCode}', uri: Uri.parse(source));
      }
      return await consolidateHttpClientResponseBytes(res);
    } finally {
      client.close();
    }
  }

  /// [source] bisa path lokal atau URL. Return path file hasil (PNG).
  static Future<String> drawBox({
    required String source,
    required Rect box, // relatif 0..1
    Color color = AppThemeColors.primary,
  }) async {
    final img = await decodeImageFromList(await _bytes(source));
    final w = img.width.toDouble();
    final h = img.height.toDouble();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImage(img, Offset.zero, Paint());

    final rect = Rect.fromLTRB(
      box.left * w,
      box.top * h,
      box.right * w,
      box.bottom * h,
    );

    final stroke = (w * 0.006).clamp(3.0, 12.0);

    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke + 4
        ..color = Colors.white,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color,
    );

    final picture = recorder.endRecording();
    final out = await picture.toImage(img.width, img.height);
    final data = await out.toByteData(format: ui.ImageByteFormat.png);

    img.dispose();
    out.dispose();
    picture.dispose();

    if (data == null) throw Exception('Gagal meng-encode foto');

    final path =
        '${Directory.systemTemp.path}${Platform.pathSeparator}'
        'marker_${DateTime.now().microsecondsSinceEpoch}.png';
    await File(path).writeAsBytes(data.buffer.asUint8List(), flush: true);
    return path;
  }
}
