import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../../domain/entities/pengiriman/berkas_entity.dart';
import '../../../../../domain/entities/pengiriman/pengiriman_payload_entity.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../shared/widgets/button.dart';
import '../../pages/aksi/scan_berkas_page.dart';

/// Tombol aksi di bawah detail berkas, hanya yang ada di `aksi[]` server.
/// Aksi utama tampil sebagai tombol penuh, sisanya tombol garis.
/// [onSelesai] dipanggil setelah aksi berhasil (muat ulang detail).
class AksiBar extends StatelessWidget {
  final BerkasEntity berkas;
  final VoidCallback onSelesai;

  const AksiBar({super.key, required this.berkas, required this.onSelesai});

  /// Urutan prioritas: yang pertama jadi tombol utama.
  static const _urutan = [
    AksiBerkas.ambil,
    AksiBerkas.serah,
    AksiBerkas.tiba,
    AksiBerkas.kembalikan,
    AksiBerkas.perjalanan,
    AksiBerkas.gagal,
  ];

  static (String, IconData) _info(AksiBerkas a) => switch (a) {
    AksiBerkas.ambil => ('Ambil Surat', Icons.move_to_inbox_outlined),
    AksiBerkas.perjalanan => ('Update Posisi', Icons.two_wheeler_outlined),
    AksiBerkas.tiba => ('Tiba di Tujuan', Icons.place_outlined),
    AksiBerkas.serah => ('Serah Terima', Icons.task_alt_rounded),
    AksiBerkas.gagal => ('Gagal Antar', Icons.report_gmailerrorred_rounded),
    AksiBerkas.kembalikan => ('Kembalikan', Icons.keyboard_return_rounded),
  };

  Future<void> _buka(BuildContext context, AksiBerkas a) async {
    final noResi = berkas.noResi;
    final (String rute, Object extra) = switch (a) {
      AksiBerkas.ambil => (
        AppRoutes.pengirimanScan,
        (mode: ModeScanBerkas.ambil, awal: [noResi]),
      ),
      AksiBerkas.kembalikan => (
        AppRoutes.pengirimanScan,
        (mode: ModeScanBerkas.kembalikan, awal: [noResi]),
      ),
      AksiBerkas.perjalanan => (
        AppRoutes.pengirimanCheckin,
        (noResi: noResi, jenis: JenisCheckin.perjalanan),
      ),
      AksiBerkas.tiba => (
        AppRoutes.pengirimanCheckin,
        (noResi: noResi, jenis: JenisCheckin.tiba),
      ),
      AksiBerkas.serah => (AppRoutes.pengirimanSerah, berkas),
      AksiBerkas.gagal => (AppRoutes.pengirimanGagal, noResi),
    };
    final hasil = await context.push<bool>(rute, extra: extra);
    if (hasil == true) onSelesai();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final aksi = _urutan.where(berkas.boleh).toList();
    if (aksi.isEmpty) return const SizedBox.shrink();

    final utama = aksi.first;
    final lain = aksi.skip(1).toList();
    final (label, icon) = _info(utama);

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lain.isNotEmpty) ...[
            Row(
              children: [
                for (var i = 0; i < lain.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: Button(
                      label: _info(lain[i]).$1,
                      icon: _info(lain[i]).$2,
                      height: 44,
                      variant: BapendaButtonVariant.outlined,
                      onPressed: () => _buka(context, lain[i]),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
          ],
          Button(
            label: label,
            icon: icon,
            onPressed: () => _buka(context, utama),
          ),
        ],
      ),
    );
  }
}
