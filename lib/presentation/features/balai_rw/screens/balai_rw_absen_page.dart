// lib/presentation/features/balai_rw/pages/balai_rw_absen_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mybapenda/core/constants/app_colors_new.dart';
import 'package:mybapenda/core/di/injection.dart';
import 'package:mybapenda/core/services/geo_location/i_geo_location_service.dart';
import 'package:mybapenda/core/services/permission/i_permission_service.dart';
import 'package:mybapenda/core/enums/app_permission_enum.dart'; 
import 'package:mybapenda/presentation/shared/utils/date_util.dart';
import 'package:mybapenda/presentation/shared/utils/foto_stamp_util.dart';
import 'package:mybapenda/presentation/shared/widgets/button.dart';
import 'package:mybapenda/presentation/shared/widgets/form_fields.dart';
import 'package:mybapenda/presentation/shared/widgets/info_row.dart';
import '../../../shared/widgets/bapenda_image.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';

enum BalaiRwAbsenType { checkIn, checkOut }

class BalaiRwAbsenPage extends StatefulWidget {
  final BalaiRwAbsenType type;
  final Map<String, dynamic> penugasan;
  final Map<String, dynamic>? initial;
  final Future<String?> Function(Map<String, dynamic> data)? onSubmit;
  final bool readOnly;

  const BalaiRwAbsenPage({
    super.key,
    required this.type,
    required this.penugasan,
    this.initial,
    this.onSubmit,
    this.readOnly = false,
  });

  @override
  State<BalaiRwAbsenPage> createState() => _BalaiRwAbsenPageState();
}

class _BalaiRwAbsenPageState extends State<BalaiRwAbsenPage> {
  // static const _brand = AppThemeColors.primary;

  final _picker = ImagePicker();
  
  late final IGeoLocationService _locationService;
  late final IPermissionService _permissionService;

  String? _rawPath;
  String? _stampedPath;
  TimeOfDay? _time;
  ({double lat, double lng})? _loc;
  String? _address;
  bool _busy = false;
  bool _stamping = false;
  double? _acc;
  DateTime? _gpsTime;

  bool get _isIn => widget.type == BalaiRwAbsenType.checkIn;
  String get _label => _isIn ? 'Check-in' : 'Check-out';

  bool get _useLocation => true;

  bool _sending = false;

  bool get _hasNewPhoto =>
      _stampedPath != null && !_stampedPath!.startsWith('http');

  bool get _canSave =>
      _hasNewPhoto &&
      _time != null &&
      (!_useLocation || _loc != null) &&
      !_busy &&
      !_stamping &&
      !_sending;

  @override
  void initState() {
    super.initState();
    // 🚀 REFACTOR: Inisialisasi Service
    _locationService = getIt<IGeoLocationService>();
    _permissionService = getIt<IPermissionService>();

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
      if (_useLocation) {
        // 🚀 REFACTOR: Early permission check (menggantikan LocationUtil.ensureReady)
        final permCamera = await _permissionService.requestPermission(AppPermissionType.camera);
        if (permCamera != AppPermissionStatus.granted) {
          _snack('Izin kamera ditolak. Buka pengaturan aplikasi untuk memberikan izin.');
          return;
        }
        
        final permLocation = await _permissionService.requestPermission(AppPermissionType.location);
        if (permLocation != AppPermissionStatus.granted) {
          _snack('Izin lokasi ditolak. Buka pengaturan aplikasi untuk memberikan izin.');
          return;
        }
      }

      final shot = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (shot == null) return;

      // 🚀 REFACTOR: Ambil lokasi via Service Baru (Gaya Either / Pattern Matching)
      GeoPosition? locResult;
      
      if (_useLocation) {
        final locationEither = await _locationService.getCurrentPosition();
        
        // Cek kegagalan lokasi
        final isFailed = locationEither.fold(
          (failure) {
            _snack(failure.message);
            return true;
          },
          (position) {
            locResult = position;
            return false;
          }
        );
        
        if (isFailed) return; // Hentikan proses jika gagal (Akurasi buruk, timeout, dll)
      }

      final address = locResult == null
          ? null
          : await _lookupAddress(locResult!.latitude, locResult!.longitude);

      if (!mounted) return;
      setState(() {
        _rawPath = shot.path;
        _stampedPath = null;
        _loc = locResult == null ? null : (lat: locResult!.latitude, lng: locResult!.longitude);
        _acc = locResult?.akurasiMeter;
        _gpsTime = locResult?.time;
        _address = address;
        _time = _isIn
            ? null
            : TimeOfDay.fromDateTime(locResult?.time ?? DateTime.now());
      });

      if (_isIn) {
        await _pickTime();
      } else {
        await _restamp();
      }
    } catch (e) {
      // Catch generik hanya untuk kesalahan di luar kendali GPS (misal error ImagePicker)
      _snack('Gagal mengambil foto: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ===========================================================================
  // SISA KODE (TIDAK ADA YANG BERUBAH)
  // ===========================================================================

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

  Future<void> _save() async {
    final t = _time;
    final path = _stampedPath;
    if (t == null || path == null) return;
    final loc = _loc;

    final data = <String, dynamic>{
      'jam': DateUtil.jamOf(t),
      'path': path,
      'lat': loc?.lat,
      'lng': loc?.lng,
    };

    final submit = widget.onSubmit;
    if (submit == null) {
      context.pop(true);
      return;
    }

    setState(() => _sending = true);
    final err = await submit(data);
    if (!mounted) return;
    setState(() => _sending = false);

    if (err != null) {
      _snack(err);
      return;
    }
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _stampedPath != null || _rawPath != null;

    return Scaffold(
      backgroundColor: AppThemeColors.defaultBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          BapendaSliverHeader(
            title: _label,
            showBackButton: true,
            subtitle: Text(
              '${widget.penugasan['balaiRw']}',
              style: TextStyle(
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
                decoration: const BoxDecoration(
                  color: AppThemeColors.defaultSurface,
                  border: Border(
                    top: BorderSide(color: AppThemeColors.subtleBorder),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                child: Button(
                  label: 'Kirim $_label',
                  icon: Icons.send_rounded,
                  isLoading: _sending,
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
        color: AppThemeColors.defaultSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeColors.subtleBorder),
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
        color: AppThemeColors.defaultSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeColors.subtleBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppThemeColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isIn ? Icons.login_rounded : Icons.logout_rounded,
              size: 30,
              color: AppThemeColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Foto $_label',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.titleText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isIn
                ? 'Ambil foto saat tiba di balai RW. Setelah foto, isi jam kedatangan secara manual.'
                : 'Lokasi, tanggal, dan jam otomatis tercetak di foto. Pastikan GPS aktif.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppThemeColors.secondaryText,
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
              onTap: (_busy || _stamping || _sending || _rawPath == null)
                  ? null
                  : _pickTime,
            ),
            const SizedBox(height: 8),
            Text(
              'Jam ini yang tercetak di foto dan dipakai sebagai jam masuk.',
              style: const TextStyle(fontSize: 11.5,  color: AppThemeColors.secondaryText),
            ),
          ] else ...[
            InfoRow(
              label: _isIn ? 'Jam $_label' : 'Jam di foto',
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
            onPressed: _sending ? null : _capture,
          ),
        ],
      ],
    );
  }
}