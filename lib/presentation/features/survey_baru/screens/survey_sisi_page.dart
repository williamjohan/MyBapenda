// lib/presentation/features/reklame/pages/survey_sisi_page.dart
import 'package:bapendacore/presentation/features/survey_baru/widgets/survey_header_card.dart';
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../cubit/survey_radius/survey_radius_cubit.dart';
import '../cubit/survey_submit/survey_submit_cubit.dart';
import '../widgets/hasil_simpan_survey.dart';
import '../widgets/tombol_simpan_draft.dart';
import '../widgets/survey_sisi_tile.dart';
import '../utils/survey_lokasi_ui_helper.dart';
import 'survey_foto_page.dart';

class SurveySisiPage extends StatefulWidget {
  final String nomorPelayanan;
  final List<Map<String, dynamic>> sisiList; // = data.sisiList dari API
  final Map<String, dynamic> info; // dari halaman Informasi Survey

  const SurveySisiPage({
    super.key,
    required this.nomorPelayanan,
    required this.sisiList,
    required this.info,
  });

  @override
  State<SurveySisiPage> createState() => _SurveySisiPageState();
}

class _SurveySisiPageState extends State<SurveySisiPage> {
  // TODO: pindahin ke Cubit. Key = seq sisi
  final Map<int, SurveyResult> _results = {};

  /// Seq sisi yang pinnya di luar radius saat ini (radius mengecil setelah
  /// pin dipasang). Simpan dicegah sampai pin dipindah; pin tidak dihapus.
  List<int> _luarRadius(int radius) => [
    for (final s in widget.sisiList)
      if (SurveyLokasiUiHelper.diLuarRadius(_results[s['seq']]?.lokasi, radius))
        s['seq'] as int,
  ];

  /// Semua sisi lengkap (bukan draft): boleh Review & Kirim.
  bool get _allDone =>
      _results.length == widget.sisiList.length &&
      _results.values.every((r) => !isDataDraft(r.data));

  /// Survey yang dikembalikan penilai tidak memakai Simpan Draft.
  bool get _bolehDraft {
    final h = widget.sisiList.firstOrNull?['header'];
    return !(h is Map && h['dikembalikan'] == true);
  }

  /// Server menolak draft bila ada sisi tanpa titik reklame & foto. Sisi
  /// yang sudah punya draft di server boleh tidak dikirim ulang.
  bool get _siapDraft => widget.sisiList.every(
    (s) =>
        _results.containsKey(s['seq']) || (_isDraft && titikDraftOf(s) != null),
  );

  Future<void> _openSisi(Map<String, dynamic> sisi) async {
    final seq = sisi['seq'] as int;
    final result = await context.pushNamed<SurveyResult>(
      AppRoutes.surveyFoto,
      extra: (sisi: sisi, result: _results[seq]),
    );
    if (result != null && mounted) setState(() => _results[seq] = result);
  }

  bool get _isDraft {
    final h = widget.sisiList.firstOrNull?['header'];
    return h is Map && h['isDraft'] == true;
  }

  /// Simpan sisi yang sudah selesai sebagai draft. Server tetap langsung
  /// submit ke penilaian bila ternyata semua isian sudah lengkap.
  Future<void> _simpanDraft() async {
    final res = await context.read<SurveySubmitCubit>().submit(
      info: widget.info,
      sisiList: widget.sisiList,
      results: _results,
    );
    if (!mounted) return;

    final hasil = res.hasil;
    if (hasil == null) {
      final error = res.error;
      if (error == null) return;
      final n = await tampilkanGagalSimpanSurvey(context, error);
      final sisi = n == null ? null : sisiKe(widget.sisiList, n);
      if (sisi != null && mounted) await _openSisi(sisi);
      return;
    }
    await tampilkanHasilSimpanSurvey(context, hasil);
  }

  Future<void> _openReview() async {
    // Review mengembalikan seq sisi kalau user tekan "Edit"
    final editSeq = await context.pushNamed<int>(
      AppRoutes.surveyReview,
      extra: (
        nomor: widget.nomorPelayanan,
        sisiList: widget.sisiList,
        results: _results,
        info: widget.info,
      ),
    );
    if (editSeq != null && mounted) {
      final sisi = widget.sisiList.firstWhere((s) => s['seq'] == editSeq);
      await _openSisi(sisi);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.sisiList;
    final radius = context.watch<SurveyRadiusCubit>().state;
    final luar = _luarRadius(radius);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          BapendaSliverHeader(
            title: 'Mulai Survey',
            showBackButton: true,
            subtitle: Text(
              widget.nomorPelayanan,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          if (list.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: SurveyHeaderCard(sisi: list.first),
              ),
            ),
          if (_isDraft)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: _InfoDraft(),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Daftar Sisi Reklame',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2933),
                      ),
                    ),
                  ),
                  Text(
                    '${_results.length}/${list.length} selesai',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFB8680F),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            sliver: SliverList.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final s = list[i];
                final seq = s['seq'] as int;
                return SurveySisiTile(
                  seq: seq,
                  jenisReklame: s['jenisReklameNama'] as String? ?? '-',
                  materi: s['materiReklamePermohonan'] as String? ?? '-',
                  lokasi: s['lokPenyelenggaraanPermohonan'] as String? ?? '-',
                  masaTayang: s['masaTayang'] as String? ?? '-',
                  // foto lokal ATAU foto yang sudah ada di server
                  hasFoto:
                      _results.containsKey(seq) ||
                      apiFotosOf(s).isNotEmpty ||
                      punyaFotoDraft(s),
                  done:
                      _results.containsKey(seq) &&
                      !isDataDraft(_results[seq]!.data),
                  draft: isDataDraft(_results[seq]?.data),
                  peringatan: luar.contains(seq)
                      ? 'Titik reklame di luar radius $radius m, pindahkan pin'
                      : null,
                  onTap: () => _openSisi(s),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: BlocBuilder<SurveySubmitCubit, bool>(
            builder: (context, menyimpan) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (luar.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Titik reklame sisi ${luar.join(', ')} di luar radius '
                      '$radius m. Pindahkan pin sebelum menyimpan.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC62828),
                      ),
                    ),
                  )
                else if (_bolehDraft && !_siapDraft)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Simpan Draft aktif setelah semua sisi punya titik '
                      'reklame dan foto.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF7B8794),
                      ),
                    ),
                  ),
                Row(
                  children: [
                    if (_bolehDraft) ...[
                      TombolSimpanDraft(
                        isLoading: menyimpan,
                        onPressed:
                            _results.isEmpty || !_siapDraft || luar.isNotEmpty
                            ? null
                            : _simpanDraft,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Button(
                        label: 'Review & Kirim',
                        icon: Icons.arrow_forward_rounded,
                        iconAtEnd: true,
                        onPressed: _allDone && luar.isEmpty && !menyimpan
                            ? _openReview
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Penanda survey ini melanjutkan draft yang tersimpan di server.
class _InfoDraft extends StatelessWidget {
  const _InfoDraft();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF5C27A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.edit_note_rounded, size: 20, color: Color(0xFFB8680F)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Melanjutkan draft survey. Check-in, titik reklame, foto dan '
              'isian sudah terisi dari draft; lengkapi yang kurang lalu simpan.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: Color(0xFF7A4A0C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
