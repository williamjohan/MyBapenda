// lib/presentation/features/reklame/pages/survey_permohonan_page.dart
import 'package:bapendacore/presentation/features/survey_baru/widgets/survey_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';

class SurveyPermohonanBaruPage extends StatefulWidget {
  const SurveyPermohonanBaruPage({super.key});

  @override
  State<SurveyPermohonanBaruPage> createState() =>
      _SurveyPermohonanBaruPageState();
}

class _SurveyPermohonanBaruPageState extends State<SurveyPermohonanBaruPage> {
  String _query = '';

  // TODO: ganti dengan data dari API
  static const _dummy =
      <
        ({
          String nomor,
          String wajibPajak,
          String kategori,
          String statusPermohonan,
          String statusProses,
          int jumlahSisi,
        })
      >[
        (
          nomor: 'PRMN-10.2026.00116',
          wajibPajak: '3515150206030007',
          kategori: 'Permanen',
          statusPermohonan: 'Diproses',
          statusProses: 'Survey',
          jumlahSisi: 2,
        ),
      ];

  // TODO: dari API (data.sisiList)
  static final List<Map<String, dynamic>> _dummySisi = [
    {
      'seq': 1,
      'keySisi': 'JwSu0hF9fpocgnvpqY2jPQ',
      'jenisReklameNama': 'Berjalan',
      'lokPenyelenggaraanPermohonan': 'NEW YORK BARAT',
      'materiReklamePermohonan': 'TESTING SISI 1',
      'masaTayang': '27 Okt 2026 - 27 Okt 2027',
      'nor': null,
      'fotosWp': [
        {'url': 'https://picsum.photos/id/1016/800/600'},
      ],
      'survey': {'fotos': []},
    },
    {
      'seq': 2,
      'keySisi': 'EbUcQw72nQA0X6v-A2bCrQ',
      'jenisReklameNama': 'Berjalan',
      'lokPenyelenggaraanPermohonan': 'NEW YORK BARAT',
      'materiReklamePermohonan': 'TESTING SISI 2',
      'masaTayang': '27 Okt 2026 - 27 Okt 2027',
      'nor': null,
      'fotosWp': [
        {'url': 'https://picsum.photos/id/1015/800/600'},
      ],
      'survey': {'fotos': []},
    },
  ];

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final items = q.isEmpty
        ? _dummy
        : _dummy
              .where(
                (e) =>
                    e.nomor.toLowerCase().contains(q) ||
                    e.wajibPajak.toLowerCase().contains(q),
              )
              .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          BapendaSliverHeader(
            title: 'Survey Permohonan Baru',
            showBackButton: true,
            subtitle: Text(
              'Pilih permohonan yang akan disurvey',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Cari nomor pelayanan / wajib pajak',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF9AA5B1),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF9AA5B1),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'Permohonan tidak ditemukan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF7B8794),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final e = items[i];
                  return SurveyCard(
                    nomorPelayanan: e.nomor,
                    informasiWajibPajak: e.wajibPajak,
                    kategori: e.kategori,
                    statusPermohonan: e.statusPermohonan,
                    statusProses: e.statusProses,
                    jumlahSisi: e.jumlahSisi,
                    onTap: () => context.pushNamed(
                      AppRoutes.surveyInfo,
                      extra: (nomor: e.nomor, sisiList: _dummySisi),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
