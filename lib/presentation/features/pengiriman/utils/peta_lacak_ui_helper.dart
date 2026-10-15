import 'dart:math' as math;
import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/pengiriman/berkas_entity.dart';
import '../../../../domain/entities/pengiriman/jejak_entity.dart';

/// Jenis pin di peta lacak: posisi petugas saat transit (ikon motor),
/// check-in di tujuan (tiba/diterima), gagal antar, dan alamat tujuan.
enum JenisPin { transit, tiba, gagal, tujuan }

class PinPeta extends Equatable {
  final double lat;
  final double lng;
  final JenisPin jenis;
  final String label;
  final DateTime? waktu;

  /// Posisi paling akhir petugas (digambar lebih menonjol).
  final bool terbaru;

  const PinPeta({
    required this.lat,
    required this.lng,
    required this.jenis,
    required this.label,
    this.waktu,
    this.terbaru = false,
  });

  @override
  List<Object?> get props => [lat, lng, jenis, label, waktu, terbaru];
}

/// Pusat + zoom awal peta, dan proyeksi koordinat → posisi piksel
/// (Web Mercator, sama dengan Google Maps).
class ViewportPeta {
  final double lat;
  final double lng;
  final int zoom;

  const ViewportPeta({
    required this.lat,
    required this.lng,
    required this.zoom,
  });

  Offset posisi(double lat, double lng, Size ukuran) {
    final p = _dunia(lat, lng, zoom);
    final c = _dunia(this.lat, this.lng, zoom);
    return Offset(
      p.dx - c.dx + ukuran.width / 2,
      p.dy - c.dy + ukuran.height / 2,
    );
  }
}

class PetaLacakUiHelper {
  static const int zoomMaks = 17;
  static const int zoomTunggal = 16;

  static JenisPin jenisDari(StatusBerkas s) => switch (s) {
    StatusBerkas.tiba || StatusBerkas.diterima => JenisPin.tiba,
    StatusBerkas.gagalAntar || StatusBerkas.tidakTerkirim => JenisPin.gagal,
    _ => JenisPin.transit,
  };

  /// Pin urut kronologis (lama → baru) dari [jejak] (terbaru di atas) yang
  /// punya koordinat, plus pin [JenisPin.tujuan] bila koordinat tujuan ada.
  static List<PinPeta> pin(
    List<JejakEntity> jejak, {
    double? latTujuan,
    double? longTujuan,
    String labelTujuan = 'Alamat tujuan',
  }) {
    final berkoordinat = jejak.reversed.where((j) => j.punyaKoordinat).toList();
    return [
      if (latTujuan != null && longTujuan != null)
        PinPeta(
          lat: latTujuan,
          lng: longTujuan,
          jenis: JenisPin.tujuan,
          label: labelTujuan,
        ),
      for (var i = 0; i < berkoordinat.length; i++)
        PinPeta(
          lat: berkoordinat[i].latitude!,
          lng: berkoordinat[i].longitude!,
          jenis: jenisDari(berkoordinat[i].status),
          label: berkoordinat[i].statusNama,
          waktu: berkoordinat[i].tglCheckin,
          terbaru: i == berkoordinat.length - 1,
        ),
    ];
  }

  /// Zoom terbesar yang memuat semua [pin] dengan jarak [tepi] piksel dari
  /// sisi peta; satu titik saja memakai [zoomTunggal].
  static ViewportPeta? viewport(
    List<PinPeta> pin,
    Size ukuran, {
    double tepi = 32,
  }) {
    if (pin.isEmpty) return null;
    final lats = pin.map((p) => p.lat);
    final lngs = pin.map((p) => p.lng);
    final minLat = lats.reduce(math.min), maxLat = lats.reduce(math.max);
    final minLng = lngs.reduce(math.min), maxLng = lngs.reduce(math.max);
    final lat = (minLat + maxLat) / 2, lng = (minLng + maxLng) / 2;

    if (minLat == maxLat && minLng == maxLng) {
      return ViewportPeta(lat: lat, lng: lng, zoom: zoomTunggal);
    }

    final lebar = math.max(ukuran.width - 2 * tepi, 1);
    final tinggi = math.max(ukuran.height - 2 * tepi, 1);
    for (var z = zoomMaks; z > 1; z--) {
      final a = _dunia(maxLat, minLng, z), b = _dunia(minLat, maxLng, z);
      if (b.dx - a.dx <= lebar && b.dy - a.dy <= tinggi) {
        return ViewportPeta(lat: lat, lng: lng, zoom: z);
      }
    }
    return ViewportPeta(lat: lat, lng: lng, zoom: 1);
  }
}

/// Koordinat piksel dunia Web Mercator (ubin 256 px) pada [zoom].
Offset _dunia(double lat, double lng, int zoom) {
  final skala = 256.0 * (1 << zoom);
  final sinLat = math.sin(lat * math.pi / 180).clamp(-0.9999, 0.9999);
  return Offset(
    (lng + 180) / 360 * skala,
    (0.5 - math.log((1 + sinLat) / (1 - sinLat)) / (4 * math.pi)) * skala,
  );
}
