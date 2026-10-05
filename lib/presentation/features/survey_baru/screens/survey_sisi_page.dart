// lib/presentation/features/reklame/pages/survey_sisi_page.dart
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../widgets/survey_sisi_tile.dart';
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

  bool get _allDone => _results.length == widget.sisiList.length;

  Future<void> _openSisi(Map<String, dynamic> sisi) async {
    final seq = sisi['seq'] as int;
    final result = await context.pushNamed<SurveyResult>(
      AppRoutes.surveyFoto,
      extra: (sisi: sisi, result: _results[seq]),
    );
    if (result != null && mounted) setState(() => _results[seq] = result);
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
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.85),
              ),
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
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2933),
                      ),
                    ),
                  ),
                  Text(
                    '${_results.length}/${list.length} selesai',
                    style: GoogleFonts.plusJakartaSans(
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
                      _results.containsKey(seq) || apiFotosOf(s).isNotEmpty,
                  done: _results.containsKey(seq),
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
          child: Button(
            label: 'Review & Kirim',
            icon: Icons.arrow_forward_rounded,
            iconAtEnd: true,
            onPressed: _allDone ? _openReview : null,
          ),
        ),
      ),
    );
  }
}
