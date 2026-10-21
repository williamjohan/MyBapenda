import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:injectable/injectable.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_map/survey_map_point.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_map/survey_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    show LatLng; 
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/services/geo_location/i_geo_location_service.dart';
import 'survey_map_state.dart';

@injectable
class SurveyMapCubit extends Cubit<SurveyMapState> {
  final IGeoLocationService _geolocationService;
  
 SurveyMapCubit(this._geolocationService)
    : super(
        SurveyMapState(),
      ); 

  static const _prefix = 'survey_map_';

  Timer? _debounce;
  int _reqId = 0;
  String? _requestedKey;

  static String get _dayKey {
    final n = DateTime.now();
    String p(int v) => v.toString().padLeft(2, '0');
    return '$_prefix${n.year}-${p(n.month)}-${p(n.day)}';
  }

  Future<void> start() async {
    await _load();
    await locate();
  }

  // ---- Data tugas ----

  void setPoints(List<SurveyMapPoint> points) {
    emit(state.copyWith(points: points));
    _refreshRoute();
  }

  // ---- Posisi petugas ----

  Future<void> locate() async {
    if (state.locating) return;
    emit(state.copyWith(locating: true));

    final locationResult = await _geolocationService.getCurrentPosition();

    if (isClosed) return;

    locationResult.fold(
      // =======================================================================
      // KONDISI GAGAL (Left: Failure)
      // =======================================================================
      (failure) {
        // Jika gagal mendapatkan lokasi, tandai locDenied jika GPS awal memang belum ada
        emit(state.copyWith(locDenied: state.gps == null));
      },

      // =======================================================================
      // KONDISI SUKSES (Right: GeoPosition)
      // =======================================================================
      (fix) {
        emit(
          state.copyWith(
            gps: LatLng(fix.latitude, fix.longitude),
            accuracy: fix.akurasiMeter.toDouble(),
            locDenied: false,
          ),
        );
        _refreshRoute();
      },
    );

    if (!isClosed) {
      emit(state.copyWith(locating: false));
    }
  }

  // ---- Prioritas ----

  /// "Kerjakan Dulu": jadikan nomor 1, sisanya menyesuaikan.
  void doFirst(String id) {
    _setManual(
      pinned: [id, ...state.pinned.where((e) => e != id)],
      skipped: {...state.skipped}..remove(id),
    );
  }

  /// Geser baris. Semua baris dari atas sampai baris terdampak dikunci.
  /// [newIndex] mengikuti konvensi ReorderableListView.
  void move(int oldIndex, int newIndex) {
    final ids = [for (final p in state.plan.order) p.id];
    if (oldIndex < 0 || oldIndex >= ids.length) return;
    if (newIndex > oldIndex) newIndex -= 1;
    final id = ids.removeAt(oldIndex);
    ids.insert(newIndex, id);

    final locked = state.plan.pinnedIds.length; // kunci lama tidak hilang
    final keep = math.max(math.max(oldIndex, newIndex) + 1, locked);
    _setManual(pinned: ids.sublist(0, math.min(keep, ids.length)));
  }

  void skip(String id) => _setManual(
    pinned: state.pinned.where((e) => e != id).toList(),
    skipped: {...state.skipped, id},
  );

  void unskip(String id) => _setManual(skipped: {...state.skipped}..remove(id));

  void reset() => _setManual(pinned: const [], skipped: const <String>{});

  void _setManual({List<String>? pinned, Set<String>? skipped}) {
    emit(state.copyWith(pinned: pinned, skipped: skipped));
    _save();
    _refreshRoute();
  }

  // ---- Rute ----

  void _refreshRoute() {
    final plan = state.plan;
    final wps = [
      if (plan.from != null) plan.from!,
      for (final p in plan.order) p.position,
    ];
    final key = plan.key;

    if (wps.length < 2) {
      _debounce?.cancel();
      _requestedKey = key;
      emit(state.copyWith(clearRoute: true, loadingRoute: false));
      return;
    }
    if (key == _requestedKey) return;
    _requestedKey = key;

    final id = ++_reqId;
    emit(state.copyWith(loadingRoute: true));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final r = await SurveyRouteService.fetch(wps);
      if (isClosed || id != _reqId) return; // hasil basi diabaikan
      emit(
        state.copyWith(
          route: r,
          routeKey: key,
          routeHasFrom: plan.from != null,
          loadingRoute: false,
        ),
      );
    });
  }

  // ---- Simpan per hari ----

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Prioritas hari-hari sebelumnya tidak berlaku lagi.
      for (final k in prefs.getKeys().toList()) {
        if (k.startsWith(_prefix) && k != _dayKey) await prefs.remove(k);
      }
      final raw = prefs.getString(_dayKey);
      if (raw == null || isClosed) return;
      final m = jsonDecode(raw) as Map<String, dynamic>;
      emit(
        state.copyWith(
          pinned: [for (final e in (m['pinned'] as List? ?? const [])) '$e'],
          skipped: {for (final e in (m['skipped'] as List? ?? const [])) '$e'},
        ),
      );
      _refreshRoute();
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _dayKey,
        jsonEncode({'pinned': state.pinned, 'skipped': state.skipped.toList()}),
      );
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
