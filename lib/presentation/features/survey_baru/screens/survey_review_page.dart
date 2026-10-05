// lib/presentation/features/reklame/pages/survey_review_page.dart
import 'dart:convert';
import 'package:bapendacore/presentation/features/survey_baru/constants/survey_option.dart';
import 'package:bapendacore/presentation/shared/widgets/bapenda_image.dart';
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:bapendacore/presentation/shared/widgets/info_row.dart';
import 'package:bapendacore/presentation/shared/widgets/photo_preview.dart';
import 'package:bapendacore/presentation/shared/widgets/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import 'survey_foto_page.dart';

class SurveyReviewPage extends StatelessWidget {
  final String nomorPelayanan;
  final List<Map<String, dynamic>> sisiList;
  final Map<int, SurveyResult> results;
  final Map<String, dynamic> info;

  const SurveyReviewPage({
    super.key,
    required this.nomorPelayanan,
    required this.sisiList,
    required this.results,
    required this.info,
  });

  Future<void> _submit(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kirim hasil survey?'),
        content: const Text(
          'Pastikan foto, kotak penanda, dan data semua sisi sudah benar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cek Lagi'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    // TODO: POST ke API. Sementara cuma print.
    final out = [
      for (final s in sisiList)
        if (results[s['seq']] case final r?)
          {
            ...r.data,
            'foto': {
              'path': r.foto.path,
              'lat': r.foto.lat,
              'lng': r.foto.lng,
              'box': {
                'left': r.foto.box.left,
                'top': r.foto.box.top,
                'right': r.foto.box.right,
                'bottom': r.foto.box.bottom,
              },
            },
          },
    ];
    debugPrint(
      const JsonEncoder.withIndent(
        '  ',
      ).convert({'informasiSurvey': info, 'sisi': out}),
    );

    final messenger = ScaffoldMessenger.of(context);
    context.goNamed(AppRoutes.reklameDashboard);
    messenger.showSnackBar(
      const SnackBar(content: Text('Hasil survey siap dikirim (mode uji).')),
    );
  }

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
              nomorPelayanan,
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 4),
              child: Text(
                'Ringkasan Survey',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2933),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
              child: _InfoReviewCard(info: info),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            sliver: SliverList.separated(
              itemCount: sisiList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final s = sisiList[i];
                final seq = s['seq'] as int;
                final r = results[seq];
                if (r == null) return const SizedBox.shrink();
                return SisiReviewCard(sisi: s, result: r);
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
            label: 'Kirim Hasil Survey',
            icon: Icons.send_rounded,
            onPressed: () => _submit(context),
          ),
        ),
      ),
    );
  }
}

class SisiReviewCard extends StatelessWidget {
  final Map<String, dynamic> sisi;
  final SurveyResult result;
  final VoidCallback? onEdit;

  const SisiReviewCard({required this.sisi, required this.result, this.onEdit});

  String _opt(Map<int, String> map, dynamic id) => map[id] ?? '-';

  @override
  Widget build(BuildContext context) {
    final d = result.data;
    final f = result.foto;
    final seq = sisi['seq'] as int;

    final p = d['panjang'] as num? ?? 0;
    final l = d['lebar'] as num? ?? 0;
    final t = d['tinggi'] as num? ?? 0;

    final nb = d['norBaru'];
    final nor =
        (sisi['nor'] as String?) ??
        (d['norLabel'] as String?) ??
        (nb is Map ? 'NOR Baru · NOP ${nb['nopPbb']}' : '-');

    final ketSisi = (d['ketSisi'] as String?) ?? '';
    final ketSurvey = (d['ketSurvey'] as String?) ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.campaign_rounded,
                size: 18,
                color: Color(0xFFB8680F),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sisi $seq',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2933),
                  ),
                ),
              ),
              if (onEdit != null)
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: Text(
                    'Edit',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB8680F),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          PhotoPreview(path: f.path, ratio: f.ratio, box: f.box),
          const SizedBox(height: 10),
          if (f.lat != 0 || f.lng != 0)
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: Color(0xFFB8680F),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${f.lat.toStringAsFixed(6)}, ${f.lng.toStringAsFixed(6)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF52606D),
                    ),
                  ),
                ),
              ],
            ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFEEF0F3)),
          ),

          InfoRow(label: 'NOR', value: nor),
          InfoRow(label: 'Lokasi', value: '${d['lokPenyelenggaraan'] ?? '-'}'),
          InfoRow(label: 'Materi', value: '${d['materiReklame'] ?? '-'}'),
          InfoRow(
            label: 'Lokasi Tertentu',
            value: _opt(SurveyOptions.lokasiTertentu, d['lokasiTertentuId']),
          ),
          InfoRow(
            label: 'Letak Reklame',
            value: _opt(SurveyOptions.letakReklame, d['letakReklame']),
          ),
          InfoRow(
            label: 'Status Tanah',
            value: _opt(SurveyOptions.statusTanah, d['statusTanah']),
          ),
          InfoRow(
            label: 'Ukuran (P x L x T)',
            value:
                '${SurveyOptions.fmtNum(p)} x ${SurveyOptions.fmtNum(l)} x ${SurveyOptions.fmtNum(t)} m',
          ),
          InfoRow(
            label: 'Jenis Reklame',
            value: _opt(SurveyOptions.jenisReklame, d['idJenisReklame']),
          ),
          InfoRow(
            label: 'Jenis Produk',
            value: _opt(SurveyOptions.jenisProduk, d['idJenisProduk']),
          ),
          InfoRow(
            label: 'Sudut Pandang',
            value: _opt(SurveyOptions.sudutPandang, d['sudutPandang']),
          ),
          if (ketSisi.isNotEmpty) InfoRow(label: 'Ket. Sisi', value: ketSisi),
          if (ketSurvey.isNotEmpty)
            InfoRow(label: 'Ket. Survey', value: ketSurvey),
        ],
      ),
    );
  }
}

class _InfoReviewCard extends StatelessWidget {
  final Map<String, dynamic> info;
  const _InfoReviewCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final selfie = info['selfiePath'] as String?;
    final lat = (info['latitude'] as num?)?.toStringAsFixed(6) ?? '-';
    final lng = (info['longitude'] as num?)?.toStringAsFixed(6) ?? '-';
    final tgl = DateTime.tryParse('${info['tanggalSurvey']}');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Color(0xFFB8680F),
              ),
              const SizedBox(width: 8),
              Text(
                'Informasi Survey',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2933),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (selfie != null)
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BapendaImage(
                    path: selfie,
                    width: 64,
                    height: 64,
                    cacheWidth: 200,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Foto selfie petugas',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: const Color(0xFF52606D),
                    ),
                  ),
                ),
              ],
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFEEF0F3)),
          ),
          InfoRow(label: 'Koordinat', value: '$lat, $lng'),
          InfoRow(
            label: 'Kecamatan',
            value: SurveyOptions.kecamatan[info['kecamatanId']] ?? '-',
          ),
          InfoRow(
            label: 'Kelurahan',
            value: SurveyOptions.kelurahanName(
              info['kecamatanId'],
              info['kelurahanId'],
            ),
          ),
          InfoRow(label: 'RT / RW', value: '${info['rt']} / ${info['rw']}'),
          InfoRow(label: 'No IMB', value: '${info['noImb']}'),
          InfoRow(label: 'Blok', value: '${info['blok']}'),
          InfoRow(
            label: 'Tim Survey',
            value: SurveyOptions.timSurvey[info['timSurveyId']] ?? '-',
          ),
          InfoRow(
            label: 'Tanggal Survey',
            value: tgl == null ? '-' : SurveyOptions.fmtTanggal(tgl),
          ),
        ],
      ),
    );
  }
}
