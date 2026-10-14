import 'package:flutter/material.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';

/// Satu tab: ikon status, label, jumlah (null = belum termuat),
/// [sorot] = badge merah bila ada isi (butuh tindakan).
typedef StatusTabItem = ({
  String label,
  IconData icon,
  int? jumlah,
  bool sorot,
});

/// Bar tab status yang sama untuk Pengiriman Surat & Pantau Surat:
/// ikon + label + badge jumlah, bisa digeser, indikator aksen.
class StatusTabBar extends StatelessWidget {
  final TabController controller;
  final List<StatusTabItem> items;

  const StatusTabBar({
    super.key,
    required this.controller,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      color: palette.surface,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: palette.accent,
        unselectedLabelColor: palette.textSecondary,
        indicatorColor: palette.accent,
        indicatorWeight: 3,
        dividerColor: palette.border,
        labelPadding: const EdgeInsets.symmetric(horizontal: 14),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: [for (final item in items) _StatusTab(item: item)],
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  final StatusTabItem item;
  const _StatusTab({required this.item});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final jumlah = item.jumlah;
    final merah = item.sorot && (jumlah ?? 0) > 0;

    return Tab(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warna ikon ikut label (aktif = aksen) lewat IconTheme TabBar.
          Icon(item.icon, size: 18),
          const SizedBox(width: 6),
          Text(item.label),
          if (jumlah != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                color: merah ? palette.statusGagal : palette.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                jumlah > 99 ? '99+' : '$jumlah',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: merah ? palette.surface : palette.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
