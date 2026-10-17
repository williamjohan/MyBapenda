// lib/presentation/features/survey_baru/screens/survey_review_page.dart
import 'package:bapendacore/core/di/injection.dart';
import 'package:bapendacore/presentation/features/survey_baru/constants/survey_option.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_submit/survey_submit_cubit.dart';
import 'package:bapendacore/presentation/features/survey_baru/widgets/survey_header_card.dart';
import 'package:bapendacore/presentation/shared/master_data/domain/entities/master_option_type.dart';
import 'package:bapendacore/presentation/shared/master_data/presentation/cubit/master_data_cubit.dart';
import 'package:bapendacore/presentation/shared/widgets/bapenda_image.dart';
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:bapendacore/presentation/shared/widgets/info_row.dart';
import 'package:bapendacore/presentation/shared/widgets/photo_preview.dart';
import 'package:bapendacore/presentation/shared/widgets/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

    final messenger = ScaffoldMessenger.of(context);
    final res = await context.read<SurveySubmitCubit>().submit(
      info: info,
      sisiList: sisiList,
      results: results,
    );
    if (!context.mounted) return;

    if (!res.ok) {
      if (res.error != null) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(res.error!)));
      }
      return;
    }

    context.goNamed(AppRoutes.reklameDashboard);
    messenger.showSnackBar(
      const SnackBar(content: Text('Hasil survey berhasil dikirim.')),
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
              style: TextStyle(
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
          if (sisiList.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: SurveyHeaderCard(
                  sisi: sisiList.first,
                  initiallyExpanded: false,
                ),
              ),
            ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 20, 18, 4),
              child: Text(
                'Ringkasan Survey',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2933),
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
                return SisiReviewCard(
                  sisi: s,
                  result: r,
                  // Sisi page menunggu seq ini lewat _openReview.
                  onEdit: () => context.pop<int>(seq),
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
            builder: (context, sending) => Button(
              label: 'Kirim Hasil Survey',
              icon: Icons.send_rounded,
              isLoading: sending,
              onPressed: sending ? null : () => _submit(context),
            ),
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

  const SisiReviewCard({
    super.key,
    required this.sisi,
    required this.result,
    this.onEdit,
  });

  String _opt(Map<int, String> map, dynamic id) => map[id] ?? '-';

  @override
  Widget build(BuildContext context) {
    // MasterDataCubit singleton: opsi sudah ke-cache saat halaman data dipakai.
    final m = getIt<MasterDataCubit>().state;

    debugPrint('letak opts: ${m.intOptionsOf(MasterOptionType.letakReklame)}');
    debugPrint('tanah opts: ${m.intOptionsOf(MasterOptionType.statusTanah)}');
    debugPrint('produk opts: ${m.intOptionsOf(MasterOptionType.jenisProduk)}');

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
        (nb is Map ? 'NOR Baru · ${nb['noAlamat'] ?? '-'}' : '-');

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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2933),
                  ),
                ),
              ),
              if (onEdit != null)
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text(
                    'Edit',
                    style: TextStyle(
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
          if (f.keterangan.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notes_rounded,
                    size: 15,
                    color: Color(0xFF9AA5B1),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      f.keterangan,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: Color(0xFF52606D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFEEF0F3)),
          ),

          InfoRow(label: 'NOR', value: nor),
          if (nb is Map) ...[
            InfoRow(
              label: 'Jenis Bangunan',
              value: _opt(
                m.intOptionsOf(MasterOptionType.jenisBangunan),
                nb['jenisBangunanId'],
              ),
            ),
            InfoRow(
              label: 'Nama Jalan',
              value: '${nb['namaJalanNama'] ?? '-'}',
            ),
            InfoRow(label: 'No. Alamat', value: '${nb['noAlamat'] ?? '-'}'),
            InfoRow(label: 'Persil', value: '${nb['persilLabel'] ?? '-'}'),
          ],
          InfoRow(label: 'Lokasi', value: '${d['lokPenyelenggaraan'] ?? '-'}'),
          InfoRow(label: 'Materi', value: '${d['materiReklame'] ?? '-'}'),
          InfoRow(
            label: 'Lokasi Tertentu',
            value: _opt(
              m.intOptionsOf(MasterOptionType.lokasiTertentu),
              d['lokasiTertentuId'],
            ),
          ),
          InfoRow(
            label: 'Letak Reklame',
            value: _opt(
              m.intOptionsOf(MasterOptionType.letakReklame),
              d['letakReklame'],
            ),
          ),
          InfoRow(
            label: 'Status Tanah',
            value: _opt(
              m.intOptionsOf(MasterOptionType.statusTanah),
              d['statusTanah'],
            ),
          ),
          InfoRow(
            label: 'Ukuran (P x L x T)',
            value:
                '${SurveyOptions.fmtNum(p)} x ${SurveyOptions.fmtNum(l)} x ${SurveyOptions.fmtNum(t)} m',
          ),
          InfoRow(
            label: 'Jenis Reklame',
            value: _opt(
              m.intOptionsOf(MasterOptionType.jenisReklame),
              d['idJenisReklame'],
            ),
          ),
          InfoRow(
            label: 'Jenis Produk',
            value: _opt(
              m.intOptionsOf(MasterOptionType.jenisProduk),
              d['idJenisProduk'],
            ),
          ),
          InfoRow(
            label: 'Sudut Pandang',
            value: _opt(
              m.intOptionsOf(MasterOptionType.sudutPandang),
              d['sudutPandang'],
            ),
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
    final m = getIt<MasterDataCubit>().state;

    final selfie = info['selfiePath'] as String?;
    final lat = (info['latitude'] as num?)?.toStringAsFixed(6) ?? '-';
    final lng = (info['longitude'] as num?)?.toStringAsFixed(6) ?? '-';
    final tgl = DateTime.tryParse('${info['tanggalSurvey']}');

    final kecId = info['kecamatanId'] as String?;
    final kec = m.optionsOf(MasterOptionType.kecamatan)[kecId] ?? '-';
    final kel = m.kelurahanOf(kecId)[info['kelurahanId']] ?? '-';

    // Petugas pembantu boleh lebih dari satu (list nama dari halaman info).
    final pembantu = [
      for (final n in (info['namaPembantu'] as List? ?? const [])) '$n',
    ];

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
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Color(0xFFB8680F),
              ),
              SizedBox(width: 8),
              Text(
                'Informasi Survey',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2933),
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
                const Expanded(
                  child: Text(
                    'Foto selfie petugas',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF52606D)),
                  ),
                ),
              ],
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFEEF0F3)),
          ),
          InfoRow(label: 'Koordinat', value: '$lat, $lng'),
          InfoRow(label: 'Alamat', value: '${info['alamat'] ?? '-'}'),
          InfoRow(label: 'Kecamatan', value: kec),
          InfoRow(label: 'Kelurahan', value: kel),
          InfoRow(label: 'RT / RW', value: '${info['rt']} / ${info['rw']}'),
          InfoRow(label: 'Keterangan Lokasi', value: '${info['blok'] ?? '-'}'),
          InfoRow(
            label: 'Nama Petugas',
            value: '${info['namaPetugas'] ?? '-'}',
          ),
          InfoRow(
            label: 'Petugas Pembantu',
            value: pembantu.isEmpty ? '-' : pembantu.join(', '),
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
