// lib/presentation/shared/utils/bt_image_compressor.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class BtImageCompressor {
  BtImageCompressor._();

  static Future<String> toJpeg(
    String path, {
    int maxBytes = 800 * 1024,
  }) async {
    // sisi terpendek foto (px), dari besar ke kecil
    const sides = [1200, 960, 800, 640, 480];
    const qualities = [80, 70, 60, 50];

    final tmpFiles = <String>[];
    String? best;
    var bestSize = 1 << 62;

    try {
      for (final side in sides) {
        for (final q in qualities) {
          final target =
              '${Directory.systemTemp.path}/up_${DateTime.now().microsecondsSinceEpoch}.jpg';

          final out = await FlutterImageCompress.compressAndGetFile(
            path,
            target,
            minWidth: side,
            minHeight: side,
            quality: q,
            format: CompressFormat.jpeg,
          );
          if (out == null) continue;
          tmpFiles.add(out.path);

          final size = await File(out.path).length();
          if (size < bestSize) {
            best = out.path;
            bestSize = size;
          }
          if (size <= maxBytes) {
            debugPrint('[Compress] ok ${size ~/ 1024} KB (side=$side q=$q)');
            return _keep(out.path, tmpFiles);
          }
        }
      }
    } catch (e) {
      _cleanup(tmpFiles, keep: null);
      rethrow;
    }

    _cleanup(tmpFiles, keep: null);
    throw Exception(
      'Foto tetap ${bestSize ~/ 1024} KB setelah dikompres (batas ${maxBytes ~/ 1024} KB)',
    );
  }

  static String _keep(String keep, List<String> all) {
    _cleanup(all, keep: keep);
    return keep;
  }

  static void _cleanup(List<String> files, {String? keep}) {
    for (final f in files) {
      if (f == keep) continue;
      try {
        File(f).deleteSync();
      } catch (_) {}
    }
  }
}