import 'package:flutter/material.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../../core/utils/date_format_id.dart';
import '../../../../../domain/entities/pengiriman/berkas_entity.dart';
import '../../utils/berkas_sla_ui_helper.dart';
import '../../utils/pantau_ui_helper.dart';
import '../../utils/berkas_style.dart';
import '../common/tone_chip.dart';

/// Kartu berkas di Pantau: identitas (ikon status, WP, no resi, jenis),
/// chip status/SLA, alamat, progres tahap, lalu waktu & tombol Lacak.
class PantauBerkasCard extends StatelessWidget {
  final BerkasEntity berkas;
  final DateTime now;
  final VoidCallback? onTap;

  const PantauBerkasCard({
    super.key,
    required this.berkas,
    required this.now,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tone = berkas.status.tone(palette);
    final sla = berkas.sla(now);
    final tahap = PantauUiHelper.tahap(berkas.status);

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
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tone.bg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(berkas.status.icon, color: tone.fg, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            berkas.namaWp,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 14,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            berkas.noResi,
                            style: TextStyle(
                              color: palette.textTertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    JenisSuratBadge(
                      label: berkas.jenisNama,
                      tone: berkas.jenis.tone(palette),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(66, 8, 14, 0),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ToneChip(
                      label: berkas.statusNama,
                      icon: berkas.status.icon,
                      tone: tone,
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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Row(
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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: tahap == null
                    ? _BannerTerputus(berkas: berkas)
                    : _ProgresKirim(tahap: tahap, warna: tone.fg),
              ),
              Container(
                color: palette.surfaceMuted,
                padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 14,
                      color: palette.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        berkas.tglSelesai != null
                            ? 'Diterima ${formatTanggalId(berkas.tglSelesai!)}'
                                  ' · ${formatJamId(berkas.tglSelesai!)}'
                            : berkas.tglDitugaskan == null
                            ? 'Belum ditugaskan'
                            : 'Ditugaskan ${formatTanggalId(berkas.tglDitugaskan!)}'
                                  ' · ${formatJamId(berkas.tglDitugaskan!)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textTertiary,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onTap,
                      style: TextButton.styleFrom(
                        foregroundColor: palette.accent,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lacak',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, size: 18),
                        ],
                      ),
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

/// Progres 4 tahap: titik terisi sampai tahap saat ini.
class _ProgresKirim extends StatelessWidget {
  final int tahap;
  final Color warna;

  const _ProgresKirim({required this.tahap, required this.warna});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    const semua = TahapKirim.values;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < semua.length; i++)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == 0
                            ? Colors.transparent
                            : (i <= tahap ? warna : palette.border),
                      ),
                    ),
                    _Titik(selesai: i < tahap, kini: i == tahap, warna: warna),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == semua.length - 1
                            ? Colors.transparent
                            : (i < tahap ? warna : palette.border),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  semua[i].label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: i == tahap ? FontWeight.w700 : FontWeight.w500,
                    color: i <= tahap
                        ? palette.textPrimary
                        : palette.textTertiary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Titik extends StatelessWidget {
  final bool selesai;
  final bool kini;
  final Color warna;

  const _Titik({
    required this.selesai,
    required this.kini,
    required this.warna,
  });

  /// Kotak tetap untuk semua titik supaya garis antar-tahap sejajar.
  static const double _kotak = 16;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _kotak,
      child: Center(child: _bulatan(context.palette)),
    );
  }

  Widget _bulatan(AppPalette palette) {
    if (kini) {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: palette.surface,
          border: Border.all(color: warna, width: 4.5),
        ),
      );
    }
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selesai ? warna : palette.surface,
        border: Border.all(
          color: selesai ? warna : palette.borderStrong,
          width: 1.5,
        ),
      ),
      child: selesai
          ? Icon(Icons.check_rounded, size: 10, color: palette.surface)
          : null,
    );
  }
}

/// Gagal antar / dibatalkan: progres diganti keterangan.
class _BannerTerputus extends StatelessWidget {
  final BerkasEntity berkas;
  const _BannerTerputus({required this.berkas});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tone = berkas.status.tone(palette);
    final teks = [
      if (berkas.jumlahGagal > 0) 'Gagal ${berkas.jumlahGagal}x',
      if (berkas.perluDikembalikan) 'surat perlu dikembalikan ke kantor',
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: tone.fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              teks.isEmpty ? berkas.statusNama : teks,
              style: TextStyle(
                color: tone.fg,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
