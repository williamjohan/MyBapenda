import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../cubit/survey_lokasi/survey_lokasi_state.dart';
import '../utils/survey_lokasi_ui_helper.dart';

/// Zoom peta lokasi reklame: dekat, radius maksimal masih kelihatan utuh.
const zoomPetaReklame = 19.5;

/// Ukuran (logis) pin reklame; ujung jarum di tengah bawah.
const ukuranPinReklame = Size(44, 56);

/// Lukis pin reklame: jarum berwarna [warna] berisi papan reklame putih.
void lukisPinReklame(Canvas c, Color warna) {
  final w = ukuranPinReklame.width, h = ukuranPinReklame.height;

  // Jarum: lingkaran + segitiga ke bawah, dengan bayangan tipis.
  final jarum = Path()
    ..addOval(Rect.fromCircle(center: Offset(w / 2, 20), radius: 19))
    ..moveTo(w / 2 - 11, 33)
    ..lineTo(w / 2, h - 2)
    ..lineTo(w / 2 + 11, 33)
    ..close();
  c.drawShadow(jarum, Colors.black, 2, false);
  c.drawPath(jarum, Paint()..color = warna);
  c.drawCircle(
    Offset(w / 2, 20),
    19,
    Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2,
  );

  // Papan reklame: papan + dua tiang.
  final putih = Paint()..color = Colors.white;
  c.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w / 2 - 11, 11, 22, 13),
      const Radius.circular(2),
    ),
    putih,
  );
  final tiang = Paint()
    ..color = Colors.white
    ..strokeWidth = 2.4
    ..strokeCap = StrokeCap.round;
  c.drawLine(Offset(w / 2 - 6, 24), Offset(w / 2 - 6, 30), tiang);
  c.drawLine(Offset(w / 2 + 6, 24), Offset(w / 2 + 6, 30), tiang);
  // Garis "iklan" di papan.
  final iklan = Paint()
    ..color = warna
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;
  c.drawLine(Offset(w / 2 - 7, 15.5), Offset(w / 2 + 7, 15.5), iklan);
  c.drawLine(Offset(w / 2 - 7, 19.5), Offset(w / 2 + 3, 19.5), iklan);
}

/// Ikon marker pin reklame. Ujung jarum = titik koordinat (pakai
/// `anchor: Offset(0.5, 1)`).
Future<BitmapDescriptor> ikonPinReklame(Color warna, double dpr) async {
  final rekam = ui.PictureRecorder();
  lukisPinReklame(Canvas(rekam)..scale(dpr), warna);
  return _bitmap(rekam, ukuranPinReklame.width, ukuranPinReklame.height, dpr);
}

/// Titik posisi petugas (dipakai di preview; peta interaktif memakai titik
/// biru bawaan Google).
Future<BitmapDescriptor> ikonPetugas(Color warna, double dpr) async {
  const d = 22.0;
  final rekam = ui.PictureRecorder();
  final c = Canvas(rekam)..scale(dpr);
  const pusat = Offset(d / 2, d / 2);
  c.drawCircle(pusat, d / 2, Paint()..color = warna.withValues(alpha: 0.25));
  c.drawCircle(pusat, 7, Paint()..color = Colors.white);
  c.drawCircle(pusat, 5, Paint()..color = warna);
  return _bitmap(rekam, d, d, dpr);
}

Future<BitmapDescriptor> _bitmap(
  ui.PictureRecorder rekam,
  double w,
  double h,
  double dpr,
) async {
  final img = await rekam.endRecording().toImage(
    (w * dpr).ceil(),
    (h * dpr).ceil(),
  );
  final png = await img.toByteData(format: ui.ImageByteFormat.png);
  img.dispose();
  return BitmapDescriptor.bytes(
    png!.buffer.asUint8List(),
    imagePixelRatio: dpr,
  );
}

/// Preview (tidak interaktif) lokasi reklame yang sudah dipilih: pin
/// reklame, posisi petugas, garis jarak, lalu alamat & jarak di bawahnya.
class PetaLokasiReklame extends StatefulWidget {
  final SurveyLokasiHasil lokasi;
  final double tinggi;

  const PetaLokasiReklame({super.key, required this.lokasi, this.tinggi = 150});

  @override
  State<PetaLokasiReklame> createState() => _PetaLokasiReklameState();
}

class _PetaLokasiReklameState extends State<PetaLokasiReklame> {
  Set<Marker> _marker = const {};
  AppPalette? _paletteIkon;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final palette = context.palette;
    if (!identical(palette, _paletteIkon)) {
      _paletteIkon = palette;
      _buatMarker(palette, MediaQuery.devicePixelRatioOf(context));
    }
  }

  Future<void> _buatMarker(AppPalette palette, double dpr) async {
    final l = widget.lokasi;
    final pin = await ikonPinReklame(palette.accent, dpr);
    final petugas = await ikonPetugas(palette.statusProses, dpr);
    if (!mounted) return;
    setState(() {
      _marker = {
        Marker(
          markerId: const MarkerId('petugas'),
          position: LatLng(l.petugasLat, l.petugasLng),
          icon: petugas,
          anchor: const Offset(0.5, 0.5),
        ),
        Marker(
          markerId: const MarkerId('reklame'),
          position: LatLng(l.lat, l.lng),
          icon: pin,
          anchor: const Offset(0.5, 1),
          zIndexInt: 1,
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l = widget.lokasi;
    final alamat = SurveyLokasiUiHelper.alamat(l.alamat);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: widget.tinggi,
            child: AbsorbPointer(
              child: GoogleMap(
                // Lite mode: gambar peta statis, ringan di dalam daftar.
                liteModeEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    (l.lat + l.petugasLat) / 2,
                    (l.lng + l.petugasLng) / 2,
                  ),
                  zoom: zoomPetaReklame - 0.5,
                ),
                markers: _marker,
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('jarak'),
                    points: [
                      LatLng(l.petugasLat, l.petugasLng),
                      LatLng(l.lat, l.lng),
                    ],
                    color: palette.accent,
                    width: 3,
                    patterns: [PatternItem.dash(12), PatternItem.gap(6)],
                  ),
                },
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on_rounded, size: 16, color: palette.accent),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                alamat.detail,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: palette.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.straighten_rounded,
              size: 16,
              color: palette.textTertiary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${SurveyLokasiUiHelper.jarak(l.jarakMeter)} dari posisi '
                'petugas · ${l.lat.toStringAsFixed(6)}, '
                '${l.lng.toStringAsFixed(6)}',
                style: TextStyle(fontSize: 11.5, color: palette.textTertiary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
