import 'package:flutter/material.dart';

import '../../../../../domain/entities/pengiriman/lacak_entity.dart';
import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../shared/widgets/section_label.dart';
import '../../utils/lacak_ui_helper.dart';
import 'jejak_timeline.dart';
import 'lacak_status_card.dart';

/// Isi halaman berkas: ringkasan status, riwayat perjalanan (opsional),
/// lalu seksi info. Lacak (Pantau) menampilkan peta + riwayat; Detail
/// Berkas tidak.
class LacakDetailView extends StatelessWidget {
  final LacakViewData data;

  /// Peta & timeline jejak; Detail Berkas mematikannya (riwayat ada di Lacak).
  final bool tampilkanRiwayat;

  /// Jalur jalan untuk peta (Lacak); null = peta hanya menampilkan titik.
  final List<TitikRute>? rute;

  const LacakDetailView({
    super.key,
    required this.data,
    this.tampilkanRiwayat = true,
    this.rute,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LacakStatusCard(data: data, denganPeta: tampilkanRiwayat, rute: rute),
        if (tampilkanRiwayat) ...[
          const SizedBox(height: 16),
          const SectionLabel(
            text: 'Riwayat Perjalanan',
            icon: Icons.route_outlined,
          ),
          const SizedBox(height: 8),
          SurfaceCard(child: JejakTimeline(jejak: data.jejak)),
        ],
        for (final s in data.seksi) ...[
          const SizedBox(height: 16),
          SectionLabel(text: s.judul, icon: _ikonSeksi(s.judul)),
          const SizedBox(height: 8),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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
