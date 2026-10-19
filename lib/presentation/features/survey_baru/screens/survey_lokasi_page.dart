import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/services/geo_location_service.dart';
import '../../../../core/theme/theme_kit.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/utils/marker_stamp_util.dart';
import '../../../shared/widgets/bapenda_image.dart';
import '../../../shared/widgets/button.dart';
import '../cubit/survey_lokasi/survey_lokasi_cubit.dart';
import '../cubit/survey_lokasi/survey_lokasi_state.dart';
import '../utils/survey_lokasi_ui_helper.dart';
import '../widgets/peta_lokasi_reklame.dart';
import 'survey_foto_page.dart';
import 'survey_sisi_review_page.dart';

/// Langkah pertama survey satu sisi: pinpoint lokasi reklame + foto.
///
/// Urutan bebas: petugas boleh foto dulu atau geser pin dulu. Pin awal =
/// posisi HP; geser peta sampai pin tepat di reklame. Garis putus-putus
/// ("penggaris") menunjukkan jarak dari posisi petugas ke pin; pin di luar
/// radius [SurveyLokasiState.jarakMaksMeter] diberi warna merah dan Lanjut
/// dinonaktifkan. Kotak penanda & keterangan diatur di [SurveyFotoPage].
/// Lanjut → Data → Review, lalu `pop` [SurveyResult] ke daftar sisi.
class SurveyLokasiPage extends StatefulWidget {
  final Map<String, dynamic> sisi;
  final SurveyResult? initialResult;

  const SurveyLokasiPage({super.key, required this.sisi, this.initialResult});

  @override
  State<SurveyLokasiPage> createState() => _SurveyLokasiPageState();
}

class _SurveyLokasiPageState extends State<SurveyLokasiPage> {
  GoogleMapController? _peta;
  AppPalette? _paletteIkon;
  BitmapDescriptor? _ikonPin;
  BitmapDescriptor? _ikonPinJauh;
  bool _ambilFoto = false;
  bool _menyimpan = false; // menggambar garis kotak

  late SurveyFoto? _foto = widget.initialResult?.foto;
  late SurveyData? _data = widget.initialResult?.data;

  // true kalau belum ada foto lokal tapi API punya foto -> perlu di-load
  late bool _memuatFotoServer =
      _foto == null && apiFotosOf(widget.sisi).isNotEmpty;
  bool _fotoServer = false;

  // File garis kotak yang dibuat halaman ini (dihapus kalau dibuat ulang).
  String? _fileKotak;

  int get _seq => widget.sisi['seq'] as int;

  @override
  void initState() {
    super.initState();
    if (_memuatFotoServer) _muatFotoServer(apiFotosOf(widget.sisi).first);
  }

  @override
  void dispose() {
    _peta?.dispose();
    super.dispose();
  }

  void _snack(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

  Future<void> _hapusFileKotak() async {
    final p = _fileKotak;
    _fileKotak = null;
    if (p == null) return;
    try {
      final f = File(p);
      if (await f.exists()) await f.delete();
    } catch (_) {
      // Gagal bersih-bersih tidak boleh mengganggu alur survey.
    }
  }

  /// Hitung rasio foto dari URL supaya kotak (0..1) pas.
  Future<double> _rasioServer(String url) {
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

  Future<void> _muatFotoServer(Map<String, dynamic> m) async {
    final url = fotoUrlOf(m);
    try {
      if (url == null || url.isEmpty) throw Exception('URL foto kosong');
      final ratio = await _rasioServer(url);

      final b = m['box'];
      final adaKotak =
          b is Map &&
          _d(b['right']) > _d(b['left']) &&
          _d(b['bottom']) > _d(b['top']);
      final box = adaKotak
          ? Rect.fromLTRB(
              _d(b['left']),
              _d(b['top']),
              _d(b['right']),
              _d(b['bottom']),
            )
          : kotakAwalFoto;

      if (!mounted) return;
      setState(() {
        _foto = (
          path: url,
          source: url,
          ratio: ratio,
          box: box,
          keterangan: (m['keterangan'] ?? '').toString(),
        );
        _fotoServer = true;
      });
    } catch (_) {
      _snack('Gagal memuat foto dari server. Kamu bisa ambil foto baru.');
    } finally {
      if (mounted) setState(() => _memuatFotoServer = false);
    }
  }

  /// Foto baru dari kamera, langsung dibuka di editor kotak penanda.
  Future<void> _ambil() async {
    if (_ambilFoto) return;
    setState(() => _ambilFoto = true);
    try {
      final baru = await ambilFotoSurvey();
      if (baru == null || !mounted) return;
      setState(() {
        _foto = baru;
        _fotoServer = false;
      });
      await _tandai();
    } catch (e) {
      _snack('Gagal mengambil foto: $e');
    } finally {
      if (mounted) setState(() => _ambilFoto = false);
    }
  }

  /// Buka editor kotak penanda & keterangan untuk foto saat ini.
  Future<void> _tandai() async {
    final foto = _foto;
    if (foto == null) return;
    final hasil = await Navigator.of(context).push<SurveyFoto>(
      MaterialPageRoute(
        builder: (_) => AdaptiveThemeScope(
          child: SurveyFotoPage(
            sisi: widget.sisi,
            foto: foto,
            dariServer: _fotoServer,
          ),
        ),
      ),
    );
    if (hasil == null || !mounted) return;
    setState(() {
      if (hasil.source != foto.source) _fotoServer = false;
      _foto = hasil;
    });
  }

  /// Gambar garis kotak ke foto asli. Return null kalau gagal.
  Future<SurveyFoto?> _gambarKotak(SurveyFoto f) async {
    setState(() => _menyimpan = true);
    try {
      final out = await MarkerStampUtil.drawBox(source: f.source, box: f.box);
      await _hapusFileKotak();
      _fileKotak = out;
      return (
        path: out,
        source: f.source,
        ratio: f.ratio,
        box: f.box,
        keterangan: f.keterangan,
      );
    } catch (e) {
      _snack('Gagal menyimpan garis kotak pada foto: $e');
      return null;
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  Future<void> _lanjut() async {
    final foto = _foto;
    final lokasi = context.read<SurveyLokasiCubit>().state.hasil;
    if (foto == null || lokasi == null || _menyimpan) return;

    // Garis kotak digambar ke foto sekali di sini, sebelum ke halaman Data.
    final ditandai = await _gambarKotak(foto);
    if (ditandai == null || !mounted) return;

    while (true) {
      // 1) Data
      final saved = await context.pushNamed<SurveyData>(
        AppRoutes.surveyData,
        extra: (sisi: widget.sisi, initial: _data),
      );
      if (saved == null || !mounted) return;
      _data = saved;

      final result = (foto: ditandai, data: saved, lokasi: lokasi);

      // 2) Review sisi ini
      final ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => AdaptiveThemeScope(
            child: SurveySisiReviewPage(sisi: widget.sisi, result: result),
          ),
        ),
      );
      if (!mounted) return;

      if (ok == true) {
        // 3) Simpan -> balik ke daftar sisi
        context.pop<SurveyResult>(result);
        return;
      }
      if (ok == null) return; // back dari review -> tetap di halaman ini
      // ok == false -> loop lagi, buka halaman Data dengan isi sebelumnya
    }
  }

  /// Ambil ulang GPS lalu pusatkan peta ke posisi petugas (pin tetap).
  Future<void> _kePosisiSaya() async {
    final cubit = context.read<SurveyLokasiCubit>();
    await cubit.perbaruiPosisiPetugas();
    final p = cubit.state.petugas;
    if (p == null || !mounted) return;
    await _peta?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(p.latitude, p.longitude),
        zoomPetaReklame,
      ),
    );
  }

  /// Pin dipindah ke posisi petugas (pin "hilang" di luar layar / reset).
  Future<void> _pinKePosisiSaya() async {
    final cubit = context.read<SurveyLokasiCubit>();
    final p = cubit.state.petugas;
    if (p == null) return;
    cubit.geserPin(p.latitude, p.longitude);
    await cubit.pinBerhenti();
    await _peta?.animateCamera(
      CameraUpdate.newLatLng(LatLng(p.latitude, p.longitude)),
    );
  }

  /// Ikon pin dibuat sekali per warna (normal / terlalu jauh).
  Future<void> _siapkanIkon() async {
    final palette = context.palette;
    if (identical(palette, _paletteIkon)) return;
    _paletteIkon = palette;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final normal = await ikonPinReklame(palette.accent, dpr);
    final jauh = await ikonPinReklame(palette.statusGagal, dpr);
    if (!mounted) return;
    setState(() {
      _ikonPin = normal;
      _ikonPinJauh = jauh;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _siapkanIkon();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: BlocConsumer<SurveyLokasiCubit, SurveyLokasiState>(
        listenWhen: (a, b) =>
            b.pesanError != null &&
            a.pesanError != b.pesanError &&
            b.petugas != null,
        // Peta sudah tampil: error GPS berikutnya cukup snackbar.
        listener: (context, s) => _snack(s.pesanError!),
        builder: (context, s) {
          final pin = s.pin;
          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    if (pin == null)
                      _StatusAwal(state: s)
                    else
                      _buildPeta(s, pin),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TombolBulat(
                              icon: Icons.arrow_back_rounded,
                              tooltip: 'Kembali',
                              onTap: () => context.pop(),
                            ),
                            const SizedBox(width: 10),
                            if (pin != null)
                              Expanded(child: _PetunjukPeta(state: s)),
                          ],
                        ),
                      ),
                    ),
                    if (pin != null)
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Column(
                          children: [
                            _TombolBulat(
                              icon: Icons.push_pin_outlined,
                              tooltip: 'Pindahkan pin ke posisi saya',
                              onTap: _pinKePosisiSaya,
                            ),
                            const SizedBox(height: 10),
                            _TombolBulat(
                              icon: Icons.my_location_rounded,
                              tooltip: 'Ke posisi saya',
                              memuat: s.status == SurveyLokasiStatus.memuat,
                              onTap: _kePosisiSaya,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              _PanelBawah(
                state: s,
                seq: _seq,
                foto: _foto,
                memuatFoto: _memuatFotoServer,
                ambilFoto: _ambilFoto,
                menyimpan: _menyimpan,
                onAmbil: _ambil,
                onTandai: _tandai,
                onLanjut:
                    s.lokasiSiap &&
                        _foto != null &&
                        !_memuatFotoServer &&
                        !_ambilFoto
                    ? _lanjut
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeta(SurveyLokasiState s, TitikPeta pin) {
    final palette = context.palette;
    final petugas = s.petugas;
    final warna = s.terlaluJauh ? palette.statusGagal : palette.accent;
    final cubit = context.read<SurveyLokasiCubit>();
    final ikon = s.terlaluJauh ? _ikonPinJauh : _ikonPin;

    return GoogleMap(
      // Kamera awal di posisi petugas (atau pin hasil sebelumnya); peta
      // tidak menggeser pin, pin yang digeser.
      initialCameraPosition: CameraPosition(
        target: petugas != null
            ? LatLng(petugas.latitude, petugas.longitude)
            : LatLng(pin.lat, pin.lng),
        zoom: zoomPetaReklame,
      ),
      onMapCreated: (c) => _peta = c,
      // Ketuk peta = pindahkan pin ke titik itu.
      onTap: (p) {
        cubit.geserPin(p.latitude, p.longitude);
        cubit.pinBerhenti();
      },
      markers: {
        if (ikon != null)
          Marker(
            markerId: const MarkerId('reklame'),
            position: LatLng(pin.lat, pin.lng),
            icon: ikon,
            anchor: const Offset(0.5, 1),
            draggable: true,
            zIndexInt: 2,
            onDrag: (p) => cubit.geserPin(p.latitude, p.longitude),
            onDragEnd: (p) {
              cubit.geserPin(p.latitude, p.longitude);
              cubit.pinBerhenti();
            },
          ),
      },
      // Titik biru bawaan Google = posisi HP petugas.
      myLocationEnabled: petugas != null,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      minMaxZoomPreference: const MinMaxZoomPreference(16, 21),
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
      },
      // Radius maksimal pin dari posisi petugas.
      circles: {
        if (petugas != null)
          Circle(
            circleId: const CircleId('radius-maks'),
            center: LatLng(petugas.latitude, petugas.longitude),
            radius: SurveyLokasiState.jarakMaksMeter,
            fillColor: warna.withValues(alpha: 0.08),
            strokeColor: warna.withValues(alpha: 0.7),
            strokeWidth: 2,
          ),
      },
      // "Penggaris" posisi petugas -> pin.
      polylines: {
        if (petugas != null)
          Polyline(
            polylineId: const PolylineId('penggaris'),
            points: [
              LatLng(petugas.latitude, petugas.longitude),
              LatLng(pin.lat, pin.lng),
            ],
            color: warna,
            width: 3,
            patterns: [PatternItem.dash(12), PatternItem.gap(6)],
          ),
      },
    );
  }
}

/// Kartu petunjuk + jarak di atas peta.
class _PetunjukPeta extends StatelessWidget {
  final SurveyLokasiState state;
  const _PetunjukPeta({required this.state});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final jarak = state.jarakMeter;
    final jauh = state.terlaluJauh;
    final maks = SurveyLokasiState.jarakMaksMeter.round();

    return Material(
      color: jauh ? palette.statusGagal : palette.surface,
      elevation: 3,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            Icon(
              jauh ? Icons.warning_amber_rounded : Icons.touch_app_rounded,
              size: 18,
              color: jauh ? Colors.white : palette.accent,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    jauh
                        ? 'Pin di luar radius $maks m'
                        : 'Ketuk peta atau tahan & geser pin',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: jauh ? Colors.white : palette.textPrimary,
                    ),
                  ),
                  if (jarak != null)
                    Text(
                      '${SurveyLokasiUiHelper.jarak(jarak)} dari Anda · '
                      'maks $maks m',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: jauh
                            ? Colors.white.withValues(alpha: 0.9)
                            : palette.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sebelum ada pin: memuat GPS, atau gagal (izin/GPS mati) + tombol aksi.
class _StatusAwal extends StatelessWidget {
  final SurveyLokasiState state;
  const _StatusAwal({required this.state});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<SurveyLokasiCubit>();
    final gagal = state.status == SurveyLokasiStatus.gagal;
    final bisaPengaturan =
        state.kodeError == GeoLocationError.serviceDisabled ||
        state.kodeError == GeoLocationError.permissionDeniedForever;

    return ColoredBox(
      color: palette.surfaceMuted,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (gagal)
                Icon(
                  Icons.location_off_rounded,
                  size: 44,
                  color: palette.statusGagal,
                )
              else
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              const SizedBox(height: 14),
              Text(
                gagal
                    ? state.pesanError ?? 'Gagal mengambil lokasi.'
                    : 'Mencari posisi Anda...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: palette.textSecondary),
              ),
              if (gagal) ...[
                const SizedBox(height: 18),
                Button(
                  label: 'Coba Lagi',
                  icon: Icons.refresh_rounded,
                  expanded: false,
                  height: 44,
                  onPressed: cubit.perbaruiPosisiPetugas,
                ),
                if (bisaPengaturan) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: cubit.bukaPengaturanLokasi,
                    child: const Text('Buka Pengaturan'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TombolBulat extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool memuat;

  const _TombolBulat({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.memuat = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: palette.surface,
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: memuat ? null : onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Center(
              child: memuat
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon, size: 22, color: palette.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

/// Satu langkah di panel bawah: nomor (centang bila selesai) + isi.
class _Langkah extends StatelessWidget {
  final int nomor;
  final String judul;
  final bool selesai;
  final bool error;
  final Widget child;

  const _Langkah({
    required this.nomor,
    required this.judul,
    required this.selesai,
    required this.child,
    this.error = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final warna = error
        ? palette.statusGagal
        : selesai
        ? palette.statusSukses
        : palette.accent;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
          child: selesai && !error
              ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
              : Text(
                  '$nomor',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3, bottom: 6),
                child: Text(
                  judul,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ],
    );
  }
}

class _PanelBawah extends StatelessWidget {
  final SurveyLokasiState state;
  final int seq;
  final SurveyFoto? foto;
  final bool memuatFoto;
  final bool ambilFoto;
  final bool menyimpan;
  final VoidCallback onAmbil;
  final VoidCallback onTandai;

  /// null = belum bisa lanjut (tombol nonaktif).
  final VoidCallback? onLanjut;

  const _PanelBawah({
    required this.state,
    required this.seq,
    required this.foto,
    required this.memuatFoto,
    required this.ambilFoto,
    required this.menyimpan,
    required this.onAmbil,
    required this.onTandai,
    required this.onLanjut,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = state;
    final alamat = SurveyLokasiUiHelper.alamat(s.alamat);
    final jarak = s.jarakMeter;
    final foto = this.foto;
    final maks = SurveyLokasiState.jarakMaksMeter.round();

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: palette.shadow, blurRadius: 12)],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Survey Sisi $seq',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              // 1. Titik reklame
              _Langkah(
                nomor: 1,
                judul: 'Titik reklame',
                selesai: s.lokasiSiap,
                error: s.terlaluJauh,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: s.terlaluJauh
                        ? palette.statusGagalSoft
                        : palette.accentSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: s.pin == null || s.memuatAlamat
                      ? Text(
                          'Mencari alamat...',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: palette.textSecondary,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alamat.judul,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: palette.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              alamat.detail,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                height: 1.4,
                                color: palette.textSecondary,
                              ),
                            ),
                            if (jarak != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                s.terlaluJauh
                                    ? '${SurveyLokasiUiHelper.jarak(jarak)} '
                                          'dari Anda, maksimal $maks m. Dekati '
                                          'reklame atau geser pin.'
                                    : '${SurveyLokasiUiHelper.jarak(jarak)} '
                                          'dari Anda · akurasi GPS '
                                          '±${s.petugas!.akurasiMeter.round()} m',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: s.terlaluJauh
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: s.terlaluJauh
                                      ? palette.statusGagal
                                      : palette.textTertiary,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 14),

              // 2. Foto reklame
              _Langkah(
                nomor: 2,
                judul: 'Foto reklame',
                selesai: foto != null,
                child: memuatFoto
                    ? Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Memuat foto dari server...',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: palette.textSecondary,
                            ),
                          ),
                        ],
                      )
                    : foto == null
                    ? Button(
                        label: 'Ambil Foto Reklame',
                        icon: Icons.photo_camera_rounded,
                        variant: BapendaButtonVariant.outlined,
                        height: 44,
                        isLoading: ambilFoto,
                        onPressed: onAmbil,
                      )
                    : Row(
                        children: [
                          GestureDetector(
                            onTap: ambilFoto || menyimpan ? null : onTandai,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: BapendaImage(
                                path: foto.source,
                                width: 60,
                                height: 60,
                                cacheWidth: 200,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton.icon(
                                  onPressed: ambilFoto || menyimpan
                                      ? null
                                      : onTandai,
                                  icon: const Icon(
                                    Icons.crop_free_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Tandai reklame'),
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: ambilFoto || menyimpan
                                      ? null
                                      : onAmbil,
                                  icon: const Icon(
                                    Icons.photo_camera_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Ambil ulang'),
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              Button(
                label: 'Lanjutkan',
                icon: Icons.arrow_forward_rounded,
                iconAtEnd: true,
                isLoading: menyimpan,
                onPressed: onLanjut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
