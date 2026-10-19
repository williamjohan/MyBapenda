// lib/presentation/features/reklame/pages/reklame_dashboard_page.dart
import 'package:bapendacore/presentation/features/cek_reklame/widgets/reklame_survey_baru_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../widgets/dasboard_cek_reklame/reklame_history_card.dart';
import '../widgets/dasboard_cek_reklame/reklame_primary_card.dart';

class ReklameDashboardPage extends StatelessWidget {
  const ReklameDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          BapendaSliverHeader(
            title: 'Survey Reklame',
            showBackButton: true,
            subtitle: Text(
              'Pengawasan reklame Kota Surabaya',
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Section 1: Laporan Foto ----
                  const _SectionLabel(
                    title: 'Laporan Foto',
                    subtitle: 'Temuan reklame di lapangan',
                  ),
                  const SizedBox(height: 12),
                  ReklamePrimaryActionCard(
                    title: 'Ambil Gambar Reklame',
                    description:
                        'Foto lokasi & laporkan billboard yang ditemukan di lapangan secara presisi',
                    ctaLabel: 'Mulai Ambil Gambar',
                    onTap: () => context.pushNamed(AppRoutes.camera),
                  ),
                  const SizedBox(height: 12),
                  ReklameHistoryTile(
                    icon: Icons.history_rounded,
                    title: 'Riwayat Laporan Foto',
                    subtitle: 'Laporan foto yang pernah dikirim',
                    onTap: () => context.pushNamed(AppRoutes.history),
                  ),

                  const SizedBox(height: 28),

                  // ---- Section 2: Survey Permohonan ----
                  const _SectionLabel(
                    title: 'Survey Permohonan',
                    subtitle: 'Tugas survey dari permohonan reklame',
                  ),
                  const SizedBox(height: 12),
                  ReklameSurveyBaruCard(
                    icon: Icons.add_rounded,
                    title: 'Survey Permohonan Baru',
                    subtitle: 'Buat laporan survey reklame baru',
                    onTap: () =>
                        context.pushNamed(AppRoutes.surveyPermohonanBaru),
                  ),
                  const SizedBox(height: 12),
                  ReklameHistoryTile(
                    icon: Icons.fact_check_outlined,
                    title: 'Riwayat Survey Permohonan',
                    subtitle: 'Survey yang sudah selesai dikirim',
                    onTap: () => context.pushNamed(AppRoutes.surveyHistory),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Judul section: penanda aksen + judul + keterangan singkat.
class _SectionLabel extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionLabel({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFB8680F),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2933),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF7B8794)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
