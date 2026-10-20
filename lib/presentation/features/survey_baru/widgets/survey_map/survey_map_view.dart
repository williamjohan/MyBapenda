// [UBAH TOTAL] flutter_map (OpenStreetMap)  ->  Google Maps.
//
// Yang hilang dari versi lama:
//  - _Pin, _PinPainter  -> diganti gambar pin di survey_pin_icons.dart
//  - _UserDot           -> diganti titik biru bawaan Google (tanpa animasi,
//                          jadi tidak ada animasi 60 fps yang memberatkan HP)
//  - lingkaran akurasi & atribusi OSM -> sudah ditangani Google
import 'dart:math' as math;

import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_map/survey_map_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'survey_deadline.dart';
import 'survey_map_controller.dart';
import 'survey_map_point.dart';
import 'survey_pin_icons.dart';
import 'survey_route.dart';

const _blue = Color(0xFF3B6FF5);
const _skipGrey = Color(0xFF9AA5B1);

class SurveyMapView extends StatefulWidget {
  final SurveyMapController controller;
  final SurveyMapState data;
  final String? selectedId;
  final ValueChanged<String?> onSelect;
  final bool showRoute;
  final VoidCallback onFit;
  final VoidCallback onLocate;

  /// Jarak dari atas untuk chip & tombol (layar penuh punya top bar).
  final double topInset;

  /// [BARU] Bagian peta yang tertutup sesuatu (top bar / sheet). Kamera dan
  /// logo Google akan menghindarinya. Pengganti `padding` di CameraFit lama.
  final EdgeInsets mapPadding;

  /// [BARU] false = peta tidak bisa digeser/di-zoom (ketuk pin tetap bisa).
  /// Dipakai di kartu mini supaya scroll halaman tidak "tersangkut" di peta
  /// dan peta tidak perlu memproses gestur.
  final bool interactive;

  const SurveyMapView({
    super.key,
    required this.controller,
    required this.data,
    required this.selectedId,
    required this.onSelect,
    required this.showRoute,
    required this.onFit,
    required this.onLocate,
    this.topInset = 0,
    this.mapPadding = EdgeInsets.zero,
    this.interactive = true,
  });

  @override
  State<SurveyMapView> createState() => _SurveyMapViewState();
}

class _SurveyMapViewState extends State<SurveyMapView> {
  // Pin kecil: 2x sudah tajam. Lebih dari itu hanya memboroskan RAM.
  double _dpr = 2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dpr = math.min(MediaQuery.devicePixelRatioOf(context), 2.0);
    _prepareIcons();
  }

  @override
  void didUpdateWidget(SurveyMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _prepareIcons();
  }

  @override
  void dispose() {
    widget.controller.detach();
    super.dispose();
  }

  // ---- Pin ----

  PinSpec _specOf(SurveyMapPoint p, SurveyPlan plan) {
    final skipped = plan.isSkipped(p.id);
    final number = plan.numberOf(p.id);
    return (
      label: skipped ? '–' : (number > 99 ? '99+' : '$number'),
      color: skipped ? _skipGrey : SurveyDeadline.styleOf(p.daysLeft).fg,
      selected: p.id == widget.selectedId,
      pinned: plan.isPinned(p.id),
    );
  }

  /// Gambar pin yang belum ada dibuat satu per satu (bukan serentak) supaya
  /// lonjakan memori kecil. Pin yang sudah pernah dibuat langsung dipakai.
  Future<void> _prepareIcons() async {
    if (!TickerMode.of(context)) return; // peta sedang dilepas
    final plan = widget.data.plan;
    final missing = [
      for (final p in widget.data.points)
        if (SurveyPinIcons.peek(_specOf(p, plan)) == null) _specOf(p, plan),
    ];
    if (missing.isEmpty) return;

    var sinceRefresh = 0;
    for (final spec in missing) {
      await SurveyPinIcons.ensure(spec, _dpr);
      // Tampilkan bertahap tiap 10 pin supaya tidak menunggu semuanya.
      if (++sinceRefresh == 10 && mounted) {
        sinceRefresh = 0;
        setState(() {});
      }
    }
    if (mounted) setState(() {});
  }

  Set<Marker> _markers(SurveyPlan plan) {
    final markers = <Marker>{};
    for (final p in widget.data.points) {
      final spec = _specOf(p, plan);
      final icon = SurveyPinIcons.peek(spec);
      if (icon == null) continue; // gambar pin masih dibuat

      markers.add(
        Marker(
          markerId: MarkerId(p.id),
          position: p.position,
          icon: icon,
          anchor: const Offset(0.5, 1), // ujung bawah pin = koordinat
          consumeTapEvents: true, // tanpa gerak kamera / info window bawaan
          zIndexInt: spec.selected ? 3 : 1, // pin terpilih paling atas
          onTap: () => widget.onSelect(p.id),
        ),
      );
    }
    return markers;
  }

  // ---- Status di pojok peta ----

  ({String text, bool busy})? _status(SurveyPlan plan) {
    final data = widget.data;
    if (widget.showRoute && data.loadingRoute) {
      return (text: 'Menghitung rute…', busy: true);
    }
    if (data.locating) return (text: 'Mencari lokasimu…', busy: true);
    final r = data.validRouteFor(plan);
    if (widget.showRoute && r != null && !r.isRoad) {
      return (text: 'Rute perkiraan', busy: false);
    }
    if (data.locDenied) return (text: 'Lokasi tidak aktif', busy: false);
    if (data.gps != null && plan.from == null) {
      return (text: 'Posisimu jauh dari tugas', busy: false);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Halaman ini sedang tertutup halaman lain (mis. layar survey)? Lepas peta
    // Google. Ini penghemat RAM terbesar: tidak ada dua peta hidup sekaligus.
    // Peta dibuat lagi otomatis begitu halaman ini terlihat kembali.
    if (!TickerMode.of(context)) return const _MapPlaceholder();

    final data = widget.data;
    final plan = data.plan;
    final route = widget.showRoute ? data.validRouteFor(plan) : null;
    final status = _status(plan);

    return Stack(
      fit: StackFit.expand,
      children: [
        GoogleMap(
          initialCameraPosition: SurveyMapController.initialCamera(data),
          onMapCreated: (g) {
            widget.controller.attach(g);
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) widget.controller.fit(widget.data, animate: false);
            });
          },
          padding: widget.mapPadding,
          markers: _markers(plan),
          polylines: {
            if (route != null)
              Polyline(
                polylineId: const PolylineId('rute'),
                points: route.line,
                width: 5,
                color: _blue,
                jointType: JointType.round,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
                // Rute perkiraan (garis lurus) digambar putus-putus.
                patterns: route.isRoad
                    ? const []
                    : [PatternItem.dash(16), PatternItem.gap(8)],
              ),
          },
          onTap: (_) => widget.onSelect(null),

          // Titik biru bawaan Google = posisi petugas (hanya bila GPS sudah
          // didapat, berarti izin lokasi sudah diberikan).
          myLocationEnabled: data.gps != null,
          myLocationButtonEnabled: false,

          // Matikan semua yang tidak dipakai: lebih ringan di GPU dan RAM.
          buildingsEnabled: false,
          indoorViewEnabled: false,
          trafficEnabled: false,
          tiltGesturesEnabled: false,
          rotateGesturesEnabled: false,
          compassEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          scrollGesturesEnabled: widget.interactive,
          zoomGesturesEnabled: widget.interactive,
          gestureRecognizers: widget.interactive
              ? {
                  Factory<OneSequenceGestureRecognizer>(
                    EagerGestureRecognizer.new,
                  ),
                }
              : const <Factory<OneSequenceGestureRecognizer>>{},
          minMaxZoomPreference: const MinMaxZoomPreference(10, 18),
        ),
        if (status != null)
          Positioned(
            top: 8 + widget.topInset,
            left: 8,
            child: _MapChip(text: status.text, busy: status.busy),
          ),
        Positioned(
          top: 8 + widget.topInset,
          right: 8,
          child: Column(
            children: [
              _MapButton(
                icon: Icons.center_focus_strong_rounded,
                tooltip: 'Tampilkan semua',
                onTap: widget.onFit,
              ),
              const SizedBox(height: 8),
              _MapButton(
                icon: Icons.my_location_rounded,
                tooltip: 'Posisiku',
                busy: data.locating,
                highlight: data.gps != null,
                onTap: widget.onLocate,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// [BARU] Pengganti peta saat halaman tertutup halaman lain.
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: ColoredBox(
        color: Color(0xFFEEF0F3),
        child: Center(
          child: Icon(Icons.map_outlined, size: 32, color: Color(0xFFB4BCC6)),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Widget kecil di atas peta (TIDAK BERUBAH dari versi lama)
// ----------------------------------------------------------------------------

/// Chip "Rute" (nyala/mati).
class SurveyRouteToggle extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const SurveyRouteToggle({
    super.key,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFB8680F);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFF4E5) : const Color(0xFFF5F6F8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? accent.withValues(alpha: 0.35) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.alt_route_rounded,
              size: 15,
              color: active ? accent : const Color(0xFF7B8794),
            ),
            const SizedBox(width: 5),
            Text(
              'Rute',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: active ? accent : const Color(0xFF7B8794),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapChip extends StatelessWidget {
  final String text;
  final bool busy;

  const _MapChip({required this.text, required this.busy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (busy)
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: _blue),
            )
          else
            const Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: Color(0xFF7B8794),
            ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E4C59),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool busy;
  final bool highlight;

  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.busy = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        elevation: 0,
        shape: const CircleBorder(side: BorderSide(color: Color(0xFFE5E7EB))),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: busy ? null : onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Center(
              child: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _blue,
                      ),
                    )
                  : Icon(
                      icon,
                      size: 20,
                      color: highlight ? _blue : const Color(0xFF52606D),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
