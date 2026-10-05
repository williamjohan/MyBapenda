// lib/presentation/features/reklame/pages/survey_foto_page.dart
import 'dart:async';
import 'package:bapendacore/presentation/features/survey_baru/screens/survey_sisi_review_page.dart';
import 'package:bapendacore/presentation/shared/utils/location_util.dart';
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:bapendacore/presentation/shared/widgets/marker_box.dart';
import 'package:bapendacore/presentation/shared/widgets/status_chip.dart';
import 'package:bapendacore/presentation/shared/widgets/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/widgets/bapenda_image.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';

/// Draft foto (sementara, belum model). box = 0..1 relatif ke gambar.
/// path bisa path lokal ATAU URL (foto dari server).
typedef SurveyFoto = ({
  String path,
  double ratio, // width / height
  Rect box,
  double lat, // 0 = tidak diketahui
  double lng,
});

/// Bentuknya sama dengan objek `survey` di API.
typedef SurveyData = Map<String, dynamic>;

/// Hasil lengkap satu sisi: foto + kotak + data form.
typedef SurveyResult = ({SurveyFoto foto, SurveyData data});

/// Foto yang sudah ada di server untuk sisi ini (`sisi.survey.fotos`).
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
  late SurveyFoto? _foto = widget.initialResult?.foto;
  late SurveyData? _data = widget.initialResult?.data;

  // true kalau belum ada foto lokal tapi API punya foto -> perlu di-load
  late bool _loadingRemote =
      _foto == null && apiFotosOf(widget.sisi).isNotEmpty;
  bool _fromServer = false;
  bool _busy = false;
  bool _dragging = false;

  int get _seq => widget.sisi['seq'] as int;

  @override
  void initState() {
    super.initState();
    if (_loadingRemote) _loadRemote(apiFotosOf(widget.sisi).first);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

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

      if (!mounted) return;
      setState(() {
        _foto = (
          path: url,
          ratio: ratio,
          box: box,
          lat: _d(m['latitude'] ?? m['lat']),
          lng: _d(m['longitude'] ?? m['lng']),
        );
        _fromServer = true;
      });
    } catch (_) {
      _snack('Gagal memuat foto dari server. Kamu bisa ambil foto baru.');
    } finally {
      if (mounted) setState(() => _loadingRemote = false);
    }
  }

  Future<void> _capture() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final loc = await LocationUtil.current();

      final shot = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (shot == null) return;

      final img = await decodeImageFromList(await shot.readAsBytes());
      final ratio = img.width / img.height;
      img.dispose();

      if (!mounted) return;
      setState(() {
        _foto = (
          path: shot.path,
          ratio: ratio,
          box: _defaultBox,
          lat: loc.lat,
          lng: loc.lng,
        );
        _fromServer = false;
      });
    } on LocationException catch (e) {
      _snack(e.message);
    } on TimeoutException {
      _snack('Sinyal GPS lemah, coba lagi di area yang lebih terbuka.');
    } catch (e) {
      _snack('Gagal mengambil foto: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _next() async {
    if (_foto == null) return;

    while (true) {
      // 1) Data
      final saved = await context.pushNamed<SurveyData>(
        AppRoutes.surveyData,
        extra: (sisi: widget.sisi, initial: _data),
      );
      if (saved == null || !mounted) return;
      _data = saved;

      // 2) Review sisi ini
      final foto = _foto!; // pakai posisi kotak terbaru
      final ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => SurveySisiReviewPage(
            sisi: widget.sisi,
            result: (foto: foto, data: saved),
          ),
        ),
      );
      if (!mounted) return;

      if (ok == true) {
        // 3) Simpan -> balik ke daftar sisi
        context.pop<SurveyResult>((foto: foto, data: saved));
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

  Widget _buildFotoWp() {
    final urls = [
      for (final m in wpFotosOf(widget.sisi))
        if (fotoUrlOf(m) case final u? when u.isNotEmpty) u,
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
          Row(
            children: [
              const Icon(Icons.person_pin_rounded, size: 18, color: _brand),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Foto dari Wajib Pajak',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2933),
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
          if (urls.isEmpty)
            Text(
              'Wajib pajak belum melampirkan foto.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF7B8794),
              ),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: urls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _previewWp(urls[i]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BapendaImage(
                      path: urls[i],
                      width: 160,
                      height: 120,
                      cacheWidth: 400,
                    ),
                  ),
                ),
              ),
            ),
          if (urls.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Ketuk foto untuk memperbesar',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: const Color(0xFF9AA5B1),
              ),
            ),
          ],
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
                  _buildFotoWp(),
                  const SizedBox(height: 20),
                  Text(
                    'Foto Survey Petugas',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2933),
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
            onPressed: foto != null && !_busy && !_loadingRemote ? _next : null,
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
      child: Column(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(height: 14),
          Text(
            'Memuat foto dari server...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: const Color(0xFF7B8794),
            ),
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
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2933),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ambil foto langsung di lokasi. Foto wajib pajak di atas hanya sebagai pembanding dan tidak akan tertimpa. Lokasi GPS tercatat otomatis.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              height: 1.5,
              color: const Color(0xFF7B8794),
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
    final hasLoc = f.lat != 0 || f.lng != 0;

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
                      key: ValueKey(f.path), // reset kotak kalau ganti foto
                      initialRect: f.box,
                      onInteracting: (v) => setState(() => _dragging = v),
                      onChanged: (r) {
                        _foto = (
                          path: f.path,
                          ratio: f.ratio,
                          box: r,
                          lat: f.lat,
                          lng: f.lng,
                        );
                      },
                      child: BapendaImage(path: f.path),
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.open_with_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Geser sudut kotak untuk menandai reklame',
                                  style: GoogleFonts.plusJakartaSans(
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
        if (hasLoc) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 18, color: _brand),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lokasi foto · ${f.lat.toStringAsFixed(6)}, ${f.lng.toStringAsFixed(6)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF52606D),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
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
