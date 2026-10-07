import 'package:flutter/material.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../domain/entities/absensi/riwayat_absensi_entity.dart';
import '../constants/absensi_formatters.dart';
import '../logic/rekap_harian_logic.dart';

/// Satu kartu per hari berisi timeline scan (terbaru di atas).
class RiwayatDayGroup extends StatelessWidget {
  final RiwayatHarian group;
  final DateTime today;

  const RiwayatDayGroup({super.key, required this.group, required this.today});

  String get _judul {
    final diff = DateTime(
      today.year,
      today.month,
      today.day,
    ).difference(group.tanggal).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    return AbsensiFormatters.tanggal(group.tanggal);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final rekap = group.rekap;
    final items = group.items;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
        boxShadow: palette.cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: palette.accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _judul,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${items.length} scan',
                  style: TextStyle(color: palette.textTertiary, fontSize: 11),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: palette.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++)
                  RiwayatTimelineTile(
                    item: items[i],
                    isFirst: i == 0,
                    isLast: i == items.length - 1,
                    tag: _tagFor(items[i], rekap),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Scan valid paling awal = MASUK, paling akhir = PULANG.
  RiwayatTag? _tagFor(RiwayatAbsensiEntity item, RekapHarian rekap) {
    if (!item.isValid) return null;
    if (item.tglPresensi == rekap.masuk) return RiwayatTag.masuk;
    if (item.tglPresensi == rekap.pulang) return RiwayatTag.pulang;
    return null;
  }
}

/// Penanda scan pertama (MASUK) / terakhir (PULANG) dalam sehari.
enum RiwayatTag { masuk, pulang }

class RiwayatTimelineTile extends StatelessWidget {
  final RiwayatAbsensiEntity item;
  final bool isFirst;
  final bool isLast;
  final RiwayatTag? tag;

  const RiwayatTimelineTile({
    super.key,
    required this.item,
    this.isFirst = false,
    this.isLast = false,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (icon, sumber) = _sumber(item);
    final dotColor = !item.isValid
        ? palette.danger
        : switch (tag) {
            RiwayatTag.masuk => palette.success,
            RiwayatTag.pulang => palette.accent,
            null => palette.borderStrong,
          };
    final detail = [
      item.namaDevice ?? sumber,
      if (item.namaLokasi != null) item.namaLokasi!,
    ].join(' · ');

    return Opacity(
      opacity: item.isValid ? 1 : 0.6,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 70,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  AbsensiFormatters.jam(item.tglPresensi),
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            // Garis & titik timeline.
            SizedBox(
              width: 20,
              child: Column(
                children: [
                  Container(
                    width: 2,
                    height: 13,
                    color: isFirst ? Colors.transparent : palette.border,
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: palette.surface, width: 2),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isLast ? Colors.transparent : palette.border,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(icon, size: 14, color: palette.textSecondary),
                        Text(
                          sumber,
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (tag == RiwayatTag.masuk)
                          _Chip('Masuk', palette.success, palette.successSoft),
                        if (tag == RiwayatTag.pulang)
                          _Chip('Pulang', palette.accent, palette.accentSoft),
                        if (!item.isValid)
                          _Chip('Ditolak', palette.danger, palette.dangerSoft),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    if (item.keterangan != null && item.keterangan!.isNotEmpty)
                      Text(
                        item.keterangan!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textTertiary,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
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

  (IconData, String) _sumber(RiwayatAbsensiEntity item) {
    switch (item.sumber) {
      case SumberAbsensi.manual:
        return (Icons.edit_outlined, 'Input manual');
      case SumberAbsensi.sync:
        return (Icons.fingerprint, 'Mesin finger');
      case SumberAbsensi.online:
        return item.jenisDevice == 2
            ? (Icons.fingerprint, 'Mesin finger')
            : (Icons.smartphone_rounded, 'Aplikasi');
    }
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color fg;
  final Color bg;
  const _Chip(this.text, this.fg, this.bg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
