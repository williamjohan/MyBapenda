import 'dart:math' as math;

import 'package:mybapenda/presentation/features/survey_baru/cubit/survey_map/survey_map_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

typedef _Bounds = ({double south, double north, double west, double east});

class SurveyMapController {
  GoogleMapController? _map;

  static const _fitPadding = 56.0;

  /// Bila semua titik berada dalam kotak sekecil ini (derajat, ± 400 m),
  /// jangan zoom sedekat mungkin: pakai zoom tetap.
  static const _tightSpread = 0.004;
  static const _tightZoom = 16.0;

  /// Hanya dipakai kalau tidak ada titik sama sekali (kartu menyembunyikan
  /// peta dalam kondisi itu, jadi praktis tidak pernah terlihat).
  static const _fallbackCenter = LatLng(-2.5, 118.0);

  void attach(GoogleMapController map) => _map = map;
  void detach() => _map = null;

  // ---- Kamera awal ----

  /// Kamera sementara = tengah semua titik. Begitu peta siap, fit() menyusul
  /// dan mengepaskan zoom-nya.
  static CameraPosition initialCamera(SurveyMapState s) {
    final coords = _coordsOf(s);
    if (coords.isEmpty) {
      return const CameraPosition(target: _fallbackCenter, zoom: 10);
    }
    return CameraPosition(target: _centerOf(_boundsOf(coords)), zoom: 12);
  }

  // ---- Perintah kamera ----

  /// Tampilkan semua tugas (+ posisi petugas bila dipakai untuk rute).
  Future<void> fit(SurveyMapState s, {bool animate = true}) {
    final coords = _coordsOf(s);
    if (coords.isEmpty) return Future.value();
    return _run(_updateFor(coords), animate: animate);
  }

  /// Dekati satu titik. Zoom tidak diturunkan bila sudah lebih dekat.
  Future<void> focus(LatLng point, {double minZoom = 15}) async {
    final map = _map;
    if (map == null) return;
    try {
      final zoom = math.max(await map.getZoomLevel(), minZoom);
      await map.animateCamera(CameraUpdate.newLatLngZoom(point, zoom));
    } catch (_) {
      // Peta sudah dilepas: abaikan.
    }
  }

  Future<void> moveTo(LatLng point, double zoom) =>
      _run(CameraUpdate.newLatLngZoom(point, zoom));

  // ---- Bagian dalam ----

  Future<void> _run(CameraUpdate update, {bool animate = true}) async {
    final map = _map;
    if (map == null) return;
    try {
      if (animate) {
        await map.animateCamera(update);
      } else {
        await map.moveCamera(update);
      }
    } catch (_) {
      // Peta belum selesai di-layout atau sudah dilepas: abaikan.
    }
  }

  static List<LatLng> _coordsOf(SurveyMapState s) => [
    for (final p in s.points) p.position,
    if (s.plan.from != null) s.plan.from!,
  ];

  static _Bounds _boundsOf(List<LatLng> coords) {
    var south = coords.first.latitude, north = south;
    var west = coords.first.longitude, east = west;
    for (final c in coords) {
      south = math.min(south, c.latitude);
      north = math.max(north, c.latitude);
      west = math.min(west, c.longitude);
      east = math.max(east, c.longitude);
    }
    return (south: south, north: north, west: west, east: east);
  }

  static LatLng _centerOf(_Bounds b) =>
      LatLng((b.south + b.north) / 2, (b.west + b.east) / 2);

  static CameraUpdate _updateFor(List<LatLng> coords) {
    final b = _boundsOf(coords);
    final tight =
        (b.north - b.south) < _tightSpread && (b.east - b.west) < _tightSpread;

    if (tight) return CameraUpdate.newLatLngZoom(_centerOf(b), _tightZoom);

    return CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(b.south, b.west),
        northeast: LatLng(b.north, b.east),
      ),
      _fitPadding,
    );
  }
}
