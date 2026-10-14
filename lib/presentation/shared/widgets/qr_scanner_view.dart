import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/design_system/tokens/app_palette.dart';

/// Halaman scan QR layar penuh (mobile_scanner).
/// - [QrScannerView.scanSatu]: tutup otomatis begitu satu kode terbaca.
/// - [QrScannerView.scanBanyak]: kumpulkan banyak kode (duplikat diabaikan,
///   getar + bunyi tiap kode baru), daftar di bottom sheet, tombol Selesai.
/// Isi QR dikembalikan apa adanya (trim); server yang mengurai.
class QrScannerView extends StatefulWidget {
  final String judul;
  final bool banyak;

  /// Batas jumlah kode untuk mode banyak.
  final int maks;
  final List<String> awal;

  const QrScannerView({
    super.key,
    required this.judul,
    this.banyak = false,
    this.maks = 100,
    this.awal = const [],
  });

  static Future<String?> scanSatu(
    BuildContext context, {
    String judul = 'Scan QR',
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => QrScannerView(judul: judul)),
    );
  }

  /// null bila dibatalkan.
  static Future<List<String>?> scanBanyak(
    BuildContext context, {
    String judul = 'Scan QR',
    int maks = 100,
    List<String> awal = const [],
  }) {
    return Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) =>
            QrScannerView(judul: judul, banyak: true, maks: maks, awal: awal),
      ),
    );
  }

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  late final List<String> _kode = [...widget.awal];
  bool _selesai = false;
  String? _pesan;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_selesai) return;
    for (final b in capture.barcodes) {
      final raw = b.rawValue?.trim();
      if (raw == null || raw.isEmpty) continue;

      if (!widget.banyak) {
        _selesai = true;
        HapticFeedback.mediumImpact();
        Navigator.of(context).pop(raw);
        return;
      }
      if (_kode.contains(raw)) {
        setState(() => _pesan = 'Sudah discan: $raw');
        continue;
      }
      if (_kode.length >= widget.maks) {
        setState(() => _pesan = 'Maksimal ${widget.maks} kode');
        return;
      }
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
      setState(() {
        _kode.add(raw);
        _pesan = 'Terbaca: $raw';
      });
    }
  }

  void _hapus(String k) => setState(() => _kode.remove(k));

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(widget.judul, style: const TextStyle(fontSize: 17)),
          actions: [
            IconButton(
              tooltip: 'Senter',
              onPressed: _controller.toggleTorch,
              icon: const Icon(Icons.flashlight_on_outlined),
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) => _ErrorKamera(error: error),
            ),
            const _Bingkai(),
            if (_pesan != null)
              Positioned(
                left: 24,
                right: 24,
                top: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _pesan!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            if (widget.banyak)
              DraggableScrollableSheet(
                initialChildSize: 0.22,
                minChildSize: 0.14,
                maxChildSize: 0.7,
                builder: (context, scroll) => Container(
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: ListView(
                    controller: scroll,
                    padding: EdgeInsets.fromLTRB(
                      16,
                      10,
                      16,
                      16 + MediaQuery.paddingOf(context).bottom,
                    ),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: palette.borderStrong,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_kode.length} kode terbaca',
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: palette.accent,
                            ),
                            onPressed: _kode.isEmpty
                                ? null
                                : () => Navigator.of(context).pop(_kode),
                            child: const Text('Selesai'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final k in _kode.reversed)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.qr_code_2_rounded,
                            color: palette.accent,
                          ),
                          title: Text(
                            k,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: IconButton(
                            tooltip: 'Hapus',
                            onPressed: () => _hapus(k),
                            icon: Icon(
                              Icons.close_rounded,
                              color: palette.textTertiary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Bingkai extends StatelessWidget {
  const _Bingkai();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.35),
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
      ),
    );
  }
}

class _ErrorKamera extends StatelessWidget {
  final MobileScannerException error;
  const _ErrorKamera({required this.error});

  @override
  Widget build(BuildContext context) {
    final izin = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          izin
              ? 'Izin kamera ditolak. Aktifkan izin kamera di pengaturan HP.'
              : 'Kamera tidak bisa dibuka (${error.errorCode.name}).',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
