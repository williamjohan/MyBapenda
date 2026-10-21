import 'package:mybapenda/domain/entities/cek_reklames/survey_permohonan_baru/survey_history_entity.dart';
import 'package:mybapenda/presentation/features/survey_baru/cubit/survey_history/survey_history_detail_cubit.dart';
import 'package:mybapenda/presentation/features/survey_baru/cubit/survey_history/survey_history_detail_state.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_history/history_format.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_history/history_image.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_history/history_sisi_card.dart';
import 'package:mybapenda/presentation/shared/widgets/bapenda_sliver_header.dart';
import 'package:mybapenda/presentation/shared/widgets/button.dart';
import 'package:mybapenda/presentation/shared/widgets/info_row.dart';
import 'package:mybapenda/presentation/shared/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';

class SurveyHistoryDetailPage extends StatelessWidget {
  final String nomor;

  const SurveyHistoryDetailPage({super.key, required this.nomor});

  static const _ink = Color(0xFF1F2933);
  static const _muted = Color(0xFF7B8794);
  static const _accent = Color(0xFFB8680F);

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openPdf(BuildContext context) async {
    final res = await context.read<SurveyHistoryDetailCubit>().downloadPdf();
    if (!context.mounted) return;

    if (res.error != null) return _snack(context, res.error!);
    final path = res.path;
    if (path == null) return;

    final r = await OpenFilex.open(path, type: 'application/pdf');
    if (!context.mounted) return;
    if (r.type != ResultType.done) {
      _snack(
        context,
        'Tidak bisa membuka PDF. Pastikan ada aplikasi pembaca PDF.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          BapendaSliverHeader(
            title: 'Detail Survey',
            showBackButton: true,
            subtitle: Text(
              nomor,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          BlocBuilder<SurveyHistoryDetailCubit, SurveyHistoryDetailState>(
            builder: (context, state) {
              if (state.status == SurveyHistoryDetailStatus.loading) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final d = state.detail;
              if (state.status == SurveyHistoryDetailStatus.failure ||
                  d == null) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.error ?? 'Gagal memuat detail survey.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: _muted),
                          ),
                          TextButton.icon(
                            onPressed: context
                                .read<SurveyHistoryDetailCubit>()
                                .load,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _summary(context, d, state.downloading),
                    const SizedBox(height: 14),
                    _petugas(context, d.petugas),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Hasil Survey per Sisi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                            ),
                          ),
                        ),
                        Text(
                          '${d.sisiList.length} sisi',
                          style: const TextStyle(fontSize: 12, color: _muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (d.sisiList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'Belum ada data sisi.',
                            style: TextStyle(fontSize: 13, color: _muted),
                          ),
                        ),
                      )
                    else
                      for (var i = 0; i < d.sisiList.length; i++) ...[
                        HistorySisiCard(
                          sisi: d.sisiList[i],
                          initiallyExpanded: d.sisiList.length == 1 || i == 0,
                        ),
                        const SizedBox(height: 12),
                      ],
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---- Ringkasan + tombol PDF ----

  Widget _summary(
    BuildContext context,
    SurveyHistoryDetailEntity d,
    bool downloading,
  ) {
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5EE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  size: 21,
                  color: Color(0xFF1B7F4B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.noPelayanan,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NPWPD ${d.npwpd}',
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(
                label: d.statusProses,
                tone: HistoryFmt.toneOf(d.statusProses),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEF0F3)),
          const SizedBox(height: 8),
          InfoRow(label: 'Kategori', value: d.kategori),
          if (d.noFormulir != null)
            InfoRow(label: 'No. Formulir', value: d.noFormulir!),
          InfoRow(label: 'Status Permohonan', value: d.statusPermohonan),
          InfoRow(label: 'Jumlah Sisi', value: '${d.jumlahSisi} sisi'),
          if (d.laporanPdfUrl != null) ...[
            const SizedBox(height: 14),
            Button(
              label: 'Unduh Laporan PDF',
              icon: Icons.picture_as_pdf_rounded,
              height: 44,
              isLoading: downloading,
              onPressed: downloading ? null : () => _openPdf(context),
            ),
          ],
        ],
      ),
    );
  }

  // ---- Petugas + check-in ----

  Widget _petugas(BuildContext context, HistoryPetugasEntity p) {
    final c = p.checkin;
    final koordinat = (c != null && c.hasCoordinate)
        ? '${c.latitude!.toStringAsFixed(6)}, ${c.longitude!.toStringAsFixed(6)}'
        : null;

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
          const Row(
            children: [
              Icon(Icons.badge_outlined, size: 18, color: _accent),
              SizedBox(width: 8),
              Text(
                'Petugas Survey',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InfoRow(label: 'Petugas Utama', value: p.utama.tampil),
          InfoRow(
            label: 'Petugas Pembantu',
            value: p.pembantu.isEmpty
                ? '-'
                : p.pembantu.map((e) => e.tampil).join('\n'),
          ),
          if (c != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFEEF0F3)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (c.imageUrl != null)
                  GestureDetector(
                    onTap: () => showHistoryPhoto(
                      context,
                      c.imageUrl!,
                      caption: 'Foto check-in petugas',
                    ),
                    child: HistoryImage(
                      url: c.imageUrl!,
                      width: 76,
                      height: 76,
                      radius: 12,
                    ),
                  ),
                if (c.imageUrl != null) const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Check-in petugas',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        HistoryFmt.tanggalJam(c.waktu),
                        style: const TextStyle(fontSize: 12, color: _muted),
                      ),
                      if (c.alamat != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          c.alamat!,
                          style: const TextStyle(fontSize: 12, color: _muted),
                        ),
                      ],
                      if (koordinat != null) ...[
                        const SizedBox(height: 6),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: koordinat));
                            _snack(context, 'Koordinat disalin');
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.place_outlined,
                                size: 14,
                                color: Color(0xFF3B6FF5),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  koordinat,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3B6FF5),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.copy_rounded,
                                size: 13,
                                color: Color(0xFF9AA5B1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
