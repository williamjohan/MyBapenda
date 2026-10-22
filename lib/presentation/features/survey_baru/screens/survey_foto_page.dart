// lib/presentation/features/survey_baru/screens/survey_foto_page.dart
import 'dart:io';

import 'package:mybapenda/core/theme/theme_kit.dart';
import 'package:mybapenda/core/utils/app_file_picker_utils.dart';
import 'package:mybapenda/presentation/features/survey_baru/cubit/survey_lokasi/survey_lokasi_state.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_header_card.dart';
import 'package:mybapenda/presentation/shared/widgets/button.dart';
import 'package:mybapenda/presentation/shared/widgets/form_fields.dart';
import 'package:mybapenda/presentation/shared/widgets/marker_box.dart';
import 'package:mybapenda/presentation/shared/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:mybapenda/presentation/shared/widgets/theme_toggle_button.dart';
import '../../../shared/widgets/bapenda_image.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';

typedef SurveyFoto = ({
  String path,
  String source,
  double ratio,
  Rect box,
  String keterangan,
});

typedef SurveyData = Map<String, dynamic>;

/// Penanda [SurveyData] hasil Simpan Draft (isian boleh belum lengkap).
const kunciDraftData = 'draft';

bool isDataDraft(SurveyData? data) => data?[kunciDraftData] == true;

/// [lokasi] = pinpoint reklame sisi ini (halaman peta). Null untuk hasil
/// lama yang dibuat sebelum ada pinpoint.
typedef SurveyResult = ({
  SurveyFoto foto,
  SurveyData data,
  SurveyLokasiHasil? lokasi,
});

/// Kotak penanda awal untuk foto baru (0..1 relatif ke foto).
const kotakAwalFoto = Rect.fromLTWH(0.28, 0.2, 0.44, 0.4);

/// Foto kamera baru: rasio dihitung, kotak default, belum ada keterangan.
Future<SurveyFoto> fotoSurveyBaru(String path) async {
  final img = await decodeImageFromList(await File(path).readAsBytes());
  final ratio = img.width / img.height;
  img.dispose();
  return (
    path: path,
    source: path,
    ratio: ratio,
    box: kotakAwalFoto,
    keterangan: '',
  );
}

/// Ambil foto reklame dari kamera (null = batal).
Future<SurveyFoto?> ambilFotoSurvey() async {
  final file = await AppFilePickerUtils.pickImage(fromCamera: true);
  if (file == null) return null;
  return fotoSurveyBaru(file.path);
}

List<Map<String, dynamic>> apiFotosOf(Map<String, dynamic> sisi) {
  final survey = sisi['survey'];
  final fotos = survey is Map ? survey['fotos'] : null;
  if (fotos is! List) return const [];
  return [
    for (final f in fotos)
      if (f is Map) Map<String, dynamic>.from(f),
  ];
}

List<Map<String, dynamic>> wpFotosOf(Map<String, dynamic> sisi) {
  final fotos = sisi['fotosWp'];
  if (fotos is! List) return const [];
  return [
    for (final f in fotos)
      if (f is Map) Map<String, dynamic>.from(f),
  ];
}

/// Penanda foto sisi yang sudah tersimpan di draft server. `survey-form`
/// tidak mengirim URL foto draft sisi, jadi fotonya tidak bisa ditampilkan;
/// sisi dikirim tanpa foto dan server memakai foto draft tersimpan.
const pathFotoDraft = 'draft://foto-sisi';

const SurveyFoto fotoDraftServer = (
  path: pathFotoDraft,
  source: pathFotoDraft,
  ratio: 4 / 3,
  box: kotakAwalFoto,
  keterangan: '',
);

bool isFotoDraft(SurveyFoto? f) => f?.path == pathFotoDraft;

/// Sisi survey baru yang sudah ber-draft di server (titik reklame ada):
/// foto & titik draft berlaku, petugas tidak perlu foto ulang. Survey ulang
/// (dikembalikan penilai) selalu wajib foto baru.
bool punyaFotoDraft(Map<String, dynamic> sisi) {
  final h = sisi['header'];
  if (h is! Map || h['isDraft'] != true || h['dikembalikan'] == true) {
    return false;
  }
  return titikDraftOf(sisi) != null && apiFotosOf(sisi).isEmpty;
}

/// Titik reklame tersimpan di draft server (`survey.latitude/longitude`).
TitikPeta? titikDraftOf(Map<String, dynamic> sisi) {
  final survey = sisi['survey'];
  if (survey is! Map) return null;
  final lat = survey['latitude'], lng = survey['longitude'];
  if (lat is! num || lng is! num || (lat == 0 && lng == 0)) return null;
  return (lat: lat.toDouble(), lng: lng.toDouble());
}

/// Radius maksimal pin dari `survey-form` (meter); null = server belum
/// mengirim.
int? jarakMaksOf(Map<String, dynamic> sisi) {
  final h = sisi['header'];
  final v = h is Map ? h['jarakMaksMeter'] : null;
  return v is int && v > 0 ? v : null;
}

/// Sisi untuk "sisi ke-N" di pesan server: seq N, atau urutan ke-N bila
/// tidak ada seq itu.
Map<String, dynamic>? sisiKe(List<Map<String, dynamic>> sisiList, int n) {
  for (final s in sisiList) {
    if (s['seq'] == n) return s;
  }
  return n >= 1 && n <= sisiList.length ? sisiList[n - 1] : null;
}

/// Isian sisi dari server (draft tersimpan / survey lama yang dikembalikan)
/// dalam bentuk [SurveyData] halaman Data. Null bila belum ada isian.
/// Ditandai draft: petugas tetap harus melewati halaman Data sebelum kirim.
SurveyData? dataDraftOf(Map<String, dynamic> sisi) {
  final sv = sisi['survey'];
  if (sv is! Map) return null;
  const isian = [
    'idNor',
    'idPersil',
    'lokasiTertentuId',
    'letakReklame',
    'statusTanah',
    'lokPenyelenggaraan',
    'panjang',
    'lebar',
    'tinggi',
    'idJenisReklame',
    'idJenisProduk',
    'sudutPandang',
    'ketSisi',
    'materiReklame',
    'ketSurvey',
  ];
  if (!isian.any((k) => sv[k] != null)) return null;
  return {
    for (final k in isian) k: sv[k],
    'seq': sisi['seq'],
    // lokPenyelenggaraan dari server = id master lokasi penyelenggaraan.
    'lokasiPenyelenggaraanId': int.tryParse('${sv['lokPenyelenggaraan']}'),
    // Draft hanya menyimpan persil NOR baru; jenis bangunan, jalan & no
    // alamat diisi ulang petugas sebelum kirim.
    if (sisi['nor'] == null && sv['idPersil'] != null)
      'norBaru': {
        'persilId': '${sv['idPersil']}',
        'persilLabel': '${sv['idPersil']}',
      },
    kunciDraftData: true,
  };
}

String? fotoUrlOf(Map<String, dynamic> m) =>
    (m['url'] ?? m['fotoUrl'] ?? m['path'])?.toString();

/// Editor foto survey satu sisi: tandai reklame dengan kotak, isi
/// keterangan, atau ambil ulang. Dibuka dari halaman lokasi (peta).
/// Mengembalikan foto dengan kotak & keterangan baru (garis kotak belum
/// digambar; digambar saat Lanjut di halaman lokasi).
class SurveyFotoPage extends StatefulWidget {
  final Map<String, dynamic> sisi;
  final SurveyFoto foto;

  /// true: foto dimuat dari server (bukan jepretan baru).
  final bool dariServer;

  const SurveyFotoPage({
    super.key,
    required this.sisi,
    required this.foto,
    this.dariServer = false,
  });

  @override
  State<SurveyFotoPage> createState() => _SurveyFotoPageState();
}

class _SurveyFotoPageState extends State<SurveyFotoPage> {
  Color get _brand => context.palette.accent;

  late final TextEditingController _ketCtrl = TextEditingController(
    text: widget.foto.keterangan,
  );
  late SurveyFoto _foto = widget.foto;
  late bool _fromServer = widget.dariServer;
  bool _busy = false; // ambil foto
  bool _dragging = false;

  int get _seq => widget.sisi['seq'] as int;

  @override
  void dispose() {
    _ketCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _capture() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final baru = await ambilFotoSurvey();
      if (baru == null || !mounted) return;
      setState(() {
        // Foto baru -> keterangan lama tidak relevan lagi.
        _ketCtrl.clear();
        _foto = baru;
        _fromServer = false;
      });
    } catch (e) {
      _snack('Gagal mengambil foto: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _simpan() {
    FocusScope.of(context).unfocus();
    final f = _foto;
    Navigator.of(context).pop<SurveyFoto>((
      // Garis kotak digambar ulang dari foto asli saat Lanjut.
      path: f.source,
      source: f.source,
      ratio: f.ratio,
      box: f.box,
      keterangan: _ketCtrl.text.trim(),
    ));
  }

  void _previewWp(String url) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: BapendaImage(path: url),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Foto pembanding: hanya satu (foto pertama), tampil lebar penuh.
  Widget _buildFotoWp() {
    final url = [
      for (final m in wpFotosOf(widget.sisi))
        if (fotoUrlOf(m) case final u? when u.isNotEmpty) u,
    ].firstOrNull;

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
              Icon(Icons.person_pin_rounded, size: 18, color: _brand),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Foto dari Wajib Pajak',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2933),
                  ),
                ),
              ),
              const StatusChip(
                label: 'Pembanding',
                tone: BapendaStatusTone.info,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (url == null)
            const Text(
              'Wajib pajak belum melampirkan foto.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF7B8794)),
            )
          else
            GestureDetector(
              onTap: () => _previewWp(url),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    BapendaImage(
                      path: url,
                      width: double.infinity,
                      height: 200,
                      cacheWidth: 800,
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.zoom_out_map_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Ketuk untuk memperbesar',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: CustomScrollView(
        physics: _dragging
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        slivers: [
          BapendaSliverHeader(
            compact: true,
            trailing: const ThemeToggleButton(),
            title: 'Tandai Reklame',
            showBackButton: true,
            subtitle: Text(
              'Sisi $_seq',
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SurveyHeaderCard(sisi: widget.sisi),
                  const SizedBox(height: 14),
                  _buildFotoWp(),
                  const SizedBox(height: 20),
                  const Text(
                    'Foto Survey Petugas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2933),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildEditor(_foto),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: Button(
            label: 'Simpan',
            icon: Icons.check_rounded,
            onPressed: _busy ? null : _simpan,
          ),
        ),
      ),
    );
  }

  Widget _buildEditor(SurveyFoto f) {
    final maxH = MediaQuery.sizeOf(context).height * 0.55;

    return Column(
      children: [
        if (_fromServer) ...[
          const Align(
            alignment: Alignment.centerLeft,
            child: StatusChip(
              label: 'Foto dari server',
              tone: BapendaStatusTone.info,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: AspectRatio(
              aspectRatio: f.ratio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MarkerBox(
                      key: ValueKey(f.source), // reset kotak kalau ganti foto
                      initialRect: f.box,
                      onInteracting: (v) => setState(() => _dragging = v),
                      onChanged: (r) {
                        _foto = (
                          path: f.path,
                          source: f.source,
                          ratio: f.ratio,
                          box: r,
                          keterangan: f.keterangan,
                        );
                      },
                      // Editor selalu menampilkan foto ASLI (tanpa garis).
                      child: BapendaImage(path: f.source),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.open_with_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Geser sudut kotak untuk menandai reklame',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Keterangan foto: di luar area gambar supaya mengetik tidak
        // dianggap menggeser kotak.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: BapendaTextField(
            label: 'Keterangan Foto (Opsional)',
            hint: 'Contoh: tampak depan dari sisi jalan',
            controller: _ketCtrl,
            maxLines: 2,
            maxLength: 200,
          ),
        ),
        const SizedBox(height: 12),

        Button(
          label: 'Ambil Ulang',
          icon: Icons.photo_camera_outlined,
          variant: BapendaButtonVariant.outlined,
          height: 44,
          isLoading: _busy,
          onPressed: _capture,
        ),
      ],
    );
  }
}
