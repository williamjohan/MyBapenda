// lib/presentation/features/survey_baru/screens/survey_foto_page.dart
import 'dart:async';
import 'dart:io';
import 'package:bapendacore/presentation/features/survey_baru/screens/survey_sisi_review_page.dart';
import 'package:bapendacore/presentation/features/survey_baru/widgets/survey_header_card.dart';
import 'package:bapendacore/presentation/shared/utils/marker_stamp_util.dart';
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:bapendacore/presentation/shared/widgets/form_fields.dart';
import 'package:bapendacore/presentation/shared/widgets/marker_box.dart';
import 'package:bapendacore/presentation/shared/widgets/status_chip.dart';
import 'package:bapendacore/presentation/shared/widgets/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/widgets/bapenda_image.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';

typedef SurveyFoto = ({
  /// Foto final (sudah ada garis kotak). Dipakai review & upload.
  String path,

  /// Foto asli tanpa garis. Dipakai editor supaya garis tidak dobel.
  String source,
  double ratio,
  Rect box,

  /// Keterangan foto yang diisi petugas.
  String keterangan,
});

typedef SurveyData = Map<String, dynamic>;
typedef SurveyResult = ({SurveyFoto foto, SurveyData data});

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

String? fotoUrlOf(Map<String, dynamic> m) =>
    (m['url'] ?? m['fotoUrl'] ?? m['path'])?.toString();

class SurveyFotoPage extends StatefulWidget {
  final Map<String, dynamic> sisi;
  final SurveyResult? initialResult;

  const SurveyFotoPage({super.key, required this.sisi, this.initialResult});

  @override
  State<SurveyFotoPage> createState() => _SurveyFotoPageState();
}

class _SurveyFotoPageState extends State<SurveyFotoPage> {
  static const _brand = Color(0xFFB8680F);
  static const _defaultBox = Rect.fromLTWH(0.28, 0.2, 0.44, 0.4);

  final _picker = ImagePicker();
  late final TextEditingController _ketCtrl = TextEditingController(
    text: widget.initialResult?.foto.keterangan ?? '',
  );
  late SurveyFoto? _foto = widget.initialResult?.foto;
  late SurveyData? _data = widget.initialResult?.data;

  // true kalau belum ada foto lokal tapi API punya foto -> perlu di-load
  late bool _loadingRemote =
      _foto == null && apiFotosOf(widget.sisi).isNotEmpty;
  bool _fromServer = false;
  bool _busy = false; // ambil foto
  bool _saving = false; // menggambar garis kotak
  bool _dragging = false;

  // File garis kotak yang dibuat halaman ini (dihapus kalau dibuat ulang).
  String? _createdMarked;

  int get _seq => widget.sisi['seq'] as int;

  @override
  void initState() {
    super.initState();
    if (_loadingRemote) _loadRemote(apiFotosOf(widget.sisi).first);
  }

  @override
  void dispose() {
    _ketCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

  Future<void> _deleteCreated() async {
    final p = _createdMarked;
    _createdMarked = null;
    if (p == null) return;
    try {
      final f = File(p);
      if (await f.exists()) await f.delete();
    } catch (_) {
      // Gagal bersih-bersih tidak boleh mengganggu alur survey.
    }
  }

  /// Hitung rasio foto dari URL supaya kotak (0..1) pas.
  Future<double> _remoteRatio(String url) {
    final c = Completer<double>();
    final stream = NetworkImage(url).resolve(const ImageConfiguration());
    late final ImageStreamListener l;
    l = ImageStreamListener(
      (info, _) {
        if (!c.isCompleted) {
          c.complete(info.image.width / info.image.height);
        }
        stream.removeListener(l);
      },
      onError: (e, _) {
        if (!c.isCompleted) c.completeError(e);
        stream.removeListener(l);
      },
    );
    stream.addListener(l);
    return c.future.timeout(const Duration(seconds: 20));
  }

  Future<void> _loadRemote(Map<String, dynamic> m) async {
    final url = (m['url'] ?? m['fotoUrl'] ?? m['path'])?.toString();
    try {
      if (url == null || url.isEmpty) throw Exception('URL foto kosong');
      final ratio = await _remoteRatio(url);

      final b = m['box'];
      final hasBox =
          b is Map &&
          _d(b['right']) > _d(b['left']) &&
          _d(b['bottom']) > _d(b['top']);
      final box = hasBox
          ? Rect.fromLTRB(
              _d(b['left']),
              _d(b['top']),
              _d(b['right']),
              _d(b['bottom']),
            )
          : _defaultBox;

      final ket = (m['keterangan'] ?? '').toString();

      if (!mounted) return;
      setState(() {
        _foto = (
          path: url,
          source: url,
          ratio: ratio,
          box: box,
          keterangan: ket,
        );
        _ketCtrl.text = ket;
        _fromServer = true;
      });
    } catch (_) {
      _snack('Gagal memuat foto dari server. Kamu bisa ambil foto baru.');
    } finally {
      if (mounted) setState(() => _loadingRemote = false);
    }
  }

  /// Hanya ambil gambar dari kamera. Tidak ada lokasi / proses lain.
  Future<void> _capture() async {
    if (_busy || _saving) return;
    setState(() => _busy = true);
    try {
      final shot = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (shot == null) return;

      final img = await decodeImageFromList(await shot.readAsBytes());
      final ratio = img.width / img.height;
      img.dispose();

      await _deleteCreated(); // garis kotak foto lama sudah tidak dipakai

      if (!mounted) return;
      setState(() {
        // Foto baru -> keterangan lama tidak relevan lagi.
        _ketCtrl.clear();
        _foto = (
          path: shot.path,
          source: shot.path,
          ratio: ratio,
          box: _defaultBox,
          keterangan: '',
        );
        _fromServer = false;
      });
    } catch (e) {
      _snack('Gagal mengambil foto: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Gambar garis kotak ke foto asli. Return null kalau gagal.
  Future<SurveyFoto?> _mark(SurveyFoto f) async {
    setState(() => _saving = true);
    try {
      final out = await MarkerStampUtil.drawBox(source: f.source, box: f.box);
      await _deleteCreated();
      _createdMarked = out;
      return (
        path: out,
        source: f.source,
        ratio: f.ratio,
        box: f.box,
        // Keterangan selalu diambil dari field saat ini.
        keterangan: _ketCtrl.text.trim(),
      );
    } catch (e) {
      _snack('Gagal menyimpan garis kotak pada foto: $e');
      return null;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _next() async {
    final current = _foto;
    if (current == null || _saving) return;
    FocusScope.of(context).unfocus();

    // Garis kotak digambar ke foto sekali di sini, sebelum ke halaman Data.
    final marked = await _mark(current);
    if (marked == null || !mounted) return;
    _foto = marked;

    while (true) {
      // 1) Data
      final saved = await context.pushNamed<SurveyData>(
        AppRoutes.surveyData,
        extra: (sisi: widget.sisi, initial: _data),
      );
      if (saved == null || !mounted) return;
      _data = saved;

      // 2) Review sisi ini
      final ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => SurveySisiReviewPage(
            sisi: widget.sisi,
            result: (foto: marked, data: saved),
          ),
        ),
      );
      if (!mounted) return;

      if (ok == true) {
        // 3) Simpan -> balik ke daftar sisi
        context.pop<SurveyResult>((foto: marked, data: saved));
        return;
      }
      if (ok == null) return; // back dari review -> tetap di halaman Foto
      // ok == false -> loop lagi, buka halaman Data dengan isi sebelumnya
    }
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
              const Icon(Icons.person_pin_rounded, size: 18, color: _brand),
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
    final foto = _foto;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: CustomScrollView(
        physics: _dragging
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        slivers: [
          BapendaSliverHeader(
            title: 'Survey Permohonan Baru',
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
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: const StepIndicator(
                labels: ['Foto', 'Data', 'Review'],
                currentIndex: 0,
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
                  if (_loadingRemote)
                    _buildLoading()
                  else if (foto == null)
                    _buildEmpty()
                  else
                    _buildEditor(foto),
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
            label: 'Lanjutkan',
            icon: Icons.arrow_forward_rounded,
            iconAtEnd: true,
            isLoading: _saving,
            onPressed: foto != null && !_busy && !_saving && !_loadingRemote
                ? _next
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(height: 14),
          Text(
            'Memuat foto dari server...',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF7B8794)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3DC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.photo_camera_rounded,
              size: 30,
              color: _brand,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada foto survey Sisi $_seq',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2933),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ambil foto langsung di lokasi. Foto wajib pajak di atas hanya sebagai pembanding dan tidak akan tertimpa.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: Color(0xFF7B8794),
            ),
          ),
          const SizedBox(height: 22),
          Button(
            label: 'Ambil Foto',
            icon: Icons.photo_camera_rounded,
            isLoading: _busy,
            onPressed: _capture,
          ),
        ],
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
          onPressed: _saving ? null : _capture,
        ),
      ],
    );
  }
}
