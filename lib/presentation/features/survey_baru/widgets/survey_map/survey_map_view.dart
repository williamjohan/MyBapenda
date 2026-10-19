
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_map/survey_map_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'survey_deadline.dart';
import 'survey_map_point.dart';
import 'survey_route.dart';

const _blue = Color(0xFF3B6FF5);
const _skipGrey = Color(0xFF9AA5B1);

CameraFit surveyFit(
  SurveyMapState s, {
  EdgeInsets padding = const EdgeInsets.fromLTRB(52, 64, 52, 56),
}) => CameraFit.coordinates(
  coordinates: [
    for (final p in s.points) p.position,
    if (s.plan.from != null) s.plan.from!,
  ],
  padding: padding,
  maxZoom: 16,
);

class SurveyMapView extends StatelessWidget {
  final MapController controller;
  final SurveyMapState data;
  final String? selectedId;
  final ValueChanged<String?> onSelect;
  final bool showRoute;
  final VoidCallback onFit;
  final VoidCallback onLocate;
  final CameraFit initialFit;

  /// Jarak dari atas untuk chip & tombol (layar penuh punya top bar).
  final double topInset;

  const SurveyMapView({
    super.key,
    required this.controller,
    required this.data,
    required this.selectedId,
    required this.onSelect,
    required this.showRoute,
    required this.onFit,
    required this.onLocate,
    required this.initialFit,
    this.topInset = 0,
  });

  ({String text, bool busy})? _status(SurveyPlan plan) {
    if (showRoute && data.loadingRoute) {
      return (text: 'Menghitung rute…', busy: true);
    }
    if (data.locating) return (text: 'Mencari lokasimu…', busy: true);
    final r = data.validRouteFor(plan);
    if (showRoute && r != null && !r.isRoad) {
      return (text: 'Rute perkiraan', busy: false);
    }
    if (data.locDenied) return (text: 'Lokasi tidak aktif', busy: false);
    if (data.gps != null && plan.from == null) {
      return (text: 'Posisimu jauh dari tugas', busy: false);
    }
    return null;
  }

  Marker _pin(SurveyMapPoint p, SurveyPlan plan) {
    final skipped = plan.isSkipped(p.id);
    return Marker(
      point: p.position,
      width: 40,
      height: 50,
      alignment: Alignment.topCenter, // ujung bawah pin = koordinat
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect(p.id),
        child: _Pin(
          label: skipped ? '–' : '${plan.numberOf(p.id)}',
          color: skipped ? _skipGrey : SurveyDeadline.styleOf(p.daysLeft).fg,
          selected: p.id == selectedId,
          pinned: plan.isPinned(p.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = data.plan;
    final route = showRoute ? data.validRouteFor(plan) : null;
    final gps = data.gps;
    final status = _status(plan);

    // Pin terpilih digambar paling atas.
    final markers = <Marker>[
      for (final p in data.points)
        if (p.id != selectedId) _pin(p, plan),
      for (final p in data.points)
        if (p.id == selectedId) _pin(p, plan),
    ];

    return Stack(
      children: [
        FlutterMap(
          mapController: controller,
          options: MapOptions(
            initialCameraFit: initialFit,
            minZoom: 10,
            maxZoom: 18,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onTap: (_, __) => onSelect(null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.bapenda.cekreklame',
            ),
            if (route != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: route.line,
                    strokeWidth: 5,
                    color: route.isRoad ? _blue : _blue.withValues(alpha: 0.7),
                    borderStrokeWidth: 2,
                    borderColor: Colors.white,
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
                ],
              ),
            if (gps != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: gps,
                    radius: data.accuracy.clamp(15.0, 300.0).toDouble(),
                    useRadiusInMeter: true,
                    color: _blue.withValues(alpha: 0.12),
                    borderColor: _blue.withValues(alpha: 0.35),
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),
            if (gps != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: gps,
                    width: 64,
                    height: 64,
                    child: const _UserDot(),
                  ),
                ],
              ),
            MarkerLayer(markers: markers),
            const RichAttributionWidget(
              alignment: AttributionAlignment.bottomLeft,
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        if (status != null)
          Positioned(
            top: 8 + topInset,
            left: 8,
            child: _MapChip(text: status.text, busy: status.busy),
          ),
        Positioned(
          top: 8 + topInset,
          right: 8,
          child: Column(
            children: [
              _MapButton(
                icon: Icons.center_focus_strong_rounded,
                tooltip: 'Tampilkan semua',
                onTap: onFit,
              ),
              const SizedBox(height: 8),
              _MapButton(
                icon: Icons.my_location_rounded,
                tooltip: 'Posisiku',
                busy: data.locating,
                highlight: gps != null,
                onTap: onLocate,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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

// ----------------------------------------------------------------------------
// Pin & penanda
// ----------------------------------------------------------------------------

class _PinPainter extends CustomPainter {
  final Color color;
  final bool selected;

  const _PinPainter({required this.color, required this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final head = Path()
      ..addOval(Rect.fromCircle(center: Offset(r, r), radius: r - 2));
    final tail = Path()
      ..moveTo(r - r * 0.62, r + r * 0.55)
      ..lineTo(r, size.height - 1)
      ..lineTo(r + r * 0.62, r + r * 0.55)
      ..close();
    final pin = Path.combine(PathOperation.union, head, tail);

    canvas.drawPath(
      pin,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(pin, Paint()..color = color);
    if (selected) {
      canvas.drawCircle(Offset(r, r), r * 0.58, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _PinPainter old) =>
      old.color != color || old.selected != selected;
}

class _Pin extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final bool pinned;

  const _Pin({
    required this.label,
    required this.color,
    required this.selected,
    required this.pinned,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.18 : 1,
      alignment: Alignment.bottomCenter,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutBack,
      child: SizedBox(
        width: 40,
        height: 50,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PinPainter(color: color, selected: selected),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 40,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: selected ? color : Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
            // Penanda "dikunci petugas".
            if (pinned)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2933),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.push_pin_rounded,
                    size: 8,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Titik biru posisi petugas: halo statis + gelombang berdenyut.
class _UserDot extends StatefulWidget {
  const _UserDot();

  @override
  State<_UserDot> createState() => _UserDotState();
}

class _UserDotState extends State<_UserDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = Curves.easeOut.transform(_c.value);
        final wave = 24 + 40 * t;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: wave,
              height: wave,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _blue.withValues(alpha: 0.28 * (1 - t)),
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _blue.withValues(alpha: 0.16),
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _blue,
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          ],
        );
      },
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
