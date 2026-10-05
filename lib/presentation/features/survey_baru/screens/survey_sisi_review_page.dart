// lib/presentation/features/reklame/pages/survey_sisi_review_page.dart
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:bapendacore/presentation/shared/widgets/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import 'survey_foto_page.dart';
import 'survey_review_page.dart';

/// Review satu sisi sebelum disimpan.
/// pop(true)  = simpan sisi ini
/// pop(false) = mau ubah data lagi
/// pop(null)  = tombol back
class SurveySisiReviewPage extends StatelessWidget {
  final Map<String, dynamic> sisi;
  final SurveyResult result;

  const SurveySisiReviewPage({
    super.key,
    required this.sisi,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          BapendaSliverHeader(
            title: 'Survey Permohonan Baru',
            showBackButton: true,
            subtitle: Text(
              'Sisi ${sisi['seq']}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: const StepIndicator(
                labels: ['Foto', 'Data', 'Review'],
                currentIndex: 2,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(18),
            sliver: SliverToBoxAdapter(
              // onEdit null -> tombol Edit di kartu tidak muncul,
              // ubah data lewat tombol di bawah
              child: SisiReviewCard(sisi: sisi, result: result),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: Row(
            children: [
              Expanded(
                child: Button(
                  label: 'Ubah Data',
                  icon: Icons.edit_rounded,
                  variant: BapendaButtonVariant.outlined,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Button(
                  label: 'Simpan Sisi',
                  icon: Icons.check_rounded,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
