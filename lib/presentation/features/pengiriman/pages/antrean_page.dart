import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../core/utils/date_format_id.dart';
import '../../../../domain/entities/pengiriman/antrean_entity.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/section_label.dart';
import '../cubit/antrean/antrean_pengiriman_cubit.dart';
import '../cubit/antrean/antrean_pengiriman_state.dart';
import '../widgets/common/pengiriman_message.dart';
import '../widgets/common/tone_chip.dart';

/// Daftar aksi belum terkirim (antrean) dan yang ditolak server.
class AntreanPage extends StatelessWidget {
  const AntreanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<AntreanPengirimanCubit>();

    return Scaffold(
      backgroundColor: palette.background,
      body: BlocBuilder<AntreanPengirimanCubit, AntreanPengirimanState>(
        builder: (context, state) {
          final r = state.ringkasan;
          return CustomScrollView(
            slivers: [
              const BapendaSliverHeader(
                title: 'Belum Terkirim',
                showBackButton: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                sliver: SliverList.list(
                  children: [
                    if (r.jumlah == 0)
                      const PengirimanMessage(
                        icon: Icons.cloud_done_outlined,
                        message: 'Semua data sudah terkirim.',
                      ),
                    if (r.menunggu.isNotEmpty) ...[
                      SectionLabel(
                        text: 'Menunggu dikirim (${r.menunggu.length})',
                        icon: Icons.schedule_send_outlined,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Dikirim berurutan otomatis saat ada sinyal atau '
                        'aplikasi dibuka lagi.',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final a in r.menunggu) ...[
                        _ItemAntrean(item: a),
                        const SizedBox(height: 10),
                      ],
                      Button(
                        label: state.sedangKirim
                            ? 'Mengirim…'
                            : 'Kirim Sekarang',
                        icon: Icons.cloud_upload_outlined,
                        isLoading: state.sedangKirim,
                        onPressed: cubit.kirim,
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (r.gagal.isNotEmpty) ...[
                      SectionLabel(
                        text: 'Perlu dicek (${r.gagal.length})',
                        icon: Icons.error_outline_rounded,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ditolak server atau status tidak berubah. Cek berkas '
                        'lalu ulangi aksinya bila perlu.',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final a in r.gagal) ...[
                        _ItemAntrean(
                          item: a,
                          ditolak: true,
                          onHapus: () => cubit.hapusGagal(a.checkinUuid),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ItemAntrean extends StatelessWidget {
  final AntreanPengirimanEntity item;
  final bool ditolak;
  final VoidCallback? onHapus;

  const _ItemAntrean({required this.item, this.ditolak = false, this.onHapus});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tone = ditolak
        ? (item.diabaikan
              ? (fg: palette.statusWarning, bg: palette.statusWarningSoft)
              : (fg: palette.statusGagal, bg: palette.statusGagalSoft))
        : (fg: palette.statusProses, bg: palette.statusProsesSoft);
    final t = item.tglDibuat;

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ToneChip(label: item.jenis.label, tone: tone),
                    const Spacer(),
                    Text(
                      '${formatTanggalId(t)} ${formatJamId(t)}',
                      style: TextStyle(
                        color: palette.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.noResi.join(', '),
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (item.pesan?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  Text(
                    ditolak
                        ? item.pesan!
                        : 'Percobaan ${item.jmlCoba}x · ${item.pesan}',
                    style: TextStyle(
                      color: ditolak ? tone.fg : palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ] else if (ditolak && item.diabaikan) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Tersimpan sebagai jejak, status berkas tidak berubah.',
                    style: TextStyle(color: tone.fg, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (onHapus != null)
            IconButton(
              tooltip: 'Tandai sudah dicek',
              onPressed: onHapus,
              icon: Icon(Icons.close_rounded, color: palette.textTertiary),
            ),
        ],
      ),
    );
  }
}
