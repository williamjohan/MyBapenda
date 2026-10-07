// lib/presentation/features/balai_rw/pages/balai_rw_laporan_page.dart
import 'package:bapendacore/presentation/features/balai_rw/constant/balai_rw_dummy.dart';
import 'package:bapendacore/presentation/shared/utils/date_util.dart';
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:bapendacore/presentation/shared/widgets/form_fields.dart';
import 'package:bapendacore/presentation/shared/widgets/info_row.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';

class BalaiRwLaporanPage extends StatefulWidget {
  final Map<String, dynamic> penugasan;
  final Map<String, dynamic>? initial; // {jawaban, dihadiriOleh}
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

  /// 12 | 2,5 | 1.500.000
  static final _angka = RegExp(r'^\d+([.,]\d+)*$');

  static List<Map<String, dynamic>> _fieldsOf(Map<String, dynamic> section) =>
      (section['fields'] as List).cast<Map<String, dynamic>>();

  final _hadirCtrl = TextEditingController(text: 'Staf Bapenda');

  /// key = kode field ("A.1", dst), dibuat dari form API
  late final Map<String, TextEditingController> _answers = {
    for (final s in BalaiRwDummy.formSections)
      for (final f in _fieldsOf(s))
        f['code'] as String: TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    final d = widget.initial;
    if (d == null) return;
    _hadirCtrl.text = d['dihadiriOleh'] as String? ?? _hadirCtrl.text;
    final j = (d['jawaban'] as Map?) ?? const {};
    _answers.forEach((code, c) => c.text = '${j[code] ?? ''}');
  }

  @override
  void dispose() {
    _hadirCtrl.dispose();
    for (final c in _answers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validate() {
    for (final e in _answers.entries) {
      final v = e.value.text.trim();
      if (v.isEmpty)
        return 'Isian ${e.key} masih kosong (isi 0 kalau tidak ada)';
      if (!_angka.hasMatch(v)) return 'Isian ${e.key} harus berupa angka';
    }
    if (_hadirCtrl.text.trim().isEmpty) return 'Dihadiri oleh wajib diisi';
    return null;
  }

  void _save() {
    final err = _validate();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    context.pop<Map<String, dynamic>>({
      'jawaban': {for (final e in _answers.entries) e.key: e.value.text.trim()},
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

  Widget _sectionCard(Map<String, dynamic> s) {
    final fields = _fieldsOf(s);
    return _card(
      title: s['title'] as String? ?? 'Bagian ${s['code']}',
      icon: Icons.assignment_rounded,
      children: [
        for (var i = 0; i < fields.length; i++) ...[
          if (i > 0) _gap,
          BapendaNumberField(
            label: '${fields[i]['code']}  ${fields[i]['label']}',
            controller: _answers[fields[i]['code']]!,
            hint: widget.readOnly ? '-' : '0',
            suffixText: fields[i]['suffix'] as String?, // opsional dari API
            readOnly: widget.readOnly,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.penugasan;
    final now = DateTime.now();

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
                        Expanded(
                          child: Text(
                            'Mode lihat saja',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF52606D),
                            ),
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
                    InfoRow(
                      label: 'Tanggal',
                      value: DateUtil.tanggal(now),
                    ),
                    InfoRow(
                      label: 'Kecamatan',
                      value: '${t['kecamatan']}',
                    ),
                    InfoRow(
                      label: 'Kelurahan',
                      value: '${t['kelurahan']}',
                    ),
                    InfoRow(label: 'Balai RW', value: '${t['balaiRw']}'),
                  ],
                ),
                for (final s in BalaiRwDummy.formSections) ...[
                  _gap,
                  _sectionCard(s),
                ],
                _gap,
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
                  onPressed: _save,
                ),
              ),
            ),
    );
  }
}
