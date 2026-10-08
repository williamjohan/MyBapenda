// lib/presentation/shared/utils/bapenda_image_compressor.dart
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class BtImageCompressor {
  BtImageCompressor._();

  static Future<String> toJpeg(
    String path, {
    int quality = 75,
    int maxBytes = 700 * 1024,
  }) async {
    var q = quality;
    while (true) {
      final target =
          '${Directory.systemTemp.path}/up_${DateTime.now().microsecondsSinceEpoch}.jpg';

      final out = await FlutterImageCompress.compressAndGetFile(
        path,
        target,
        minWidth: 1280,
        minHeight: 960,
        quality: q,
        format: CompressFormat.jpeg,
      );
      if (out == null) throw Exception('Gagal mengompres foto');

      if (await File(out.path).length() <= maxBytes || q <= 40) return out.path;
      q -= 15;
    }
  }
}