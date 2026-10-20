import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    show LatLng; // [UBAH] dulu latlong2
import 'survey_map_point.dart';

String fmtKm(double m) => m < 1000
    ? '${m.round()} m'
    : '${(m / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';

String fmtDur(double s) {
  final min = (s / 60).round().clamp(1, 100000);
  if (min < 60) return '$min mnt';
  final h = min ~/ 60;
  final r = min % 60;
  return r == 0 ? '$h j' : '$h j $r mnt';
}

typedef RouteLeg = ({double meters, double seconds});

class SurveyRouteResult {
  final List<LatLng> line;
  final double meters;
  final double seconds;
  final List<RouteLeg> legs;

  /// true = rute jalan (OSRM), false = garis lurus (perkiraan).
  final bool isRoad;

  const SurveyRouteResult({
    required this.line,
    required this.meters,
    required this.seconds,
    required this.legs,
    required this.isRoad,
  });
}

/// Hasil penyusunan urutan: tugas aktif berurutan + tugas yang dilewati.
class SurveyPlan {
  final List<SurveyMapPoint> order;
  final List<SurveyMapPoint> skipped;

  /// Id tugas yang dikunci manual oleh petugas (selalu di awal [order]).
  final Set<String> pinnedIds;

  /// Posisi petugas yang dipakai untuk rute (null bila tidak masuk akal).
  final LatLng? from;

  const SurveyPlan({
    required this.order,
    required this.skipped,
    required this.pinnedIds,
    required this.from,
  });

  /// 1-based. 0 kalau tidak ada di urutan (mis. dilewati).
  int numberOf(String id) => order.indexWhere((e) => e.id == id) + 1;
  bool isSkipped(String id) => skipped.any((e) => e.id == id);
  bool isPinned(String id) => pinnedIds.contains(id);

  /// Jarak garis lurus total, untuk membandingkan dua urutan.
  double straightMeters() {
    var total = 0.0;
    LatLng? cur = from;
    for (final p in order) {
      if (cur != null) total += SurveyRoutePlanner.meters(cur, p.position);
      cur = p.position;
    }
    return total;
  }

  /// Nomor urut tugas mendesak yang berada setelah tugas biasa.
  List<int> get lateUrgent {
    final firstNormal = order.indexWhere((p) => (p.daysLeft ?? 999) > 0);
    if (firstNormal < 0) return const [];
    return [
      for (var i = firstNormal + 1; i < order.length; i++)
        if ((order[i].daysLeft ?? 999) <= 0) i + 1,
    ];
  }

  /// Berubah kalau urutan atau posisi berubah. Dipakai untuk cache rute.
  String get key {
    final f = from;
    final fs = f == null
        ? '-'
        : '${f.latitude.toStringAsFixed(3)},${f.longitude.toStringAsFixed(3)}';
    return '$fs#${order.map((e) => e.id).join('|')}';
  }
}

class SurveyRoutePlanner {
  SurveyRoutePlanner._();

  /// [UBAH] Jarak garis lurus dua titik (rumus haversine), dalam meter.
  /// Dulu memakai `Distance` dari latlong2; sekarang tanpa paket tambahan.
  static double meters(LatLng a, LatLng b) {
    const earthRadius = 6371000.0;
    double rad(double deg) => deg * math.pi / 180;

    final dLat = rad(b.latitude - a.latitude);
    final dLng = rad(b.longitude - a.longitude);
    final sinLat = math.sin(dLat / 2);
    final sinLng = math.sin(dLng / 2);
    final h =
        sinLat * sinLat +
        math.cos(rad(a.latitude)) * math.cos(rad(b.latitude)) * sinLng * sinLng;

    return 2 * earthRadius * math.asin(math.sqrt(h.clamp(0.0, 1.0)));
  }

  /// Posisi petugas dipakai hanya kalau < 60 km dari tugas terdekat
  /// (emulator di luar negeri tidak merusak peta).
  static LatLng? usableFrom(LatLng? from, List<SurveyMapPoint> pts) {
    if (from == null || pts.isEmpty) return null;
    final nearest = pts.map((p) => meters(from, p.position)).reduce(math.min);
    return nearest < 60000 ? from : null;
  }

  /// [pinned] = urutan manual (dikunci di awal), [skipped] = dilewati.
  /// Sisanya: mendesak dulu (urut tenggat), lalu tetangga terdekat.
  static SurveyPlan plan(
    List<SurveyMapPoint> pts, {
    LatLng? from,
    List<String> pinned = const [],
    Set<String> skipped = const {},
  }) {
    final byId = {for (final p in pts) p.id: p};
    final skippedPts = [
      for (final p in pts)
        if (skipped.contains(p.id)) p,
    ];
    final start = usableFrom(from, pts);

    final out = <SurveyMapPoint>[];
    final locked = <String>{};
    for (final id in pinned) {
      final p = byId[id];
      if (p == null || skipped.contains(id) || locked.contains(id)) continue;
      out.add(p);
      locked.add(id);
    }

    final rest = [
      for (final p in pts)
        if (!skipped.contains(p.id) && !locked.contains(p.id)) p,
    ];
    out.addAll(_auto(rest, from: out.isNotEmpty ? out.last.position : start));

    return SurveyPlan(
      order: out,
      skipped: skippedPts,
      pinnedIds: locked,
      from: start,
    );
  }

  static List<SurveyMapPoint> _auto(List<SurveyMapPoint> pts, {LatLng? from}) {
    final urgent = pts.where((p) => (p.daysLeft ?? 999) <= 0).toList()
      ..sort((a, b) => a.daysLeft!.compareTo(b.daysLeft!));
    final rest = pts.where((p) => (p.daysLeft ?? 999) > 0).toList();

    final out = <SurveyMapPoint>[...urgent];
    LatLng? cursor = out.isNotEmpty ? out.last.position : from;

    if (cursor == null && rest.isNotEmpty) {
      rest.sort((a, b) => (a.daysLeft ?? 999).compareTo(b.daysLeft ?? 999));
      final first = rest.removeAt(0);
      out.add(first);
      cursor = first.position;
    }

    // [UBAH] Dulu: sort ulang seluruh daftar di setiap langkah (berat di HP
    // lawas). Sekarang cukup cari satu titik terdekat per langkah.
    while (rest.isNotEmpty) {
      final next = _nearest(rest, cursor!);
      rest.remove(next);
      out.add(next);
      cursor = next.position;
    }
    return out;
  }

  /// [BARU] Titik di [pts] yang paling dekat ke [from].
  static SurveyMapPoint _nearest(List<SurveyMapPoint> pts, LatLng from) {
    var best = pts.first;
    var bestDistance = meters(from, best.position);
    for (final p in pts.skip(1)) {
      final d = meters(from, p.position);
      if (d < bestDistance) {
        best = p;
        bestDistance = d;
      }
    }
    return best;
  }
}

class SurveyRouteService {
  SurveyRouteService._();

  /// [UBAH] Alamat server rute dipisah di sini supaya gampang diganti.
  ///
  /// TODO: ini SATU-SATUNYA bagian yang masih "uji coba". Server publik OSRM
  /// tidak untuk produksi (ada batas pemakaian, tanpa jaminan hidup). Sebelum
  /// rilis: pasang OSRM sendiri, atau minta backend meneruskan ke layanan rute
  /// berbayar. Cukup ganti alamat ini, format jawabannya sama untuk OSRM.
  static const _routeUrl = 'https://router.project-osrm.org/route/v1/driving';

  /// [BARU] Titik rute yang lebih rapat dari ini dibuang. Rute asli bisa
  /// berisi ribuan titik; di layar HP tidak terlihat bedanya, tapi RAM-nya
  /// jauh lebih hemat.
  static const _minPointGapMeters = 12.0;

  // Dio terpisah: token API tidak boleh terkirim ke server lain.
  static final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      headers: {'User-Agent': 'com.bapenda.cekreklame'},
    ),
  );

  static Future<SurveyRouteResult> fetch(List<LatLng> waypoints) async {
    try {
      final coords = waypoints
          .map((p) => '${p.longitude},${p.latitude}')
          .join(';');
      final res = await _dio.get(
        '$_routeUrl/$coords',
        queryParameters: {'overview': 'full', 'geometries': 'geojson'},
      );

      final data = res.data as Map;
      if (data['code'] != 'Ok') {
        debugPrint('OSRM: code=${data['code']} ${data['message'] ?? ''}');
        return _straight(waypoints);
      }
      final routes = data['routes'] as List? ?? const [];
      if (routes.isEmpty) return _straight(waypoints);

      final r = routes.first as Map;
      final line = _thin(r['geometry']['coordinates'] as List);
      if (line.length < 2) return _straight(waypoints);

      final legs = <RouteLeg>[
        for (final l in (r['legs'] as List))
          (
            meters: (l['distance'] as num).toDouble(),
            seconds: (l['duration'] as num).toDouble(),
          ),
      ];

      return SurveyRouteResult(
        line: line,
        meters: (r['distance'] as num).toDouble(),
        seconds: (r['duration'] as num).toDouble(),
        legs: legs,
        isRoad: true,
      );
    } catch (e) {
      debugPrint('OSRM error: $e');
      return _straight(waypoints);
    }
  }

  /// [BARU] Ubah koordinat GeoJSON [[lng, lat], ...] jadi daftar LatLng,
  /// sambil membuang titik yang terlalu rapat. Titik awal & akhir dipertahankan.
  static List<LatLng> _thin(List coords) {
    final out = <LatLng>[];
    for (var i = 0; i < coords.length; i++) {
      final c = coords[i] as List;
      final p = LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble());
      final isEdge = i == 0 || i == coords.length - 1;
      if (isEdge ||
          SurveyRoutePlanner.meters(out.last, p) >= _minPointGapMeters) {
        out.add(p);
      }
    }
    return out;
  }

  /// Cadangan: garis lurus, jarak x1,3, kecepatan kota 25 km/jam.
  static SurveyRouteResult _straight(List<LatLng> wps) {
    const mps = 25 * 1000 / 3600;
    final legs = <RouteLeg>[];
    var total = 0.0;
    for (var i = 0; i < wps.length - 1; i++) {
      final m = SurveyRoutePlanner.meters(wps[i], wps[i + 1]) * 1.3;
      legs.add((meters: m, seconds: m / mps));
      total += m;
    }
    return SurveyRouteResult(
      line: wps,
      meters: total,
      seconds: total / mps,
      legs: legs,
      isRoad: false,
    );
  }
}
