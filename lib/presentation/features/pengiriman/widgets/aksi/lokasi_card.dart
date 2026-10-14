import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../../core/services/geo_location_service.dart';
import '../../../../shared/widgets/section_label.dart';
import '../../cubit/aksi/aksi_cubit.dart';
import '../../cubit/aksi/aksi_state.dart';

/// Status GPS untuk check-in: mencari, siap (koordinat + akurasi), atau gagal
/// (dengan tombol coba lagi / buka pengaturan).
class LokasiCard extends StatelessWidget {
  const LokasiCard({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<AksiCubit>();

    return BlocBuilder<AksiCubit, AksiState>(
      buildWhen: (p, c) =>
          p.lokasiStatus != c.lokasiStatus ||
          p.lokasi != c.lokasi ||
          p.lokasiError != c.lokasiError,
      builder: (context, state) {
        final (
          IconData icon,
          Color warna,
          String judul,
          String? isi,
        ) = switch (state.lokasiStatus) {
          LokasiStatus.mencari => (
            Icons.gps_not_fixed_rounded,
            palette.statusProses,
            'Mencari lokasi…',
            'Pastikan GPS aktif.',
          ),
          LokasiStatus.siap => (
            Icons.gps_fixed_rounded,
            palette.statusSukses,
            'Lokasi didapat',
            state.lokasi == null
                ? null
                : '${state.lokasi!.latitude.toStringAsFixed(6)}, '
                      '${state.lokasi!.longitude.toStringAsFixed(6)}'
                      '  ·  ±${state.lokasi!.akurasiMeter.round()} m',
          ),
          LokasiStatus.gagal => (
            Icons.gps_off_rounded,
            palette.statusGagal,
            'Lokasi gagal',
            state.lokasiError,
          ),
        };
        final akurasiRendah =
            state.lokasiSiap && state.lokasi!.akurasiMeter > 50;
        final bisaPengaturan =
            state.lokasiErrorKode == GeoLocationError.serviceDisabled ||
            state.lokasiErrorKode == GeoLocationError.permissionDeniedForever;

        return SurfaceCard(
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
          child: Row(
            children: [
              if (state.lokasiStatus == LokasiStatus.mencari)
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: warna,
                  ),
                )
              else
                Icon(icon, color: warna),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isi != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        isi,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (akurasiRendah) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Akurasi rendah: tetap terkirim, tapi ditandai review.',
                        style: TextStyle(
                          color: palette.statusWarning,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (bisaPengaturan)
                TextButton(
                  onPressed: cubit.bukaPengaturanLokasi,
                  child: const Text('Pengaturan'),
                ),
              if (state.lokasiStatus != LokasiStatus.mencari)
                IconButton(
                  tooltip: 'Perbarui lokasi',
                  onPressed: cubit.cariLokasi,
                  icon: Icon(Icons.refresh_rounded, color: palette.accent),
                ),
            ],
          ),
        );
      },
    );
  }
}
