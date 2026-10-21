import 'dart:math' as math;
import 'package:mybapenda/presentation/features/survey_baru/cubit/survey_list/survey_list_cubit.dart';
import 'package:mybapenda/presentation/features/survey_baru/cubit/survey_list/survey_list_state.dart';
import 'package:mybapenda/presentation/features/survey_baru/cubit/survey_map/survey_map_cubit.dart';
import 'package:mybapenda/presentation/features/survey_baru/cubit/survey_map/survey_map_state.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_map/survey_deadline.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_map/survey_map_controller.dart'; // [BARU]
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_map/survey_map_point.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_map/survey_map_view.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_map/survey_route.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_map/survey_task_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// [HAPUS] import 'package:flutter_map/flutter_map.dart';
import 'survey_start.dart';

class SurveyMapPage extends StatefulWidget {
  final double initialSheet;

  const SurveyMapPage({super.key, this.initialSheet = 0.38});

  /// Membawa cubit yang sama (urutan di peta mini dan di sini selalu sama).
  static Future<void> open(BuildContext context, {bool arrange = false}) {
    final prio = context.read<SurveyMapCubit>();
    final list = context.read<SurveyListCubit>();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: prio),
            BlocProvider.value(value: list),
          ],
          child: SurveyMapPage(initialSheet: arrange ? 0.72 : 0.38),
        ),
      ),
    );
  }

  @override
  State<SurveyMapPage> createState() => _SurveyMapPageState();
}

class _SurveyMapPageState extends State<SurveyMapPage> {
  static const _minSheet = 0.14;
  static const _ink = Color(0xFF1F2933);
  static const _accent = Color(0xFFB8680F);

  final _map = SurveyMapController(); // [UBAH] dulu MapController()
  final _sheet = DraggableScrollableController();
  String? _selectedId;
  bool _showRoute = true;

  @override
  void dispose() {
    _sheet
        .dispose(); // [UBAH] _map.dispose() dihapus; peta Google melepas dirinya sendiri
    super.dispose();
  }

  void _select(String? id, {bool moveCamera = false}) {
    setState(() => _selectedId = id);
    if (id == null) return;

    if (moveCamera) {
      final p = context
          .read<SurveyMapCubit>()
          .state
          .points
          .where((e) => e.id == id)
          .firstOrNull;
      // [UBAH] zoom minimal 15 sudah diurus SurveyMapController.focus()
      if (p != null) _map.focus(p.position);
    }
    // Pastikan kartu detail terlihat.
    if (_sheet.isAttached && _sheet.size < 0.3) {
      _sheet.animateTo(
        0.38,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _locate() async {
    final cubit = context.read<SurveyMapCubit>();
    await cubit.locate();
    if (!mounted) return;
    final from = cubit.state.plan.from;
    if (from != null) await _map.moveTo(from, 16); // [UBAH]
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final top = MediaQuery.paddingOf(context).top;
    final cubit = context.read<SurveyMapCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: BlocBuilder<SurveyMapCubit, SurveyMapState>(
        builder: (context, data) {
          final plan = data.plan;
          final sel = _selectedId == null
              ? null
              : data.points.where((p) => p.id == _selectedId).firstOrNull;

          // [UBAH] Dulu `fitPadding` untuk CameraFit. Sekarang jadi padding
          // peta Google: bagian atas = top bar, bawah = sheet yang menutupi.
          final sheetInset = math.min(
            size.height * (widget.initialSheet - _minSheet) + 32,
            size.height * 0.4,
          );
          final mapPadding = EdgeInsets.only(top: top + 64, bottom: sheetInset);

          return Stack(
            children: [
              // Peta berhenti di atas posisi sheet minimum supaya atribusi terlihat.
              Positioned.fill(
                bottom: size.height * _minSheet,
                child: SurveyMapView(
                  controller: _map,
                  data: data,
                  selectedId: sel?.id,
                  onSelect: (id) => _select(id),
                  showRoute: _showRoute,
                  // [UBAH] initialFit dihapus; kamera awal diatur view sendiri
                  onFit: () => _map.fit(data),
                  onLocate: _locate,
                  topInset: top + 56,
                  mapPadding: mapPadding, // [BARU]
                ),
              ),

              // Top bar
              Positioned(
                top: top + 8,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(
                        side: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const SizedBox(
                          width: 42,
                          height: 42,
                          child: Icon(Icons.arrow_back_rounded, color: _ink),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Text(
                          'Prioritas Survey',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: SurveyRouteToggle(
                        active: _showRoute,
                        onTap: () => setState(() => _showRoute = !_showRoute),
                      ),
                    ),
                  ],
                ),
              ),

              // Sheet urutan
              DraggableScrollableSheet(
                controller: _sheet,
                initialChildSize: widget.initialSheet,
                minChildSize: _minSheet,
                maxChildSize: 0.88,
                snap: true,
                snapSizes: const [0.38, 0.88],
                builder: (context, scroll) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    child: ReorderableListView.builder(
                      scrollController: scroll,
                      buildDefaultDragHandles: false,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.paddingOf(context).bottom + 24,
                      ),
                      header: _header(context, data, plan, sel),
                      footer: plan.skipped.isEmpty
                          ? null
                          : _skippedFooter(data, plan),
                      itemCount: plan.order.length,
                      onReorder: cubit.move,
                      itemBuilder: (context, i) {
                        final p = plan.order[i];
                        return _OrderRow(
                          key: ValueKey(p.id),
                          index: i,
                          point: p,
                          number: i + 1,
                          pinned: plan.isPinned(p.id),
                          selected: p.id == _selectedId,
                          legText: _showRoute ? data.legText(plan, p.id) : null,
                          onTap: () => _select(p.id, moveCamera: true),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Overlay saat mengambil detail survey
              BlocSelector<SurveyListCubit, SurveyListState, bool>(
                selector: (s) => s.isOpening,
                builder: (context, opening) {
                  if (!opening) return const SizedBox.shrink();
                  return const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x66000000),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ---- Header sheet ----

  Widget _header(
    BuildContext context,
    SurveyMapState data,
    SurveyPlan plan,
    SurveyMapPoint? sel,
  ) {
    final cubit = context.read<SurveyMapCubit>();
    final r = data.validRouteFor(plan);
    final custom = data.isCustomized(plan);
    final extra = custom ? data.extraMeters(plan) : 0.0;
    final late = plan.lateUrgent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDBDFE9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Urutan Kunjungan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
              ),
              if (custom)
                TextButton.icon(
                  onPressed: cubit.reset,
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  label: const Text('Reset ke saran'),
                  style: TextButton.styleFrom(
                    foregroundColor: _accent,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),

          // Selected -> kartu detail. Kosong -> ringkasan rute.
          if (sel != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: SurveyTaskDetail(
                point: sel,
                number: plan.numberOf(sel.id),
                legText: _showRoute ? data.legText(plan, sel.id) : null,
                pinned: plan.isPinned(sel.id),
                skipped: plan.isSkipped(sel.id),
                isFirst: plan.numberOf(sel.id) == 1,
                // [UBAH] source selalu ada (tidak ada data contoh lagi)
                onStart: () => startSurvey(context, sel.source),
                onFirst: () => cubit.doFirst(sel.id),
                onSkip: () {
                  cubit.skip(sel.id);
                },
                onRestore: () => cubit.unskip(sel.id),
              ),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _stat(Icons.place_outlined, '${plan.order.length} tugas'),
                if (_showRoute && data.loadingRoute && r == null)
                  const Text(
                    'Menghitung rute…',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF7B8794)),
                  ),
                if (_showRoute && r != null) ...[
                  _stat(Icons.route_rounded, fmtKm(r.meters)),
                  _stat(Icons.schedule_rounded, '± ${fmtDur(r.seconds)}'),
                  if (!r.isRoad)
                    const Text(
                      'perkiraan',
                      style: TextStyle(fontSize: 11, color: Color(0xFF9AA5B1)),
                    ),
                ],
              ],
            ),

          if (custom && extra.abs() >= 100) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  extra > 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 16,
                  color: const Color(0xFF7B8794),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${extra > 0 ? '+' : '−'}${fmtKm(extra.abs())} dari urutan saran (garis lurus)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF52606D),
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (late.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: _accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      late.length == 1
                          ? '1 tugas mendesak ada di urutan ${late.first}.'
                          : '${late.length} tugas mendesak ada di urutan ${late.join(', ')}.',
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF7A4A0B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(
                Icons.drag_indicator_rounded,
                size: 16,
                color: Color(0xFF9AA5B1),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Tahan dan geser ikon di kanan untuk mengubah urutan.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF7B8794)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

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
          color: _ink,
        ),
      ),
    ],
  );

  // ---- Footer: dilewati ----

  Widget _skippedFooter(SurveyMapState data, SurveyPlan plan) {
    final cubit = context.read<SurveyMapCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dilewati hari ini (${plan.skipped.length})',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7B8794),
            ),
          ),
          const SizedBox(height: 8),
          for (final p in plan.skipped)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.nomor,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF52606D),
                          ),
                        ),
                        Text(
                          p.lokasi,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF9AA5B1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => cubit.unskip(p.id),
                    style: TextButton.styleFrom(foregroundColor: _accent),
                    child: const Text('Kembalikan'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final int index;
  final SurveyMapPoint point;
  final int number;
  final bool pinned;
  final bool selected;
  final String? legText;
  final VoidCallback onTap;

  const _OrderRow({
    super.key,
    required this.index,
    required this.point,
    required this.number,
    required this.pinned,
    required this.selected,
    required this.legText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final st = SurveyDeadline.styleOf(point.daysLeft);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: selected ? const Color(0xFFFFF4E5) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? const Color(0xFFB8680F).withValues(alpha: 0.5)
                    : const Color(0xFFEEF0F3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: st.bg,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: st.fg,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              point.nomor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F2933),
                              ),
                            ),
                          ),
                          if (pinned) ...[
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.push_pin_rounded,
                              size: 13,
                              color: Color(0xFFB8680F),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        point.lokasi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF7B8794),
                        ),
                      ),
                      if (legText != null)
                        Text(
                          legText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3B6FF5),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  st.text,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: st.fg,
                  ),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      color: Color(0xFF9AA5B1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
