import 'package:flutter/material.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../core/utils/date_format_id.dart';
import '../../../../domain/entities/notifikasi/notifikasi_entity.dart';

/// Satu baris kotak masuk; belum dibaca = latar aksen + titik.
class NotifikasiTile extends StatelessWidget {
  final NotifikasiEntity notif;
  final VoidCallback onTap;

  const NotifikasiTile({super.key, required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final baru = !notif.dibaca;
    final tgl = notif.tglNotifikasi;

    return Material(
      color: baru ? palette.accentSoft : palette.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: palette.surfaceMuted,
                child: Icon(
                  notif.noResiBerkas != null
                      ? Icons.two_wheeler_outlined
                      : Icons.notifications_outlined,
                  size: 20,
                  color: palette.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.judul,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 14,
                        fontWeight: baru ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.isi,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    if (tgl != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        formatTanggalRelatifId(tgl),
                        style: TextStyle(
                          color: palette.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (baru)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: palette.accent,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
