import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../../core/utils/date_format_id.dart';
import '../../../../../domain/entities/pengiriman/lacak_entity.dart';
import '../../utils/peta_lacak_ui_helper.dart';

/// Peta Google interaktif riwayat perjalanan: pin per check-in (motor saat
/// transit, bendera saat tiba/diterima, silang saat gagal), pin alamat
/// tujuan, dan jalur jalan antar titik ([rute]). Ketuk pin untuk status &
/// jam; tombol Maps membuka rute yang sama di aplikasi Google Maps.
class PetaLacak extends StatefulWidget {
  /// Urut kronologis (lihat [PetaLacakUiHelper.pin]); tidak boleh kosong.
  final List<PinPeta> pin;

  /// Jalur jalan dari Routes API; null = hanya titik (tanpa garis lurus).
  final List<TitikRute>? rute;
  final double tinggi;

  const PetaLacak({super.key, required this.pin, this.rute, this.tinggi = 200});

  @override
  State<PetaLacak> createState() => _PetaLacakState();
}

class _PetaLacakState extends State<PetaLacak> {
  GoogleMapController? _peta;
  Set<Marker> _marker = const {};
  AppPalette? _paletteIkon;
  ViewportPeta? _awal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final palette = context.palette;
    if (!identical(palette, _paletteIkon)) {
      _paletteIkon = palette;
      _buatMarker(palette, MediaQuery.devicePixelRatioOf(context));
    }
  }

  @override
  void didUpdateWidget(PetaLacak old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.pin, widget.pin) && _paletteIkon != null) {
      _buatMarker(_paletteIkon!, MediaQuery.devicePixelRatioOf(context));
      _pasKamera();
    }
  }

  @override
  void dispose() {
    _peta?.dispose();
    super.dispose();
  }

  Future<void> _buatMarker(AppPalette palette, double dpr) async {
    final hasil = <Marker>{};
    for (var i = 0; i < widget.pin.length; i++) {
      final p = widget.pin[i];
      final tujuan = p.jenis == JenisPin.tujuan;
      final baris = p.label.split('\n');
      hasil.add(
        Marker(
          markerId: MarkerId('pin$i'),
          position: LatLng(p.lat, p.lng),
          icon: await _ikonPin(p, palette, dpr),
          anchor: tujuan ? const Offset(0.5, 1) : const Offset(0.5, 0.5),
          zIndexInt: tujuan ? 0 : (p.terbaru ? 2 : 1),
          infoWindow: InfoWindow(
            title: baris.first,
            snippet: p.waktu != null
                ? '${formatTanggalId(p.waktu!)} ${formatJamId(p.waktu!)}'
                : (baris.length > 1 ? baris.skip(1).join(' ') : null),
          ),
        ),
      );
    }
    if (!mounted) return;
    setState(() => _marker = hasil);
  }

  /// Tampilkan semua pin (dipakai juga oleh tombol "pusatkan").
  void _pasKamera() {
    final peta = _peta;
    if (peta == null) return;
    final pin = widget.pin;
    if (pin.length == 1) {
      peta.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(pin.first.lat, pin.first.lng),
          PetaLacakUiHelper.zoomTunggal.toDouble(),
        ),
      );
      return;
    }
    final lats = pin.map((p) => p.lat), lngs = pin.map((p) => p.lng);
    peta.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            lats.reduce((a, b) => a < b ? a : b),
            lngs.reduce((a, b) => a < b ? a : b),
          ),
          northeast: LatLng(
            lats.reduce((a, b) => a > b ? a : b),
            lngs.reduce((a, b) => a > b ? a : b),
          ),
        ),
        40,
      ),
    );
  }

  Future<void> _bukaMaps() async {
    final uri = PetaLacakUiHelper.urlMaps(widget.pin);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka aplikasi peta')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final rute = [
      for (final t in widget.rute ?? const <TitikRute>[]) LatLng(t.lat, t.lng),
    ];
    final banyakTitik = PetaLacakUiHelper.titikUrut(widget.pin).length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: widget.tinggi,
          child: LayoutBuilder(
            builder: (context, c) {
              // Posisi awal sudah memuat semua pin, jadi tidak "loncat".
              final awal = _awal ??= PetaLacakUiHelper.viewport(
                widget.pin,
                Size(c.maxWidth, widget.tinggi),
              )!;
              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(awal.lat, awal.lng),
                      zoom: awal.zoom.toDouble(),
                    ),
                    onMapCreated: (c) => _peta = c,
                    markers: _marker,
                    polylines: {
                      if (rute.length > 1)
                        Polyline(
                          polylineId: const PolylineId('rute'),
                          points: rute,
                          color: palette.statusProses,
                          width: 5,
                          jointType: JointType.round,
                          startCap: Cap.roundCap,
                          endCap: Cap.roundCap,
                        ),
                    },
                    // Geser/zoom peta tanpa ikut menggulir halaman.
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(
                        EagerGestureRecognizer.new,
                      ),
                    },
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _TombolPeta(
                          icon: banyakTitik
                              ? Icons.directions_rounded
                              : Icons.open_in_new_rounded,
                          label: banyakTitik ? 'Buka Rute' : 'Buka Maps',
                          onTap: _bukaMaps,
                        ),
                        const SizedBox(height: 6),
                        _TombolPeta(
                          icon: Icons.center_focus_strong_rounded,
                          tooltip: 'Tampilkan semua titik',
                          onTap: _pasKamera,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        _Legenda(jenis: {for (final p in widget.pin) p.jenis}),
      ],
    );
  }
}

class _TombolPeta extends StatelessWidget {
  final IconData icon;
  final String? label;
  final String? tooltip;
  final VoidCallback onTap;

  const _TombolPeta({
    required this.icon,
    required this.onTap,
    this.label,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isi = Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(8),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: palette.accent),
              if (label != null) ...[
                const SizedBox(width: 4),
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: palette.accent,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return tooltip == null ? isi : Tooltip(message: tooltip, child: isi);
  }
}

(Color, IconData) _gaya(AppPalette p, JenisPin j) => switch (j) {
  JenisPin.transit => (p.statusProses, Icons.two_wheeler_rounded),
  JenisPin.tiba => (p.statusSukses, Icons.flag_rounded),
  JenisPin.gagal => (p.statusGagal, Icons.close_rounded),
  JenisPin.tujuan => (p.accent, Icons.location_on_rounded),
};

/// Gambar pin sebagai bitmap: lingkaran berwarna + ikon putih, atau jarum
/// lokasi untuk tujuan. Ukuran dalam piksel logis, digambar sesuai [dpr].
Future<BitmapDescriptor> _ikonPin(
  PinPeta pin,
  AppPalette palette,
  double dpr,
) async {
  final (warna, ikon) = _gaya(palette, pin.jenis);
  final tujuan = pin.jenis == JenisPin.tujuan;
  final d = tujuan ? 40.0 : (pin.terbaru ? 34.0 : 24.0);
  final halo = pin.terbaru ? 6.0 : 0.0;
  final sisi = d + halo * 2;

  final rekam = ui.PictureRecorder();
  final kanvas = Canvas(rekam)..scale(dpr);
  final pusat = Offset(sisi / 2, sisi / 2);

  void glyph(Color c, double ukuran) {
    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(ikon.codePoint),
        style: TextStyle(
          fontFamily: ikon.fontFamily,
          package: ikon.fontPackage,
          fontSize: ukuran,
          color: c,
        ),
      ),
    )..layout();
    tp.paint(kanvas, pusat - Offset(tp.width / 2, tp.height / 2));
  }

  if (tujuan) {
    glyph(warna, d);
  } else {
    if (halo > 0) {
      kanvas.drawCircle(
        pusat,
        sisi / 2,
        Paint()..color = warna.withValues(alpha: 0.3),
      );
    }
    kanvas.drawCircle(pusat, d / 2, Paint()..color = Colors.white);
    kanvas.drawCircle(pusat, d / 2 - 2, Paint()..color = warna);
    glyph(Colors.white, d * 0.55);
  }

  final img = await rekam.endRecording().toImage(
    (sisi * dpr).ceil(),
    (sisi * dpr).ceil(),
  );
  final png = await img.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.bytes(
    png!.buffer.asUint8List(),
    imagePixelRatio: dpr,
  );
}

class _Legenda extends StatelessWidget {
  final Set<JenisPin> jenis;
  const _Legenda({required this.jenis});

  static String _label(JenisPin j) => switch (j) {
    JenisPin.transit => 'Posisi petugas',
    JenisPin.tiba => 'Tiba / diterima',
    JenisPin.gagal => 'Gagal antar',
    JenisPin.tujuan => 'Alamat tujuan',
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          for (final j in JenisPin.values)
            if (jenis.contains(j))
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _gaya(palette, j).$2,
                    size: 13,
                    color: _gaya(palette, j).$1,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _label(j),
                    style: TextStyle(
                      fontSize: 11,
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}
