// lib/presentation/features/reklame/pages/survey_info_page.dart
import 'dart:async';
import 'package:bapendacore/presentation/features/survey_baru/constants/survey_option.dart';
import 'package:bapendacore/presentation/shared/utils/location_util.dart';
import 'package:bapendacore/presentation/shared/widgets/bt_select_fields.dart';
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:bapendacore/presentation/shared/widgets/checkin_card.dart';
import 'package:bapendacore/presentation/shared/widgets/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import 'package:geocoding/geocoding.dart';

class SurveyInfoPage extends StatefulWidget {
  final String nomorPelayanan;
  final List<Map<String, dynamic>> sisiList;

  const SurveyInfoPage({
    super.key,
    required this.nomorPelayanan,
    required this.sisiList,
  });

  @override
  State<SurveyInfoPage> createState() => _SurveyInfoPageState();
}

class _SurveyInfoPageState extends State<SurveyInfoPage> {
  String? _selfiePath;
  double? _lat;
  double? _lng;
  bool _locating = false;

  int? _kecId;
  int? _kelId;
  int? _timId;
  DateTime _tanggal = DateTime.now();

  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _rtCtrl = TextEditingController();
  final _rwCtrl = TextEditingController();
  final _imbCtrl = TextEditingController();
  final _blokCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (final c in [
      _latCtrl,
      _lngCtrl,
      _rtCtrl,
      _rwCtrl,
      _imbCtrl,
      _blokCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _norm(String? s) => (s ?? '')
      .toLowerCase()
      .replaceAll(RegExp(r'^(kecamatan|kelurahan|kec\.|kel\.)\s*'), '')
      .trim();

  /// Cocokkan nama dari geocoding ke master (exact dulu, baru "mengandung").
  int? _matchId(Map<int, String> items, Iterable<String?> candidates) {
    final cs = candidates.map(_norm).where((e) => e.isNotEmpty).toList();
    for (final e in items.entries) {
      if (cs.contains(_norm(e.value))) return e.key;
    }
    for (final e in items.entries) {
      final n = _norm(e.value);
      if (cs.any((c) => c.contains(n))) return e.key;
    }
    return null;
  }

  Future<void> _autofillWilayah(double lat, double lng) async {
    try {
      await setLocaleIdentifier('id_ID');
      final marks = await placemarkFromCoordinates(
        lat,
        lng,
      ).timeout(const Duration(seconds: 8));
      if (marks.isEmpty || !mounted) return;
      final p = marks.first;

      // Di Indonesia, locality biasanya kecamatan & subLocality kelurahan,
      // tapi tidak konsisten, jadi dicoba beberapa kandidat.
      final kecId = _matchId(SurveyOptions.kecamatan, [
        p.locality,
        p.subAdministrativeArea,
        p.subLocality,
      ]);
      if (kecId == null) {
        _snack('Wilayah belum terdeteksi, pilih kecamatan & kelurahan manual.');
        return;
      }
      final kelId = _matchId(
        SurveyOptions.kelurahan[kecId] ?? const <int, String>{},
        [p.subLocality, p.locality],
      );

      setState(() {
        _kecId = kecId;
        _kelId = kelId; // bisa null kalau kelurahan tidak ketemu
      });
      _snack(
        kelId == null
            ? 'Kecamatan terisi otomatis, pilih kelurahan manual.'
            : 'Kecamatan & kelurahan terisi otomatis, cek lagi ya.',
      );
    } catch (_) {
      // Geocoding gagal (offline / tidak ada hasil): diam saja,
      // petugas tetap bisa pilih manual.
    }
  }

  Future<void> _useCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final loc = await LocationUtil.current();
      if (!mounted) return;
      setState(() {
        _lat = loc.lat;
        _lng = loc.lng;
        _latCtrl.text = loc.lat.toStringAsFixed(6);
        _lngCtrl.text = loc.lng.toStringAsFixed(6);
      });
      await _autofillWilayah(loc.lat, loc.lng);
    } on LocationException catch (e) {
      _snack(e.message);
    } on TimeoutException {
      _snack('Sinyal GPS lemah, coba lagi di area yang lebih terbuka.');
    } catch (e) {
      _snack('Gagal mengambil lokasi: $e');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _tanggal = d);
  }

  String? _validate() {
    if (_selfiePath == null) return 'Foto selfie wajib diambil';
    if (_lat == null || _lng == null) {
      return 'Lokasi belum didapat. Tekan "Lokasi Saat Ini"';
    }
    if (_kecId == null || _kelId == null) {
      return 'Pilih kecamatan dan kelurahan';
    }
    if (_rtCtrl.text.trim().isEmpty || _rwCtrl.text.trim().isEmpty) {
      return 'RT dan RW wajib diisi';
    }
    if (_imbCtrl.text.trim().isEmpty) return 'No IMB wajib diisi';
    if (_blokCtrl.text.trim().isEmpty) return 'Blok wajib diisi';
    if (_timId == null) return 'Pilih tim survey';
    return null;
  }

  Map<String, dynamic> _payload() => {
    'selfiePath': _selfiePath,
    'latitude': _lat,
    'longitude': _lng,
    'kecamatanId': _kecId,
    'kelurahanId': _kelId,
    'rt': _rtCtrl.text.trim(),
    'rw': _rwCtrl.text.trim(),
    'noImb': _imbCtrl.text.trim(),
    'blok': _blokCtrl.text.trim(),
    'timSurveyId': _timId,
    'tanggalSurvey': SurveyOptions.isoDate(_tanggal),
  };

  void _next() {
    final err = _validate();
    if (err != null) {
      _snack(err);
      return;
    }
    context.pushNamed(
      AppRoutes.surveySisi,
      extra: (
        nomor: widget.nomorPelayanan,
        sisiList: widget.sisiList,
        info: _payload(),
      ),
    );
  }

  static const _gap = SizedBox(height: 14);

  @override
  Widget build(BuildContext context) {
    final kelItems = _kecId == null
        ? const <int, String>{}
        : (SurveyOptions.kelurahan[_kecId] ?? const <int, String>{});

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
                CheckinCard(
                  path: _selfiePath,
                  onCaptured: (p) {
                    setState(() => _selfiePath = p);
                    _useCurrentLocation(); // selfie masuk -> lokasi + wilayah terisi otomatis
                  },
                ),
                const SizedBox(height: 14),
                Container(
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
                      const SizedBox(height: 14),
                      Button(
                        label: 'Lokasi Saat Ini',
                        icon: Icons.my_location_rounded,
                        variant: BapendaButtonVariant.outlined,
                        height: 44,
                        isLoading: _locating,
                        onPressed: _useCurrentLocation,
                      ),
                      _gap,
                      Row(
                        children: [
                          Expanded(
                            child: BapendaTextField(
                              label: 'Latitude *',
                              controller: _latCtrl,
                              readOnly: true,
                              hint: '-',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: BapendaTextField(
                              label: 'Longitude *',
                              controller: _lngCtrl,
                              readOnly: true,
                              hint: '-',
                            ),
                          ),
                        ],
                      ),
                      _gap,
                      BtSelectField<int>(
                        label: 'Kecamatan *',
                        items: SurveyOptions.kecamatan,
                        value: _kecId,
                        onChanged: (v) => setState(() {
                          _kecId = v;
                          _kelId = null; // kelurahan ikut direset
                        }),
                      ),
                      _gap,
                      BtSelectField<int>(
                        key: ValueKey('kel-$_kecId'),
                        label: 'Kelurahan *',
                        hint: _kecId == null ? 'Pilih kecamatan dulu' : 'Pilih',
                        items: kelItems,
                        value: _kelId,
                        onChanged: (v) => setState(() => _kelId = v),
                      ),
                      _gap,
                      Row(
                        children: [
                          Expanded(
                            child: BapendaTextField(
                              label: 'RT *',
                              controller: _rtCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: BapendaTextField(
                              label: 'RW *',
                              controller: _rwCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                      _gap,
                      BapendaTextField(label: 'No IMB *', controller: _imbCtrl),
                      _gap,
                      BapendaTextField(label: 'Blok *', controller: _blokCtrl),
                      _gap,
                      BtSelectField<int>(
                        label: 'Tim Survey *',
                        items: SurveyOptions.timSurvey,
                        value: _timId,
                        onChanged: (v) => setState(() => _timId = v),
                      ),
                      _gap,
                      BapendaDateField(
                        label: 'Tanggal Survey *',
                        valueText: SurveyOptions.fmtTanggal(_tanggal),
                        onTap: _pickDate,
                      ),
                    ],
                  ),
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
            label: 'Lanjutkan',
            icon: Icons.arrow_forward_rounded,
            iconAtEnd: true,
            onPressed: _next,
          ),
        ),
      ),
    );
  }
}
