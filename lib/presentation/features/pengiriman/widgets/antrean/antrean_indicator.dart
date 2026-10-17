import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../../routes/app_routes.dart';
import '../../cubit/antrean/antrean_pengiriman_cubit.dart';
import '../../cubit/antrean/antrean_pengiriman_state.dart';

/// Ikon "N belum terkirim" di header; disembunyikan bila antrean kosong.
/// Ketuk untuk membuka daftar antrean & yang ditolak server.
class AntreanIndicator extends StatelessWidget {
  const AntreanIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return BlocBuilder<AntreanPengirimanCubit, AntreanPengirimanState>(
      builder: (context, state) {
        final r = state.ringkasan;
        if (r.jumlah == 0) return const SizedBox.shrink();
        final adaGagal = r.gagal.isNotEmpty;

        return IconButton(
          tooltip: '${r.jumlah} belum terkirim',
          onPressed: () => context.push(AppRoutes.pengirimanAntrean),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                state.sedangKirim
                    ? Icons.cloud_sync_outlined
                    : Icons.cloud_upload_outlined,
                color: Colors.white,
              ),
              Positioned(
                right: -8,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  constraints: const BoxConstraints(minWidth: 18),
                  decoration: BoxDecoration(
                    color: adaGagal
                        ? palette.statusGagal
                        : palette.statusWarning,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    r.jumlah > 99 ? '99+' : '${r.jumlah}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Pita kecil "Data offline" saat daftar/detail memakai cache.
class OfflineBanner extends StatelessWidget {
  final DateTime tglCache;

  const OfflineBanner({super.key, required this.tglCache});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final t = tglCache;
    final jam =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      color: palette.statusWarningSoft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: palette.statusWarning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tanpa sinyal · data terakhir ${t.day}/${t.month} $jam',
              style: TextStyle(
                color: palette.statusWarning,
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

/// Muat ulang data halaman tiap ada aksi antrean yang terkirim/ditolak,
/// supaya status dari server menggantikan tampilan sementara.
class AntreanReloadListener extends StatelessWidget {
  final VoidCallback onBerubah;
  final Widget child;

  const AntreanReloadListener({
    super.key,
    required this.onBerubah,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AntreanPengirimanCubit, AntreanPengirimanState>(
      listenWhen: (p, c) =>
          c.ringkasan.menunggu.length < p.ringkasan.menunggu.length,
      listener: (_, _) => onBerubah(),
      child: child,
    );
  }
}
