import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Ciri-ciri satu pin. Dua pin dengan ciri sama memakai gambar yang sama.
typedef PinSpec = ({String label, Color color, bool selected, bool pinned});

class SurveyPinIcons {
  SurveyPinIcons._();

  // Ukuran pin di layar (logical pixel), sama seperti pin versi lama.
  static const _width = 40.0;
  static const _height = 50.0;

  static final Map<String, BitmapDescriptor> _ready = {};
  static final Map<String, Future<void>> _loading = {};

  static String _keyOf(PinSpec s) =>
      '${s.label}|${s.color.toARGB32()}|${s.selected}|${s.pinned}';

  /// Gambar pin bila sudah jadi, `null` bila belum.
  static BitmapDescriptor? peek(PinSpec spec) => _ready[_keyOf(spec)];

  /// Pastikan gambar pin tersedia. Aman dipanggil berulang / bersamaan.
  static Future<void> ensure(PinSpec spec, double dpr) async {
    final key = _keyOf(spec);
    if (_ready.containsKey(key)) return;

    try {
      final pending = _loading[key] ??= _render(spec, dpr)
          .then((icon) => _ready[key] = icon)
          .whenComplete(() => _loading.remove(key));
      await pending;
    } catch (e) {
      debugPrint('Gagal menggambar pin "${spec.label}": $e');
    }
  }

  /// Kosongkan cache (dipanggil saat halaman daftar ditutup).
  static void clear() {
    _ready.clear();
    _loading.clear();
  }

  // ---- Menggambar ----

  static Future<BitmapDescriptor> _render(PinSpec spec, double dpr) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(dpr);
    _paint(canvas, spec);
    final picture = recorder.endRecording();

    final image = await picture.toImage(
      (_width * dpr).round(),
      (_height * dpr).round(),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();

    return BitmapDescriptor.bytes(
      data!.buffer.asUint8List(),
      width: _width,
      height: _height,
    );
  }

  static void _paint(Canvas canvas, PinSpec spec) {
    const r = _width / 2;

    // Bentuk pin = lingkaran + ekor runcing di bawah.
    final head = Path()
      ..addOval(Rect.fromCircle(center: const Offset(r, r), radius: r - 2));
    final tail = Path()
      ..moveTo(r - r * 0.62, r + r * 0.55)
      ..lineTo(r, _height - 1)
      ..lineTo(r + r * 0.62, r + r * 0.55)
      ..close();
    final pin = Path.combine(PathOperation.union, head, tail);

    // Garis tepi putih, lalu isi warna.
    canvas.drawPath(
      pin,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(pin, Paint()..color = spec.color);

    // Pin terpilih: tengahnya putih, angka berwarna.
    if (spec.selected) {
      canvas.drawCircle(
        const Offset(r, r),
        r * 0.58,
        Paint()..color = Colors.white,
      );
    }

    // Nomor urut.
    final text = TextPainter(
      text: TextSpan(
        text: spec.label,
        style: TextStyle(
          fontSize: spec.label.length > 2 ? 11 : 15,
          fontWeight: FontWeight.w800,
          color: spec.selected ? spec.color : Colors.white,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, Offset((_width - text.width) / 2, r - text.height / 2));
    text.dispose();

    // Titik gelap di pojok kanan atas = urutan dikunci petugas.
    if (spec.pinned) {
      const c = Offset(_width - 7.5, 7.5);
      canvas.drawCircle(c, 7.5, Paint()..color = Colors.white);
      canvas.drawCircle(c, 6, Paint()..color = const Color(0xFF1F2933));
      canvas.drawCircle(c, 2, Paint()..color = Colors.white);
    }
  }
}
