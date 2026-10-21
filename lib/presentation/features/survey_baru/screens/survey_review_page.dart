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
import 'package:bapendacore/presentation/shared/widgets/mb_dialog.dart';
import 'package:bapendacore/presentation/shared/widgets/photo_preview.dart';
import 'package:bapendacore/presentation/shared/widgets/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../widgets/hasil_simpan_survey.dart';
import '../widgets/peta_lokasi_reklame.dart';
import 'survey_foto_page.dart';

class SurveyReviewPage extends StatefulWidget {
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

  @override
  State<SurveyReviewPage> createState() => _SurveyReviewPageState();
}

class _SurveyReviewPageState extends State<SurveyReviewPage> {
  bool _agreementAccepted = false;

  String _formatTanggalSurvey(Object? value) {
    if (value == null) return '-';

    final raw = value.toString().trim();
    if (raw.isEmpty) return '-';

    final tanggal = DateTime.tryParse(raw);
    return tanggal == null ? raw : SurveyOptions.fmtTanggal(tanggal);
  }

  Future<void> _submit(BuildContext context) async {
    if (!_agreementAccepted) {
      await BapendaDialog.showWarning(
        context,
        title: 'Persetujuan Belum Dicentang',
        message: 'Centang pernyataan petugas survey sebelum mengirim hasil.',
        primaryLabel: 'Mengerti',
      );
      return;
    }

    final ok = await BapendaDialog.showConfirm(
      context,
      title: 'Kirim hasil survey?',
      message:
          'Pastikan foto, titik reklame, dan data semua sisi sudah benar. '
          'Bila semua isian lengkap, survey langsung dikirim ke penilaian; '
          'bila belum, disimpan sebagai draft.',
      confirmLabel: 'Kirim',
      cancelLabel: 'Cek Lagi',
      icon: Icons.send_rounded,
    );
    if (!ok || !context.mounted) return;

    await _kirim(context);
  }

  Future<void> _kirim(BuildContext context) async {
    final cubit = context.read<SurveySubmitCubit>();

    final res = await BapendaDialog.runWithLoading(
      context,
      (_) => cubit.submit(
        info: widget.info,
        sisiList: widget.sisiList,
        results: widget.results,
      ),
      title: 'Mengirim Hasil Survey',
      message: 'Mohon tunggu, jangan tutup aplikasi.',
    );
    if (!context.mounted) return;

    final hasil = res.hasil;
    if (hasil == null) {
      final error = res.error;
      if (error != null) {
        final ulang = await BapendaDialog.showError(
          context,
          title: 'Gagal Mengirim Survey',
          message: error,
          retryLabel: 'Coba Lagi',
        );
        if (ulang && context.mounted) await _kirim(context);
      }
      return;
    }

    await tampilkanHasilSimpanSurvey(context, hasil);
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
              widget.nomorPelayanan,
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
                labels: ['Lokasi & Foto', 'Data', 'Review'],
                currentIndex: 2,
              ),
            ),
          ),
          if (widget.sisiList.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: SurveyHeaderCard(
                  sisi: widget.sisiList.first,
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
              child: _InfoReviewCard(info: widget.info),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            sliver: SliverList.separated(
              itemCount: widget.sisiList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final s = widget.sisiList[i];
                final seq = s['seq'] as int;
                final r = widget.results[seq];
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              child: _SurveyAgreementCard(
                namaPetugas: widget.info['namaPetugas'] as String?,
                nipPetugas: widget.info['nipPetugas'] as String?,
                tanggalSurvey: _formatTanggalSurvey(
                  widget.info['tanggalSurvey'],
                ),
                accepted: _agreementAccepted,
                onChanged: (value) {
                  setState(() => _agreementAccepted = value ?? false);
                },
              ),
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
              onPressed: sending || !_agreementAccepted
                  ? null
                  : () => _submit(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pernyataan dan persetujuan petugas sebelum hasil survey dikirim.
class _SurveyAgreementCard extends StatelessWidget {
  final String? namaPetugas;
  final String? nipPetugas;
  final String tanggalSurvey;
  final bool accepted;
  final ValueChanged<bool?> onChanged;

  const _SurveyAgreementCard({
    required this.namaPetugas,
    required this.nipPetugas,
    required this.tanggalSurvey,
    required this.accepted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final nama = (namaPetugas ?? '').trim();
    final nip = (nipPetugas ?? '').trim();
    final identitas = [
      if (nama.isNotEmpty) nama else 'Nama petugas belum tersedia',
      if (nip.isNotEmpty) '($nip)',
    ].join(' ');

    const headingStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1F2933),
    );
    const bodyStyle = TextStyle(
      fontSize: 12.5,
      height: 1.45,
      color: Color(0xFF52606D),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EBEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.fact_check_outlined,
                size: 20,
                color: Color(0xFFB8680F),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text('Pernyataan Petugas Survey', style: headingStyle),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Dengan ini saya, $identitas, menyatakan bahwa:',
            style: bodyStyle.copyWith(color: const Color(0xFF1F2933)),
          ),
          const SizedBox(height: 10),
          _AgreementStatement(
            text:
                'Survey telah saya laksanakan secara langsung di lokasi reklame pada tanggal $tanggalSurvey.',
          ),
          const SizedBox(height: 9),
          const _AgreementStatement(
            text:
                'Seluruh data, ukuran, titik lokasi, dan foto yang saya input adalah benar, lengkap, dan sesuai dengan kondisi sebenarnya di lapangan.',
          ),
          const SizedBox(height: 9),
          const _AgreementStatement(
            text:
                'Hasil survey ini dapat dipertanggungjawabkan dan akan digunakan sebagai dasar penilaian serta penetapan pajak reklame.',
          ),
          const SizedBox(height: 9),
          const _AgreementStatement(
            text:
                'Apabila di kemudian hari ditemukan ketidaksesuaian atau data yang tidak benar, saya bersedia bertanggung jawab sesuai dengan ketentuan peraturan perundang-undangan yang berlaku.',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFEEF0F3)),
          ),
          CheckboxListTile(
            value: accepted,
            onChanged: onChanged,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            visualDensity: VisualDensity.compact,
            activeColor: const Color(0xFFB8680F),
            title: const Text(
              'Saya telah membaca, memahami, dan menyetujui pernyataan di atas.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2933),
              ),
            ),
          ),
          if (!accepted)
            const Padding(
              padding: EdgeInsets.only(left: 48, top: 2),
              child: Text(
                'Centang persetujuan untuk mengaktifkan tombol kirim.',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF7B8794)),
              ),
            ),
        ],
      ),
    );
  }
}

class _AgreementStatement extends StatelessWidget {
  final String text;

  const _AgreementStatement({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Icon(Icons.circle, size: 5, color: Color(0xFFB8680F)),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Color(0xFF52606D),
            ),
          ),
        ),
      ],
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
          const SizedBox(height: 14),
          const _ReviewSectionLabel(
            icon: Icons.photo_library_outlined,
            title: 'Dokumentasi Foto Sisi',
            subtitle: 'Foto reklame pada sisi yang sedang disurvei',
          ),
          const SizedBox(height: 10),
          if (isFotoDraft(f))
            const _FotoDraftReview()
          else
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
          if (result.lokasi case final lokasi?) ...[
            const SizedBox(height: 16),
            const _ReviewSectionLabel(
              icon: Icons.map_outlined,
              title: 'Lokasi Reklame',
              subtitle: 'Titik lokasi sisi reklame pada peta',
            ),
            const SizedBox(height: 10),
            PetaLokasiReklame(lokasi: lokasi),
          ],
          Padding(
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

class _InfoReviewCard extends StatefulWidget {
  final Map<String, dynamic> info;
  const _InfoReviewCard({required this.info});

  @override
  State<_InfoReviewCard> createState() => _InfoReviewCardState();
}

class _InfoReviewCardState extends State<_InfoReviewCard> {
  Future<void> _editAlamat() async {
    final controller = TextEditingController(
      text: '${widget.info['alamat'] ?? ''}',
    );
    final formKey = GlobalKey<FormState>();

    final alamatBaru = await BapendaDialog.show<String>(
      context,
      tone: BapendaDialogTone.info,
      icon: Icons.edit_location_alt_outlined,
      title: 'Ubah Alamat',
      message: 'Alamat ini ikut terkirim bersama hasil survey.',
      barrierDismissible: false, 
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Alamat',
            hintText: 'Masukkan alamat lokasi survei',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Alamat tidak boleh kosong'
              : null,
        ),
      ),
      actions: [
        BapendaDialogAction<String>.primary(
          label: 'Simpan',
          icon: Icons.check_rounded,
          closeOnPressed: false, 
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pop(controller.text.trim());
            }
          },
        ),
        const BapendaDialogAction<String>.secondary(label: 'Batal'),
      ],
    );

    Future.delayed(const Duration(milliseconds: 350), controller.dispose);

    if (alamatBaru == null || !mounted) return;

    setState(() {
      widget.info['alamat'] = alamatBaru;
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: InfoRow(
                  label: 'Alamat',
                  value: '${info['alamat'] ?? '-'}',
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Ubah alamat',
                onPressed: _editAlamat,
                icon: const Icon(Icons.edit_outlined, size: 18),
                style: IconButton.styleFrom(
                  foregroundColor: const Color(0xFFB8680F),
                  backgroundColor: const Color(0xFFFFF3E7),
                  minimumSize: const Size(36, 36),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
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

/// Pengganti preview foto untuk sisi yang memakai foto draft server.
class _FotoDraftReview extends StatelessWidget {
  const _FotoDraftReview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_done_rounded, color: Color(0xFFB8680F)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Foto reklame memakai foto yang tersimpan di draft.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF7A4A0C)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Label bagian untuk memisahkan dokumentasi foto dan lokasi pada halaman review.
class _ReviewSectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ReviewSectionLabel({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E7),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFFB8680F)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2933),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.3,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
