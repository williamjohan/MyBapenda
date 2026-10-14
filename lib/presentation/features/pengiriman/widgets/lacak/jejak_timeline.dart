import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../../core/utils/date_format_id.dart';
import '../../../../../domain/entities/pengiriman/jejak_entity.dart';
import '../../../../shared/widgets/bapenda_image.dart';
import '../../utils/berkas_style.dart';
import '../../utils/pengiriman_foto_url.dart';
import '../common/tone_chip.dart';
import 'jejak_foto_viewer.dart';

/// Riwayat perjalanan berkas bergaya lacak paket: jejak terbaru di atas
/// dengan titik berwarna status, jejak lama abu-abu.
class JejakTimeline extends StatelessWidget {
  /// Sudah urut terbaru di atas.
  final List<JejakEntity> jejak;

  const JejakTimeline({super.key, required this.jejak});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (jejak.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Belum ada jejak perjalanan.',
          style: TextStyle(color: palette.textTertiary, fontSize: 13),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < jejak.length; i++)
          _JejakItem(
            jejak: jejak[i],
            terbaru: i == 0,
            terakhir: i == jejak.length - 1,
          ),
      ],
    );
  }
}

class _JejakItem extends StatelessWidget {
  final JejakEntity jejak;
  final bool terbaru;
  final bool terakhir;

  const _JejakItem({
    required this.jejak,
    required this.terbaru,
    required this.terakhir,
  });

  Future<void> _bukaPeta(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${jejak.latitude},${jejak.longitude}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka aplikasi peta')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tone = jejak.status.tone(palette);
    final tgl = jejak.tglCheckin;
    final meta = [
      if (jejak.namaPetugas?.isNotEmpty ?? false) jejak.namaPetugas!,
      if (jejak.jarakKeTujuan != null) _jarak(jejak.jarakKeTujuan!),
      if (jejak.sumber?.isNotEmpty ?? false) 'via ${jejak.sumber}',
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 56,
            child: tgl == null
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatJamId(tgl),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: terbaru ? tone.fg : palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatTanggalId(tgl),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: palette.textTertiary,
                        ),
                      ),
                    ],
                  ),
          ),
          // Garis digambar per item setinggi item (bukan tinggi tetap) dan
          // selalu lewat tengah titik: item pertama tanpa garis ke atas,
          // item terakhir tanpa garis ke bawah.
          SizedBox(
            width: 32,
            child: CustomPaint(
              painter: _GarisPainter(
                atas: !terbaru,
                bawah: !terakhir,
                warna: palette.border,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: _pusatTitik - _Titik.ukuran(terbaru) / 2,
                  ),
                  child: _Titik(
                    terbaru: terbaru,
                    warna: tone.fg,
                    halo: tone.bg,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: terakhir ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jejak.statusNama,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: terbaru ? tone.fg : palette.textPrimary,
                    ),
                  ),
                  if (jejak.keterangan?.trim().isNotEmpty ?? false) ...[
                    const SizedBox(height: 3),
                    Text(
                      jejak.keterangan!.trim(),
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      meta.join('  ·  '),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: palette.textTertiary,
                      ),
                    ),
                  ],
                  _Penanda(jejak: jejak),
                  if (jejak.foto.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _FotoStrip(foto: jejak.foto),
                  ] else if (jejak.jumlahFoto > 0) ...[
                    const SizedBox(height: 6),
                    _Tautan(
                      icon: Icons.photo_library_outlined,
                      label: '${jejak.jumlahFoto} foto terlampir',
                    ),
                  ],
                  if (jejak.punyaKoordinat) ...[
                    const SizedBox(height: 6),
                    _Tautan(
                      icon: Icons.map_outlined,
                      label: 'Lihat lokasi check-in',
                      onTap: () => _bukaPeta(context),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _jarak(double meter) => meter >= 1000
      ? '±${(meter / 1000).toStringAsFixed(1)} km dari tujuan'
      : '±${meter.round()} m dari tujuan';
}

/// Jarak pusat titik dari atas item: sejajar baris judul status (14px).
const double _pusatTitik = 10;

class _Titik extends StatelessWidget {
  final bool terbaru;
  final Color warna;
  final Color halo;

  const _Titik({
    required this.terbaru,
    required this.warna,
    required this.halo,
  });

  static double ukuran(bool terbaru) => terbaru ? 18 : 10;

  @override
  Widget build(BuildContext context) {
    if (!terbaru) {
      return Container(
        width: ukuran(false),
        height: ukuran(false),
        decoration: BoxDecoration(
          color: context.palette.borderStrong,
          shape: BoxShape.circle,
        ),
      );
    }
    return Container(
      width: ukuran(true),
      height: ukuran(true),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: halo, shape: BoxShape.circle),
      child: DecoratedBox(
        decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
      ),
    );
  }
}

/// Penanda khusus jejak (diabaikan, perlu review, akurasi/waktu janggal).
class _Penanda extends StatelessWidget {
  final JejakEntity jejak;
  const _Penanda({required this.jejak});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final warning = (fg: p.statusWarning, bg: p.statusWarningSoft);
    final chips = [
      if (jejak.belumTerkirim)
        ToneChip(
          label: 'Belum terkirim',
          icon: Icons.cloud_upload_outlined,
          tone: warning,
        ),
      if (jejak.diabaikan)
        ToneChip(
          label: 'Status tidak berubah',
          icon: Icons.info_outline_rounded,
          tone: (fg: p.statusBatal, bg: p.statusBatalSoft),
        ),
      if (jejak.perluReview)
        ToneChip(
          label: 'Perlu review',
          icon: Icons.flag_outlined,
          tone: warning,
        ),
      if (jejak.flagAkurasi)
        ToneChip(
          label: jejak.akurasi == null
              ? 'Akurasi GPS rendah'
              : 'Akurasi ±${jejak.akurasi!.round()} m',
          icon: Icons.gps_not_fixed_rounded,
          tone: warning,
        ),
      if (jejak.flagWaktu)
        ToneChip(
          label: 'Waktu HP janggal',
          icon: Icons.schedule_rounded,
          tone: warning,
        ),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(spacing: 6, runSpacing: 6, children: chips),
    );
  }
}

class _FotoStrip extends StatelessWidget {
  final List<FotoJejakEntity> foto;
  const _FotoStrip({required this.foto});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < foto.length; i++)
          GestureDetector(
            onTap: () => JejakFotoViewer.open(context, foto, awal: i),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: BapendaImage(
                path: pengirimanFotoUrl(foto[i].key),
                width: 64,
                height: 64,
                cacheWidth: 200,
              ),
            ),
          ),
      ],
    );
  }
}

class _Tautan extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _Tautan({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final warna = onTap == null ? palette.textTertiary : palette.accent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: warna),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: warna,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Garis vertikal satu sumbu (tengah kolom) yang menyambung antar item:
/// [atas] dari tepi atas ke pusat titik, [bawah] dari pusat ke tepi bawah.
class _GarisPainter extends CustomPainter {
  final bool atas;
  final bool bawah;
  final Color warna;

  const _GarisPainter({
    required this.atas,
    required this.bawah,
    required this.warna,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final paint = Paint()
      ..color = warna
      ..strokeWidth = 2;
    if (atas) canvas.drawLine(Offset(x, 0), Offset(x, _pusatTitik), paint);
    if (bawah) {
      canvas.drawLine(Offset(x, _pusatTitik), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_GarisPainter old) =>
      old.atas != atas || old.bawah != bawah || old.warna != warna;
}
