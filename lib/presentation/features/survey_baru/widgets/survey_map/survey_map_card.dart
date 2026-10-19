import 'package:bapendacore/domain/entities/cek_reklames/survey_permohonan_baru/survey_permohonan_entity.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_map/survey_map_cubit.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_map/survey_map_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'survey_deadline.dart';
import 'survey_map_view.dart';
import 'survey_route.dart';
import 'survey_task_detail.dart';

class SurveyMapCard extends StatefulWidget {
  final ValueChanged<SurveyPermohonanEntity> onStart;
  final VoidCallback onOpenMap;
  final VoidCallback onArrange;
  final double mapHeight;

  const SurveyMapCard({
    super.key,
    required this.onStart,
    required this.onOpenMap,
    required this.onArrange,
    this.mapHeight = 240,
  });

  @override
  State<SurveyMapCard> createState() => _SurveyMapCardState();
}

class _SurveyMapCardState extends State<SurveyMapCard> {
  static const _ink = Color(0xFF1F2933);
  static const _accent = Color(0xFFB8680F);

  final _controller = MapController();
  String? _selectedId;
  bool _showRoute = true;

  void _fit(SurveyMapState s) {
    try {
      _controller.fitCamera(surveyFit(s));
    } catch (_) {}
  }

  Future<void> _locate() async {
    final cubit = context.read<SurveyMapCubit>();
    await cubit.locate();
    if (!mounted) return;
    final s = cubit.state;
    final from = s.plan.from;
    try {
      if (from != null) {
        _controller.move(from, 16);
      } else {
        _fit(s);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SurveyMapCubit>();

    return BlocListener<SurveyMapCubit, SurveyMapState>(
      listenWhen: (p, c) =>
          p.points != c.points || (p.plan.from == null && c.plan.from != null),
      listener: (_, s) => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fit(s);
      }),
      child: BlocBuilder<SurveyMapCubit, SurveyMapState>(
        builder: (context, data) {
          if (data.points.isEmpty) return const SizedBox.shrink();

          final plan = data.plan;
          final sel = _selectedId == null
              ? null
              : data.points.where((p) => p.id == _selectedId).firstOrNull;

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
                  child: Row(
                    children: [
                      const Icon(Icons.map_outlined, size: 18, color: _accent),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Peta Tugas Survey',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                      ),
                      SurveyRouteToggle(
                        active: _showRoute,
                        onTap: () => setState(() => _showRoute = !_showRoute),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: widget.mapHeight,
                    child: SurveyMapView(
                      controller: _controller,
                      data: data,
                      selectedId: sel?.id,
                      onSelect: (id) => setState(() => _selectedId = id),
                      showRoute: _showRoute,
                      initialFit: surveyFit(data),
                      onFit: () => _fit(data),
                      onLocate: _locate,
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: sel == null
                        ? _Summary(
                            key: const ValueKey('summary'),
                            data: data,
                            plan: plan,
                            showRoute: _showRoute,
                            onReset: cubit.reset,
                            onArrange: widget.onArrange,
                            onOpenMap: widget.onOpenMap,
                          )
                        : Padding(
                            key: ValueKey(sel.id),
                            padding: const EdgeInsets.fromLTRB(4, 12, 4, 2),
                            child: SurveyTaskDetail(
                              point: sel,
                              number: plan.numberOf(sel.id),
                              legText: _showRoute
                                  ? data.legText(plan, sel.id)
                                  : null,
                              pinned: plan.isPinned(sel.id),
                              skipped: plan.isSkipped(sel.id),
                              isFirst: plan.numberOf(sel.id) == 1,
                              onStart: sel.source == null
                                  ? null
                                  : () => widget.onStart(sel.source!),
                              onFirst: () => cubit.doFirst(sel.id),
                              onRestore: () => cubit.unskip(sel.id),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final SurveyMapState data;
  final SurveyPlan plan;
  final bool showRoute;
  final VoidCallback onReset;
  final VoidCallback onArrange;
  final VoidCallback onOpenMap;

  const _Summary({
    super.key,
    required this.data,
    required this.plan,
    required this.showRoute,
    required this.onReset,
    required this.onArrange,
    required this.onOpenMap,
  });

  Widget _stat(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: const Color(0xFF7B8794)),
      const SizedBox(width: 5),
      Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1F2933),
        ),
      ),
    ],
  );

  Widget _dot(String label, Color c) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(fontSize: 11.5, color: Color(0xFF52606D)),
      ),
    ],
  );

  Widget _outlined(String label, IconData icon, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF3E4C59),
        side: const BorderSide(color: Color(0xFFDBDFE9), width: 1.2),
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = data.validRouteFor(plan);
    final count = plan.order.length;

    Widget top;
    if (!showRoute) {
      top = _stat(Icons.place_outlined, '$count tugas');
    } else if (data.loadingRoute && r == null) {
      top = const Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text(
            'Menghitung rute...',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF7B8794)),
          ),
        ],
      );
    } else if (r != null) {
      top = Wrap(
        spacing: 16,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _stat(Icons.place_outlined, '$count tugas'),
          _stat(Icons.route_rounded, fmtKm(r.meters)),
          _stat(Icons.schedule_rounded, '± ${fmtDur(r.seconds)}'),
          if (!r.isRoad)
            const Text(
              'perkiraan',
              style: TextStyle(fontSize: 11, color: Color(0xFF9AA5B1)),
            ),
        ],
      );
    } else {
      top = _stat(Icons.place_outlined, '$count tugas');
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          top,
          if (data.isCustomized(plan)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.push_pin_rounded,
                  size: 14,
                  color: Color(0xFFB8680F),
                ),
                const SizedBox(width: 5),
                const Expanded(
                  child: Text(
                    'Urutan diatur olehmu',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB8680F),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onReset,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: const Color(0xFFB8680F),
                  ),
                  child: const Text('Reset ke saran'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _dot('Mendesak', SurveyDeadline.styleOf(0).fg),
              _dot('Segera', SurveyDeadline.styleOf(2).fg),
              _dot('Aman', SurveyDeadline.styleOf(10).fg),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Nomor pin = urutan kunjungan. Ketuk pin untuk detail.',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF7B8794)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _outlined(
                  'Atur Urutan',
                  Icons.swap_vert_rounded,
                  onArrange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _outlined(
                  'Buka Peta',
                  Icons.open_in_full_rounded,
                  onOpenMap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
