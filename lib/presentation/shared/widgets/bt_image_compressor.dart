import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class BtImageCompressor {
  BtImageCompressor._();

  static Future<String> toJpeg(
    String path, {
    int maxBytes = 800 * 1024,
  }) async {
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
          
          // Selalu catat hasil terkecil yang pernah didapat
          if (size < bestSize) {
            best = out.path;
            bestSize = size;
          }
          
          // Jika masuk target, langsung kembalikan dan bersihkan sisa file
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


    // Jika gagal mencapai target maxBytes, gunakan ukuran paling kecil yang berhasil didapat
    if (best != null) {
      debugPrint(
        '[Compress] Peringatan: Gagal mencapai target ${maxBytes ~/ 1024} KB. '
        'Menggunakan hasil terbaik: ${bestSize ~/ 1024} KB',
      );
      return _keep(best, tmpFiles);
    }

    // Hanya lempar Exception jika kompresor benar-benar gagal memproses gambar (out == null terus menerus)
    _cleanup(tmpFiles, keep: null);
    throw Exception('Gagal memproses dan mengompres gambar.');
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