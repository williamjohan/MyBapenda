import 'package:flutter/material.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../shared/widgets/section_label.dart';
import '../../logic/lacak_view_data.dart';
import 'jejak_timeline.dart';
import 'lacak_status_card.dart';

/// Isi halaman berkas: ringkasan status, riwayat perjalanan (opsional),
/// lalu seksi info. Lacak (Pantau) menampilkan riwayat; Detail Berkas tidak.
class LacakDetailView extends StatelessWidget {
  final LacakViewData data;

  /// Konten tambahan di atas kartu status (mis. penanda "Tugas Anda").
  final Widget? header;

  /// Timeline jejak; Detail Berkas mematikannya (riwayat ada di Lacak).
  final bool tampilkanRiwayat;

  const LacakDetailView({
    super.key,
    required this.data,
    this.header,
    this.tampilkanRiwayat = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) ...[header!, const SizedBox(height: 12)],
        LacakStatusCard(data: data),
        if (tampilkanRiwayat) ...[
          const SizedBox(height: 20),
          const SectionLabel(
            text: 'Riwayat Perjalanan',
            icon: Icons.route_outlined,
          ),
          const SizedBox(height: 10),
          SurfaceCard(child: JejakTimeline(jejak: data.jejak)),
        ],
        for (final s in data.seksi) ...[
          const SizedBox(height: 20),
          SectionLabel(text: s.judul, icon: _ikonSeksi(s.judul)),
          const SizedBox(height: 10),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                for (var i = 0; i < s.baris.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: context.palette.border),
                  _Baris(baris: s.baris[i]),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Baris extends StatelessWidget {
  final InfoBaris baris;
  const _Baris({required this.baris});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              baris.label,
              style: TextStyle(fontSize: 12.5, color: palette.textTertiary),
            ),
          ),
          Expanded(
            child: Text(
              baris.value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _ikonSeksi(String judul) => switch (judul) {
  'Info Penerbitan' => Icons.description_outlined,
  'Info Pengiriman' => Icons.two_wheeler_outlined,
  'Info Penerimaan' => Icons.how_to_reg_outlined,
  'Perlu Perhatian' => Icons.report_problem_outlined,
  _ => Icons.info_outline_rounded,
};
