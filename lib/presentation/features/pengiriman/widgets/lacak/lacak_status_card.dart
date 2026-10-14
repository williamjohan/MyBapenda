import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../logic/berkas_sla_logic.dart';
import '../../logic/lacak_view_data.dart';
import '../../utils/berkas_style.dart';
import '../common/tone_chip.dart';

/// Kartu ringkasan di atas timeline: status saat ini, no resi (salin),
/// jenis surat, SLA, dan tujuan.
class LacakStatusCard extends StatelessWidget {
  final LacakViewData data;

  const LacakStatusCard({super.key, required this.data});

  void _salin(BuildContext context) {
    Clipboard.setData(ClipboardData(text: data.noResi));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('No resi disalin')));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tone = data.status.tone(palette);
    final sla = BerkasSlaLogic.hitung(
      status: data.status,
      batasSla: data.tglBatasSla,
      terlambat: data.terlambat,
      now: DateTime.now(),
    );

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
        boxShadow: palette.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: tone.bg,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: palette.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(data.status.icon, color: tone.fg, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.statusNama,
                        style: TextStyle(
                          color: tone.fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (data.ringkasan != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          data.ringkasan!,
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'No. Resi  ',
                      style: TextStyle(
                        color: palette.textTertiary,
                        fontSize: 12.5,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        data.noResi,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Salin no resi',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _salin(context),
                      icon: Icon(
                        Icons.copy_rounded,
                        size: 18,
                        color: palette.accent,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      JenisSuratBadge(
                        label: data.jenisNama,
                        tone: data.jenis.tone(palette),
                      ),
                      if (sla != null)
                        ToneChip(
                          label: sla.label,
                          icon: Icons.schedule_rounded,
                          tone: sla.level.tone(palette),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: palette.accent,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.namaWp,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (data.alamatTujuan?.isNotEmpty ?? false) ...[
                              const SizedBox(height: 2),
                              Text(
                                data.alamatTujuan!,
                                style: TextStyle(
                                  color: palette.textSecondary,
                                  fontSize: 12.5,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
