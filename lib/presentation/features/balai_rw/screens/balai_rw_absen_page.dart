// lib/presentation/features/balai_rw/pages/balai_rw_absen_page.dart
import 'dart:async';
import 'package:bapendacore/presentation/shared/utils/date_util.dart';
import 'package:bapendacore/presentation/shared/utils/foto_stamp_util.dart';
import 'package:bapendacore/presentation/shared/utils/location_util.dart';
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:bapendacore/presentation/shared/widgets/form_fields.dart';
import 'package:bapendacore/presentation/shared/widgets/info_row.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/widgets/bapenda_image.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';

enum BalaiRwAbsenType { checkIn, checkOut }

class BalaiRwAbsenPage extends StatefulWidget {
  final BalaiRwAbsenType type;
  final Map<String, dynamic> penugasan;
  final Map<String, dynamic>? initial; // data lama (mode ubah / lihat)
  final bool readOnly;

  const BalaiRwAbsenPage({
    super.key,
    required this.type,
    required this.penugasan,
    this.initial,
    this.readOnly = false,
  });

  @override
  State<BalaiRwAbsenPage> createState() => _BalaiRwAbsenPageState();
}

class _BalaiRwAbsenPageState extends State<BalaiRwAbsenPage> {
  static const _brand = Color(0xFFB8680F);

  final _picker = ImagePicker();

  String? _rawPath; // foto asli (tanpa stempel)
  String? _stampedPath; // foto yang sudah distempel
  TimeOfDay? _time;
  ({double lat, double lng})? _loc;
  String? _address;
  bool _busy = false;
  bool _stamping = false;
  double? _acc;
  DateTime? _gpsTime;

  bool get _isIn => widget.type == BalaiRwAbsenType.checkIn;
  String get _label => _isIn ? 'Check-in' : 'Check-out';

  bool get _useLocation => !_isIn;

  bool get _canSave =>
      _stampedPath != null && _time != null && !_busy && !_stamping;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i == null) return;
    _rawPath = i['rawPath'] as String?;
    _stampedPath = i['path'] as String?;
    _time = DateUtil.parseJam('${i['jam']}');
    _address = i['address'] as String?;

    if (i['lat'] != null && i['lng'] != null) {
      _loc = (
        lat: (i['lat'] as num).toDouble(),
        lng: (i['lng'] as num).toDouble(),
      );
      _acc = (i['accuracy'] as num?)?.toDouble();
      _gpsTime = DateTime.tryParse('${i['gpsTime']}');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<String?> _lookupAddress(double lat, double lng) async {
    try {
      final list = await placemarkFromCoordinates(
        lat,
        lng,
      ).timeout(const Duration(seconds: 5));
      if (list.isEmpty) return null;
      final p = list.first;
      final parts = [
        p.street,
        p.subLocality,
        p.locality,
      ].whereType<String>().where((e) => e.trim().isNotEmpty).toList();
      return parts.isEmpty ? null : parts.join(', ');
    } catch (_) {
      return null; // alamat opsional
    }
  }

  Future<void> _capture() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (_useLocation) await LocationUtil.ensureReady();

      final shot = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (shot == null) return;

      final loc = _useLocation ? await LocationUtil.current() : null;
      final address = loc == null
          ? null
          : await _lookupAddress(loc.lat, loc.lng);

      if (!mounted) return;
      setState(() {
        _rawPath = shot.path;
        _stampedPath = null;
        _loc = loc == null ? null : (lat: loc.lat, lng: loc.lng);
        _acc = loc?.accuracy;
        _gpsTime = loc?.time;
        _address = address;
        _time = _isIn
            ? null
            : TimeOfDay.fromDateTime(loc?.time ?? DateTime.now());
      });

      if (_isIn) {
        await _pickTime();
      } else {
        await _restamp();
      }
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

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
      helpText: 'Jam $_label',
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (t == null || !mounted) return;
    setState(() => _time = t);
    await _restamp();
  }

  /// Bakar stempel ke foto asli. Dipanggil ulang tiap jam diubah.
  Future<void> _restamp() async {
    final raw = _rawPath;
    final t = _time;
    if (raw == null || t == null) return;

    setState(() => _stamping = true);
    try {
      final now = _gpsTime ?? DateTime.now();
      final p = widget.penugasan;
      final loc = _loc;
      final addr = _address;

      final stamped = await FotoStampUtil.stamp(
        sourcePath: raw,
        title: '$_label ${p['balaiRw']}'.toUpperCase(),
        lines: [
          'Kel. ${p['kelurahan']}, Kec. ${p['kecamatan']}',
          '${DateUtil.hari(now)}, ${DateUtil.tanggal(now)} · ${DateUtil.jamOf(t)} WIB',
          if (loc != null)
            'Lat ${loc.lat.toStringAsFixed(6)}, Long ${loc.lng.toStringAsFixed(6)}'
                '${_acc == null ? '' : '  (±${_acc!.round()} m)'}',
          if (addr != null) addr,
        ],
      );
      if (!mounted) return;
      setState(() => _stampedPath = stamped);
    } catch (e) {
      _snack('Gagal membuat stempel foto: $e');
    } finally {
      if (mounted) setState(() => _stamping = false);
    }
  }

  void _save() {
    final t = _time;
    final path = _stampedPath;
    if (t == null || path == null) return;
    final loc = _loc;

    context.pop<Map<String, dynamic>>({
      'type': _isIn ? 'in' : 'out',
      'path': path,
      'rawPath': _rawPath,
      'jam': DateUtil.jamOf(t),
      'tanggal': DateUtil.iso(DateTime.now()),
      if (loc != null) ...{
        'lat': loc.lat,
        'lng': loc.lng,
        'address': _address,
        'accuracy': _acc, 
        'gpsTime': _gpsTime?.toIso8601String(), 
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _stampedPath != null || _rawPath != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          BapendaSliverHeader(
            title: _label,
            showBackButton: true,
            subtitle: Text(
              '${widget.penugasan['balaiRw']}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: hasPhoto ? _buildPreview() : _buildEmpty(),
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
                  label: 'Simpan $_label',
                  icon: Icons.check_rounded,
                  onPressed: _canSave ? _save : null,
                ),
              ),
            ),
    );
  }

  Widget _box(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
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
            child: Icon(
              _isIn ? Icons.login_rounded : Icons.logout_rounded,
              size: 30,
              color: _brand,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Foto $_label',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2933),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isIn
                ? 'Ambil foto saat tiba di balai RW. Setelah foto, isi jam kedatangan secara manual.'
                : 'Lokasi, tanggal, dan jam otomatis tercetak di foto. Pastikan GPS aktif.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              height: 1.5,
              color: const Color(0xFF7B8794),
            ),
          ),
          const SizedBox(height: 22),
          Button(
            label: 'Ambil Foto $_label',
            icon: Icons.photo_camera_rounded,
            isLoading: _busy,
            onPressed: _capture,
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final maxH = MediaQuery.sizeOf(context).height * 0.5;
    final t = _time;
    final loc = _loc;
    final addr = _address;
    final manualTime = _isIn && !widget.readOnly;

    return Column(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  BapendaImage(
                    path: _stampedPath ?? _rawPath!,
                    fit: BoxFit.contain,
                    cacheWidth: 1000,
                  ),
                  if (_stamping)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black38,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _box([
          if (manualTime) ...[
            BapendaTimeField(
              label: 'Jam Check-in *',
              valueText: t == null ? null : '${DateUtil.jamOf(t)} WIB',
              onTap: (_busy || _stamping) ? null : _pickTime,
            ),
            const SizedBox(height: 8),
            Text(
              'Jam ini yang tercetak di foto dan dipakai sebagai jam masuk.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: const Color(0xFF7B8794),
              ),
            ),
          ] else ...[
            InfoRow(
              label: 'Jam $_label',
              value: t == null ? '-' : '${DateUtil.jamOf(t)} WIB',
            ),
            if (loc != null)
              InfoRow(
                label: 'Koordinat',
                value:
                    '${loc.lat.toStringAsFixed(6)}, ${loc.lng.toStringAsFixed(6)}',
              ),
            if (addr != null) InfoRow(label: 'Alamat', value: addr),
          ],
        ]),
        if (!widget.readOnly) ...[
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
      ],
    );
  }
}
