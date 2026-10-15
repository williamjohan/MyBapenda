import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../../domain/entities/pengiriman/berkas_entity.dart';
import '../../utils/berkas_sla_ui_helper.dart';
import '../../utils/lacak_ui_helper.dart';
import '../../utils/peta_lacak_ui_helper.dart';
import '../../utils/berkas_style.dart';
import '../common/tone_chip.dart';
import 'peta_lacak.dart';

/// Kartu ringkasan: status, no resi (salin), jenis, SLA; lalu peta riwayat
/// perjalanan bila [denganPeta] dan ada koordinat, selain itu nama WP +
/// alamat tujuan.
class LacakStatusCard extends StatelessWidget {
  final LacakViewData data;
  final bool denganPeta;

  const LacakStatusCard({
    super.key,
    required this.data,
    this.denganPeta = false,
  });

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
    final sla = SlaBerkas.hitung(
      status: data.status,
      batasSla: data.tglBatasSla,
      terlambat: data.terlambat,
      now: DateTime.now(),
    );
    final pin = denganPeta
        ? PetaLacakUiHelper.pin(
            data.jejak,
            latTujuan: data.latTujuan,
            longTujuan: data.longTujuan,
            labelTujuan: [
              data.namaWp,
              if (data.alamatTujuan?.isNotEmpty ?? false) data.alamatTujuan!,
            ].join('\n'),
          )
        : const <PinPeta>[];

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
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: palette.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(data.status.icon, color: tone.fg, size: 20),
                ),
                const SizedBox(width: 10),
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
                      if (pin.isNotEmpty)
                        Text(
                          data.namaWp,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      InkWell(
                        onTap: () => _salin(context),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  data.noResi,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: palette.textSecondary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.copy_rounded,
                                size: 13,
                                color: palette.accent,
                                semanticLabel: 'Salin no resi',
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (sla != null) ...[
                        const SizedBox(height: 4),
                        ToneChip(
                          label: sla.label,
                          icon: Icons.schedule_rounded,
                          tone: sla.level.tone(palette),
                        ),
                      ] else if (data.ringkasan != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          data.ringkasan!,
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                JenisSuratBadge(
                  label: data.jenisNama,
                  tone: data.jenis.tone(palette),
                ),
              ],
            ),
          ),
          if (pin.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PetaLacak(pin: pin),
            )
          else
            _Tujuan(data: data),
        ],
      ),
    );
  }
}

class _Tujuan extends StatelessWidget {
  final LacakViewData data;
  const _Tujuan({required this.data});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
    );
  }
}
