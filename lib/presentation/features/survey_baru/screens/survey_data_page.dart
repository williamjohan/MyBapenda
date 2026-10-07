// lib/presentation/features/reklame/pages/survey_data_page.dart
import 'package:bapendacore/presentation/features/survey_baru/constants/survey_option.dart';
import 'package:bapendacore/presentation/shared/widgets/bt_select_fields.dart';
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:bapendacore/presentation/shared/widgets/form_fields.dart';
import 'package:bapendacore/presentation/shared/widgets/info_row.dart';
import 'package:bapendacore/presentation/shared/widgets/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';

class SurveyDataPage extends StatefulWidget {
  final Map<String, dynamic> sisi;
  final Map<String, dynamic>? initial;

  const SurveyDataPage({super.key, required this.sisi, this.initial});

  @override
  State<SurveyDataPage> createState() => _SurveyDataPageState();
}

enum _NorMode { cari, baru }

class _SurveyDataPageState extends State<SurveyDataPage> {
  int? _lokasiTertentuId;
  int? _letakId;
  int? _statusTanahId;
  int? _jenisReklameId;
  int? _jenisProdukId;
  int? _sudutId;

  // Persil / NOR baru (hanya dipakai kalau sisi belum punya nor)
  _NorMode _norMode = _NorMode.cari;

  // Mode cari
  final _cariNorCtrl = TextEditingController();
  bool _searchingNor = false;
  List<Map<String, dynamic>> _norResults = [];
  Map<String, dynamic>? _norTerpilih; // {id, nor, alamat}

  // Mode baru
  int? _jenisPengajuanId;
  int? _jenisBangunanId;
  int? _namaJalanId;
  final _nopCtrl = TextEditingController();
  final _noAlamatCtrl = TextEditingController();

  // TODO: hapus kalau sudah ada API cari NOR
  static const _dummyNor = <Map<String, dynamic>>[
    {'id': 101, 'nor': '10.2026.0001', 'alamat': 'Jl. Basuki Rahmat No. 12'},
    {'id': 102, 'nor': '10.2026.0002', 'alamat': 'Jl. Raya Darmo No. 45'},
    {'id': 103, 'nor': '10.2026.0003', 'alamat': 'Jl. Ahmad Yani No. 8'},
  ];

  late final TextEditingController _lokasiCtrl = TextEditingController(
    text: widget.sisi['lokPenyelenggaraanPermohonan'] as String? ?? '',
  );
  late final TextEditingController _materiCtrl = TextEditingController(
    text: widget.sisi['materiReklamePermohonan'] as String? ?? '',
  );
  final _pCtrl = TextEditingController();
  final _lCtrl = TextEditingController();
  final _tCtrl = TextEditingController();
  final _ketSisiCtrl = TextEditingController();
  final _ketSurveyCtrl = TextEditingController();

  bool get _sudahPunyaNor => widget.sisi['nor'] != null;

  @override
  void initState() {
    super.initState();
    final d = widget.initial;
    if (d == null) return;

    int? id(dynamic v) => (v is int && v != 0) ? v : null;
    String txt(dynamic v) => (v is num && v > 0) ? SurveyOptions.fmtNum(v) : '';

    _lokasiTertentuId = id(d['lokasiTertentuId']);
    _letakId = id(d['letakReklame']);
    _statusTanahId = id(d['statusTanah']);
    _jenisReklameId = id(d['idJenisReklame']);
    _jenisProdukId = id(d['idJenisProduk']);
    _sudutId = id(d['sudutPandang']);
    final nb = d['norBaru'];
    if (nb is Map) {
      _norMode = _NorMode.baru;
      _jenisPengajuanId = id(nb['jenisPengajuanId']);
      _jenisBangunanId = id(nb['jenisBangunanId']);
      _namaJalanId = id(nb['namaJalanId']);
      _nopCtrl.text = nb['nopPbb'] as String? ?? '';
      _noAlamatCtrl.text = nb['noAlamat'] as String? ?? '';
    } else if (d['idNor'] != null) {
      _norTerpilih = {
        'id': d['idNor'],
        'nor': d['norLabel'] ?? '-',
        'alamat': '',
      };
    }
    _lokasiCtrl.text = d['lokPenyelenggaraan'] as String? ?? _lokasiCtrl.text;
    _materiCtrl.text = d['materiReklame'] as String? ?? _materiCtrl.text;
    _pCtrl.text = txt(d['panjang']);
    _lCtrl.text = txt(d['lebar']);
    _tCtrl.text = txt(d['tinggi']);
    _ketSisiCtrl.text = d['ketSisi'] as String? ?? '';
    _ketSurveyCtrl.text = d['ketSurvey'] as String? ?? '';
  }

  @override
  void dispose() {
    for (final c in [
      _cariNorCtrl,
      _nopCtrl,
      _noAlamatCtrl,
      _lokasiCtrl,
      _materiCtrl,
      _pCtrl,
      _lCtrl,
      _tCtrl,
      _ketSisiCtrl,
      _ketSurveyCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  Future<void> _cariNor() async {
    final q = _cariNorCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Isi kata kunci NOR dulu')));
      return;
    }
    setState(() => _searchingNor = true);
    try {
      // TODO: ganti dengan panggilan API cari NOR
      await Future.delayed(const Duration(milliseconds: 600));
      final hasil = _dummyNor
          .where(
            (e) =>
                '${e['nor']}'.toLowerCase().contains(q) ||
                '${e['alamat']}'.toLowerCase().contains(q),
          )
          .toList();
      if (!mounted) return;
      setState(() => _norResults = hasil);
    } finally {
      if (mounted) setState(() => _searchingNor = false);
    }
  }

  /// Bentuknya sama dengan objek `survey` di API.
  Map<String, dynamic> _payload() => {
    'seq': widget.sisi['seq'],
    'idNor': (_sudahPunyaNor || _norMode != _NorMode.cari)
        ? null
        : _norTerpilih?['id'],
    'norLabel': _norTerpilih?['nor'], // hanya untuk tampilan lokal
    'norBaru': (_sudahPunyaNor || _norMode != _NorMode.baru)
        ? null
        : {
            'jenisPengajuanId': _jenisPengajuanId,
            'jenisBangunanId': _jenisBangunanId,
            'nopPbb': _nopCtrl.text.trim(),
            'namaJalanId': _namaJalanId,
            'noAlamat': _noAlamatCtrl.text.trim(),
          },
    'lokasiTertentuId': _lokasiTertentuId ?? 0,
    'letakReklame': _letakId ?? 0,
    'statusTanah': _statusTanahId ?? 0,
    'lokPenyelenggaraan': _lokasiCtrl.text.trim(),
    'panjang': _num(_pCtrl),
    'lebar': _num(_lCtrl),
    'tinggi': _num(_tCtrl),
    'idJenisReklame': _jenisReklameId ?? 0,
    'idJenisProduk': _jenisProdukId ?? 0,
    'sudutPandang': _sudutId ?? 0,
    'ketSisi': _ketSisiCtrl.text.trim(),
    'materiReklame': _materiCtrl.text.trim(),
    'ketSurvey': _ketSurveyCtrl.text.trim(),
  };

  String? _validate() {
    if (!_sudahPunyaNor) {
      if (_norMode == _NorMode.cari) {
        if (_norTerpilih == null) {
          return 'Pilih NOR dari hasil pencarian, atau tambah NOR baru';
        }
      } else if (_jenisPengajuanId == null ||
          _jenisBangunanId == null ||
          _namaJalanId == null ||
          _nopCtrl.text.trim().isEmpty ||
          _noAlamatCtrl.text.trim().isEmpty) {
        return 'Lengkapi semua data nomor baru';
      }
    }
    if (_lokasiTertentuId == null ||
        _letakId == null ||
        _statusTanahId == null ||
        _jenisReklameId == null ||
        _jenisProdukId == null ||
        _sudutId == null) {
      return 'Lengkapi semua pilihan dulu';
    }
    if (_num(_pCtrl) <= 0 || _num(_lCtrl) <= 0 || _num(_tCtrl) <= 0) {
      return 'Ukuran reklame harus lebih dari 0';
    }
    return null;
  }

  void _save() {
    final err = _validate();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    // TODO: simpan lewat Cubit. Sementara dikembalikan ke halaman sebelumnya.
    context.pop<Map<String, dynamic>>(_payload());
  }

  static const _gap = SizedBox(height: 14);

  Widget _buildNorPicker() {
    return _card(
      title: 'NOR',
      icon: Icons.pin_drop_rounded,
      children: [
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<_NorMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: _NorMode.cari,
                icon: Icon(Icons.search_rounded, size: 18),
                label: Text('Cari NOR'),
              ),
              ButtonSegment(
                value: _NorMode.baru,
                icon: Icon(Icons.add_location_alt_rounded, size: 18),
                label: Text('NOR Baru'),
              ),
            ],
            selected: {_norMode},
            onSelectionChanged: (s) => setState(() => _norMode = s.first),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: const Color(0xFFFFF3DC),
              selectedForegroundColor: const Color(0xFFB8680F),
            ),
          ),
        ),
        if (_norMode == _NorMode.cari) ...[
          _gap,
          if (_norTerpilih != null)
            _norTile(
              _norTerpilih!,
              selected: true,
              onTap: () => setState(() {
                _norTerpilih = null;
                _norResults = [];
              }),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: BapendaTextField(
                    label: 'Cari NOR',
                    hint: 'Nomor NOR / alamat',
                    controller: _cariNorCtrl,
                  ),
                ),
                const SizedBox(width: 10),
                Button(
                  label: 'Cari',
                  icon: Icons.search_rounded,
                  expanded: false,
                  height: 48,
                  isLoading: _searchingNor,
                  onPressed: _cariNor,
                ),
              ],
            ),
            for (final r in _norResults) ...[
              const SizedBox(height: 8),
              _norTile(
                r,
                selected: false,
                onTap: () => setState(() => _norTerpilih = r),
              ),
            ],
          ],
        ],
      ],
    );
  }

  Widget _norTile(
    Map<String, dynamic> n, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? const Color(0xFFE6F6EC) : const Color(0xFFF5F6F8),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle_rounded : Icons.pin_drop_outlined,
                size: 20,
                color: selected
                    ? const Color(0xFF1B8A4B)
                    : const Color(0xFFB8680F),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${n['nor']}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2933),
                      ),
                    ),
                    if ('${n['alamat'] ?? ''}'.isNotEmpty)
                      Text(
                        '${n['alamat']}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF7B8794),
                        ),
                      ),
                  ],
                ),
              ),
              if (selected)
                Text(
                  'Ganti',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB8680F),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNorBaruForm() {
    return _card(
      title: 'Input Nomor Baru',
      icon: Icons.edit_note_rounded,
      children: [
        BtSelectField<int>(
          label: 'Jenis Pengajuan *',
          items: SurveyOptions.jenisPengajuan,
          value: _jenisPengajuanId,
          onChanged: (v) => setState(() => _jenisPengajuanId = v),
        ),
        _gap,
        BtSelectField<int>(
          label: 'Jenis Bangunan *',
          items: SurveyOptions.jenisBangunan,
          value: _jenisBangunanId,
          onChanged: (v) => setState(() => _jenisBangunanId = v),
        ),
        _gap,
        BapendaTextField(
          label: 'NOP PBB *',
          hint: 'Masukkan NOP PBB',
          controller: _nopCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        _gap,
        BtSelectField<int>(
          label: 'Nama Jalan *',
          hint: 'Pilih nama jalan',
          items: SurveyOptions.namaJalan,
          value: _namaJalanId,
          onChanged: (v) => setState(() => _namaJalanId = v),
        ),
        _gap,
        BapendaTextField(
          label: 'No. Alamat *',
          hint: 'Masukkan nomor alamat',
          controller: _noAlamatCtrl,
        ),
      ],
    );
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
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2933),
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

  @override
  Widget build(BuildContext context) {
    final s = widget.sisi;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          BapendaSliverHeader(
            title: 'Survey Permohonan Baru',
            showBackButton: true,
            subtitle: Text(
              'Sisi ${s['seq']}',
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
                currentIndex: 1,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(18),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _card(
                  title: 'Data Permohonan',
                  icon: Icons.description_rounded,
                  children: [
                    InfoRow(
                      label: 'Jenis Reklame',
                      value: '${s['jenisReklameNama'] ?? '-'}',
                    ),
                    InfoRow(
                      label: 'Lokasi',
                      value: '${s['lokPenyelenggaraanPermohonan'] ?? '-'}',
                    ),
                    InfoRow(
                      label: 'Materi',
                      value: '${s['materiReklamePermohonan'] ?? '-'}',
                    ),
                    InfoRow(
                      label: 'Masa Tayang',
                      value: '${s['masaTayang'] ?? '-'}',
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // NOR sudah ada -> read-only, input persil disembunyiin
                if (_sudahPunyaNor)
                  _card(
                    title: 'NOR',
                    icon: Icons.pin_drop_rounded,
                    children: [
                      InfoRow(label: 'NOR Terdaftar', value: '${s['nor']}'),
                    ],
                  )
                else ...[
                  _buildNorPicker(),
                  if (_norMode == _NorMode.baru) ...[
                    const SizedBox(height: 14),
                    _buildNorBaruForm(),
                  ],
                ],
                const SizedBox(height: 14),

                _card(
                  title: 'Data Hasil Survey',
                  icon: Icons.assignment_rounded,
                  children: [
                    BtSelectField<int>(
                      label: 'Lokasi Tertentu',
                      items: SurveyOptions.lokasiTertentu,
                      value: _lokasiTertentuId,
                      onChanged: (v) => setState(() => _lokasiTertentuId = v),
                    ),
                    _gap,
                    BtSelectField<int>(
                      label: 'Letak Reklame',
                      items: SurveyOptions.letakReklame,
                      value: _letakId,
                      onChanged: (v) => setState(() => _letakId = v),
                    ),
                    _gap,
                    BtSelectField<int>(
                      label: 'Status Tanah',
                      items: SurveyOptions.statusTanah,
                      value: _statusTanahId,
                      onChanged: (v) => setState(() => _statusTanahId = v),
                    ),
                    _gap,
                    BapendaTextField(
                      label: 'Lokasi Penyelenggaraan',
                      controller: _lokasiCtrl,
                    ),
                    _gap,
                    Row(
                      children: [
                        Expanded(
                          child: BapendaTextField(
                            label: 'Panjang (P)',
                            suffixText: 'm',
                            controller: _pCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: BapendaTextField(
                            label: 'Lebar (L)',
                            suffixText: 'm',
                            controller: _lCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: BapendaTextField(
                            label: 'Tinggi (T)',
                            suffixText: 'm',
                            controller: _tCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    _gap,
                    BtSelectField<int>(
                      label: 'Jenis Reklame',
                      items: SurveyOptions.jenisReklame,
                      value: _jenisReklameId,
                      onChanged: (v) => setState(() => _jenisReklameId = v),
                    ),
                    _gap,
                    BtSelectField<int>(
                      label: 'Jenis Produk',
                      items: SurveyOptions.jenisProduk,
                      value: _jenisProdukId,
                      onChanged: (v) => setState(() => _jenisProdukId = v),
                    ),
                    _gap,
                    BtSelectField<int>(
                      label: 'Sudut Pandang',
                      items: SurveyOptions.sudutPandang,
                      value: _sudutId,
                      onChanged: (v) => setState(() => _sudutId = v),
                    ),
                    _gap,
                    BapendaTextField(
                      label: 'Materi Reklame',
                      controller: _materiCtrl,
                    ),
                    _gap,
                    BapendaTextField(
                      label: 'Keterangan Sisi (Opsional)',
                      controller: _ketSisiCtrl,
                      maxLines: 2,
                    ),
                    _gap,
                    BapendaTextField(
                      label: 'Keterangan Survey (Opsional)',
                      hint: 'Tambahkan catatan jika ada...',
                      controller: _ketSurveyCtrl,
                      maxLines: 3,
                      maxLength: 200,
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: Button(
            label: 'Simpan & Lanjutkan',
            icon: Icons.arrow_forward_rounded,
            iconAtEnd: true,
            onPressed: _save,
          ),
        ),
      ),
    );
  }
}
