// lib/presentation/features/balai_rw/pages/balai_rw_laporan_page.dart
import 'package:bapendacore/domain/entities/balai_rw/pertanyaan_entity.dart';
import 'package:bapendacore/presentation/shared/utils/date_util.dart';
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:bapendacore/presentation/shared/widgets/form_fields.dart';
import 'package:bapendacore/presentation/shared/widgets/info_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../cubit/balai_rw_form_cubit.dart';
import '../cubit/balai_rw_form_state.dart';

class BalaiRwLaporanPage extends StatefulWidget {
  final Map<String, dynamic> penugasan;
  final Map<String, dynamic>?
  initial; // {jawaban: {idPertanyaan: nilai}, dihadiriOleh}
  final bool readOnly;

  const BalaiRwLaporanPage({
    super.key,
    required this.penugasan,
    this.initial,
    this.readOnly = false,
  });

  @override
  State<BalaiRwLaporanPage> createState() => _BalaiRwLaporanPageState();
}

class _BalaiRwLaporanPageState extends State<BalaiRwLaporanPage> {
  static const _gap = SizedBox(height: 14);

  /// TODO: pastikan arti kode ini dengan backend. Sementara "5" = angka.
  static const _tipeAngka = '5';

  /// 12 | 2,5 | 1.500.000
  static final _angka = RegExp(r'^\d+([.,]\d+)*$');

  final _hadirCtrl = TextEditingController(text: 'Staf Bapenda');

  /// key = idPertanyaan. Dibuat lazily setelah form dari API termuat.
  final Map<int, TextEditingController> _answers = {};

  Map get _savedJawaban => (widget.initial?['jawaban'] as Map?) ?? const {};

  TextEditingController _ctrl(PertanyaanEntity q) => _answers.putIfAbsent(
    q.idPertanyaan,
    () => TextEditingController(
      text: '${_savedJawaban['${q.idPertanyaan}'] ?? ''}',
    ),
  );

  bool _isAngka(PertanyaanEntity q) => q.tipeJawaban == _tipeAngka;

  @override
  void initState() {
    super.initState();
    final h = widget.initial?['dihadiriOleh'] as String?;
    if (h != null) _hadirCtrl.text = h;
  }

  @override
  void dispose() {
    _hadirCtrl.dispose();
    for (final c in _answers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _code(BalaiRwSection s, PertanyaanEntity q) =>
      '${s.kategori.namaKategori}.${q.seq}';

  String? _validate(List<BalaiRwSection> sections) {
    for (final s in sections) {
      for (final q in s.pertanyaan) {
        final v = _ctrl(q).text.trim();
        final code = _code(s, q);
        if (v.isEmpty) {
          return 'Isian $code masih kosong'
              '${_isAngka(q) ? ' (isi 0 kalau tidak ada)' : ''}';
        }
        if (_isAngka(q) && !_angka.hasMatch(v)) {
          return 'Isian $code harus berupa angka';
        }
      }
    }
    if (_hadirCtrl.text.trim().isEmpty) return 'Dihadiri oleh wajib diisi';
    return null;
  }

  void _save(List<BalaiRwSection> sections) {
    final err = _validate(sections);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    context.pop<Map<String, dynamic>>({
      'jawaban': {
        for (final s in sections)
          for (final q in s.pertanyaan)
            '${q.idPertanyaan}': _ctrl(q).text.trim(),
      },
      'pertanyaan': {
        for (final s in sections)
          for (final q in s.pertanyaan) '${q.idPertanyaan}': q.pertanyaan,
      },
      'dihadiriOleh': _hadirCtrl.text.trim(),
    });
  }

  Widget _card({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
              Icon(icon, size: 18, color: const Color(0xFFB8680F)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2933),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _sectionCard(BalaiRwSection s) {
    return _card(
      title: 'Bagian ${s.kategori.namaKategori}',
      icon: Icons.assignment_rounded,
      children: [
        for (var i = 0; i < s.pertanyaan.length; i++) ...[
          if (i > 0) _gap,
          _field(s, s.pertanyaan[i]),
        ],
      ],
    );
  }

  Widget _field(BalaiRwSection s, PertanyaanEntity q) {
    final label = '${_code(s, q)}  ${q.pertanyaan}';
    final ctrl = _ctrl(q);

    if (_isAngka(q)) {
      return BapendaNumberField(
        label: label,
        controller: ctrl,
        hint: widget.readOnly ? '-' : '0',
        readOnly: widget.readOnly,
      );
    }
    return BapendaTextField(
      label: label,
      controller: ctrl,
      hint: widget.readOnly ? '-' : null,
      readOnly: widget.readOnly,
      maxLines: 2,
    );
  }

  Widget _statusBody(BalaiRwFormState st) {
    if (st.status == BalaiRwFormStatus.failure) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: Color(0xFF9AA5B1),
            ),
            const SizedBox(height: 12),
            Text(
              st.error ?? 'Gagal memuat form',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF7B8794),
              ),
            ),
            const SizedBox(height: 16),
            Button(
              label: 'Coba Lagi',
              icon: Icons.refresh_rounded,
              variant: BapendaButtonVariant.outlined,
              expanded: false,
              height: 44,
              onPressed: () => context.read<BalaiRwFormCubit>().load(),
            ),
          ],
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.penugasan;
    final now = DateTime.now();

    return BlocBuilder<BalaiRwFormCubit, BalaiRwFormState>(
      builder: (context, st) {
        final ready = st.status == BalaiRwFormStatus.success;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6F8),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              BapendaSliverHeader(
                title: 'Laporan Pelayanan',
                showBackButton: true,
                subtitle: Text(
                  '${t['balaiRw']}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(18),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (widget.readOnly) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF0F3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.visibility_outlined,
                              size: 20,
                              color: Color(0xFF52606D),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Mode lihat saja',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF52606D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _gap,
                    ],
                    _card(
                      title: 'Informasi Laporan',
                      icon: Icons.location_on_outlined,
                      children: [
                        InfoRow(label: 'Hari', value: DateUtil.hari(now)),
                        InfoRow(label: 'Tanggal', value: DateUtil.tanggal(now)),
                        InfoRow(label: 'Kecamatan', value: '${t['kecamatan']}'),
                        InfoRow(label: 'Kelurahan', value: '${t['kelurahan']}'),
                        InfoRow(label: 'Balai RW', value: '${t['balaiRw']}'),
                      ],
                    ),

                    if (!ready)
                      _statusBody(st)
                    else ...[
                      for (final s in st.sections) ...[_gap, _sectionCard(s)],
                      _gap,
                      _card(
                        title: 'Kehadiran',
                        icon: Icons.groups_rounded,
                        children: [
                          BapendaTextField(
                            label: 'Dihadiri oleh *',
                            controller: _hadirCtrl,
                            readOnly: widget.readOnly,
                          ),
                        ],
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          ),
          bottomNavigationBar: widget.readOnly
              ? null
              : SafeArea(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                    child: Button(
                      label: 'Simpan Laporan',
                      icon: Icons.save_rounded,
                      onPressed: ready ? () => _save(st.sections) : null,
                    ),
                  ),
                ),
        );
      },
    );
  }
}
