import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_map/survey_map_point.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_map/survey_route.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    show LatLng; // [UBAH] dulu latlong2

class SurveyMapState extends Equatable {
  final List<SurveyMapPoint> points;

  /// Urutan manual petugas (id), selalu menjadi awal urutan.
  final List<String> pinned;
  final Set<String> skipped;

  // Posisi petugas
  final LatLng? gps;
  final double accuracy;
  final bool locating;
  final bool locDenied;

  // Rute
  final SurveyRouteResult? route;
  final String? routeKey;
  final bool routeHasFrom;
  final bool loadingRoute;

  // [UBAH] `const` dihapus dari constructor: Dart tidak mengizinkan
  // `late final` di class ber-constructor const (lihat `plan` di bawah).
  SurveyMapState({
    this.points = const [],
    this.pinned = const [],
    this.skipped = const <String>{},
    this.gps,
    this.accuracy = 0,
    this.locating = false,
    this.locDenied = false,
    this.route,
    this.routeKey,
    this.routeHasFrom = false,
    this.loadingRoute = false,
  });

  /// [UBAH] Urutan kunjungan. Dulu `get` yang menghitung ulang (sort + jarak)
  /// setiap kali dibaca, padahal dibaca belasan kali tiap rebuild. Sekarang
  /// dihitung sekali per state, lalu dipakai ulang.
  late final SurveyPlan plan = SurveyRoutePlanner.plan(
    points,
    from: gps,
    pinned: pinned,
    skipped: skipped,
  );

  bool isCustomized(SurveyPlan p) =>
      p.pinnedIds.isNotEmpty || p.skipped.isNotEmpty;

  /// Selisih jarak (garis lurus) dibanding urutan saran, dengan tugas
  /// dilewati yang sama.
  double extraMeters(SurveyPlan p) {
    final base = SurveyRoutePlanner.plan(points, from: gps, skipped: skipped);
    return p.straightMeters() - base.straightMeters();
  }

  /// Rute hanya dianggap sah kalau cocok dengan urutan sekarang.
  SurveyRouteResult? validRouteFor(SurveyPlan p) =>
      (route != null && routeKey == p.key) ? route : null;

  String? legText(SurveyPlan p, String id) {
    final r = validRouteFor(p);
    if (r == null) return null;
    final i = p.order.indexWhere((e) => e.id == id);
    if (i < 0) return null;
    final idx = routeHasFrom ? i : i - 1;
    if (idx < 0 || idx >= r.legs.length) return null;
    final leg = r.legs[idx];
    final asal = (routeHasFrom && i == 0) ? 'posisimu' : 'titik sebelumnya';
    return '${fmtKm(leg.meters)} · ${fmtDur(leg.seconds)} dari $asal';
  }

  SurveyMapState copyWith({
    List<SurveyMapPoint>? points,
    List<String>? pinned,
    Set<String>? skipped,
    LatLng? gps,
    double? accuracy,
    bool? locating,
    bool? locDenied,
    SurveyRouteResult? route,
    String? routeKey,
    bool? routeHasFrom,
    bool? loadingRoute,
    bool clearRoute = false,
  }) => SurveyMapState(
    points: points ?? this.points,
    pinned: pinned ?? this.pinned,
    skipped: skipped ?? this.skipped,
    gps: gps ?? this.gps,
    accuracy: accuracy ?? this.accuracy,
    locating: locating ?? this.locating,
    locDenied: locDenied ?? this.locDenied,
    route: clearRoute ? null : route ?? this.route,
    routeKey: clearRoute ? null : routeKey ?? this.routeKey,
    routeHasFrom: routeHasFrom ?? this.routeHasFrom,
    loadingRoute: loadingRoute ?? this.loadingRoute,
  );

  @override
  List<Object?> get props => [
    points,
    pinned,
    skipped,
    gps,
    accuracy,
    locating,
    locDenied,
    route,
    routeKey,
    routeHasFrom,
    loadingRoute,
  ];
}
