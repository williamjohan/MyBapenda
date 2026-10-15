import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Menyimpan goresan tanda tangan. Satu goresan = daftar titik.
class SignatureController extends ChangeNotifier {
  final List<List<Offset>> _goresan = [];

  List<List<Offset>> get goresan => _goresan;
  bool get isEmpty => _goresan.every((g) => g.isEmpty);

  void _mulai(Offset p) {
    _goresan.add([p]);
    notifyListeners();
  }

  void _tambah(Offset p) {
    if (_goresan.isEmpty) return;
    _goresan.last.add(p);
    notifyListeners();
  }

  void clear() {
    _goresan.clear();
    notifyListeners();
  }

  /// Ekspor PNG berlatar PUTIH ke file sementara; null bila belum ada goresan.
  Future<String?> toPngFile(Size size, {double pixelRatio = 2}) async {
    if (isEmpty) return null;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(pixelRatio);
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    _SignaturePainter.gambar(canvas, _goresan, Colors.black);

    final img = await recorder.endRecording().toImage(
      (size.width * pixelRatio).round(),
      (size.height * pixelRatio).round(),
    );
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    if (data == null) return null;

    final file = File(
      '${Directory.systemTemp.path}/ttd_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return file.path;
  }
}

/// Area tanda tangan dengan jari. Latar selalu putih supaya hasil PNG
/// sama dengan yang terlihat (juga di dark mode).
class SignaturePad extends StatefulWidget {
  final SignatureController controller;
  final double height;

  /// Teks merah di bawah area (mis. "Belum ditandatangani").
  final String? errorText;

  const SignaturePad({
    super.key,
    required this.controller,
    this.height = 180,
    this.errorText,
  });

  @override
  State<SignaturePad> createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  final _key = GlobalKey();

  /// Ukuran area saat ini, dipakai untuk ekspor PNG.
  Size get ukuran =>
      (_key.currentContext?.findRenderObject() as RenderBox?)?.size ??
      Size(double.infinity, widget.height);

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final error = widget.errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          key: _key,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: error != null ? Colors.red : const Color(0xFFD5D9DE),
              width: error != null ? 1.5 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                // Drag vertikal & horizontal (bukan pan) supaya menang atas
                // scroll halaman induk: slop-nya sama dan detektor terdalam
                // memproses gerakan lebih dulu.
                child: GestureDetector(
                  onTapDown: (d) => c._mulai(d.localPosition),
                  onVerticalDragStart: (d) => c._mulai(d.localPosition),
                  onVerticalDragUpdate: (d) => c._tambah(d.localPosition),
                  onHorizontalDragStart: (d) => c._mulai(d.localPosition),
                  onHorizontalDragUpdate: (d) => c._tambah(d.localPosition),
                  child: AnimatedBuilder(
                    animation: c,
                    builder: (_, _) =>
                        CustomPaint(painter: _SignaturePainter(c.goresan)),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: c,
                builder: (_, _) => c.isEmpty
                    ? const IgnorePointer(
                        child: Center(
                          child: Text(
                            'Tanda tangan di sini',
                            style: TextStyle(
                              color: Color(0xFFB0B7C0),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    : Positioned(
                        right: 4,
                        top: 4,
                        child: TextButton.icon(
                          onPressed: c.clear,
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Hapus'),
                        ),
                      ),
              ),
            ],
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(error, style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> goresan;
  _SignaturePainter(this.goresan);

  static void gambar(Canvas canvas, List<List<Offset>> goresan, Color warna) {
    final paint = Paint()
      ..color = warna
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final g in goresan) {
      if (g.length == 1) {
        canvas.drawCircle(g.first, 1.4, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(g.first.dx, g.first.dy);
      for (final p in g.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) => gambar(canvas, goresan, Colors.black);

  // Daftar goresan dimutasi di tempat, jadi selalu gambar ulang.
  @override
  bool shouldRepaint(_SignaturePainter old) => true;
}
