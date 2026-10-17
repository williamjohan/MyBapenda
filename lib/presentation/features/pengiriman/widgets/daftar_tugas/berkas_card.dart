import 'package:flutter/material.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../../domain/entities/pengiriman/berkas_entity.dart';
import '../../utils/berkas_sla_ui_helper.dart';
import '../../utils/berkas_style.dart';
import '../common/tone_chip.dart';

class BerkasCard extends StatelessWidget {
  final BerkasEntity berkas;
  final DateTime now;
  final VoidCallback? onTap;

  const BerkasCard({
    super.key,
    required this.berkas,
    required this.now,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final sla = berkas.sla(now);

    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: palette.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (berkas.perluDikembalikan)
                _BannerKembalikan(
                  palette: palette,
                  dibatalkan: berkas.status == StatusBerkas.dibatalkan,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 16,
                          color: palette.textTertiary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            berkas.noResi,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        JenisSuratBadge(
                          label: berkas.jenisNama,
                          tone: berkas.jenis.tone(palette),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      berkas.namaWp,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: palette.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            berkas.alamatTujuan,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ToneChip(
                          label: berkas.statusNama,
                          icon: berkas.status.icon,
                          tone: berkas.status.tone(palette),
                        ),
                        if (sla != null)
                          ToneChip(
                            label: sla.label,
                            icon: Icons.schedule_rounded,
                            tone: sla.level.tone(palette),
                          ),
                        if (berkas.antreanTertunda > 0)
                          ToneChip(
                            label: 'Belum terkirim',
                            icon: Icons.cloud_upload_outlined,
                            tone: (
                              fg: palette.statusWarning,
                              bg: palette.statusWarningSoft,
                            ),
                          ),
                        if (berkas.percobaanKe > 1)
                          ToneChip(
                            label: 'Percobaan ke-${berkas.percobaanKe}',
                            tone: (
                              fg: palette.textSecondary,
                              bg: palette.surfaceMuted,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerKembalikan extends StatelessWidget {
  final AppPalette palette;
  final bool dibatalkan;
  const _BannerKembalikan({required this.palette, required this.dibatalkan});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette.statusGagalSoft,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.keyboard_return_rounded,
            size: 16,
            color: palette.statusGagal,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              dibatalkan
                  ? 'Dibatalkan, kembalikan ke kantor'
                  : 'Kembalikan berkas ke kantor',
              style: TextStyle(
                color: palette.statusGagal,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
