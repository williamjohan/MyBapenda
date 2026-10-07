import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../core/utils/app_file_opener_utils.dart';
import '../../../../core/utils/app_share_utils.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/section_label.dart';
import '../../../shared/widgets/theme_toggle_button.dart';
import '../cubit/laporan_cubit.dart';
import '../cubit/laporan_state.dart';
import '../widgets/laporan_result_card.dart';
import '../widgets/periode_picker_card.dart';

/// Unduh PDF laporan kehadiran bulanan (sama dengan cetakan web).
class LaporanKehadiranPage extends StatefulWidget {
  const LaporanKehadiranPage({super.key});

  @override
  State<LaporanKehadiranPage> createState() => _LaporanKehadiranPageState();
}

class _LaporanKehadiranPageState extends State<LaporanKehadiranPage> {
  /// Berapa tahun ke belakang yang bisa dipilih.
  static const int _rentangTahun = 5;

  final DateTime _now = DateTime.now();
  late int _tahun = _now.year;
  late int _bulan = _now.month;

  String get _periodeLabel =>
      DateFormat('MMMM yyyy', 'id_ID').format(DateTime(_tahun, _bulan));

  bool get _isBulanBerjalan => _tahun == _now.year && _bulan == _now.month;

  void _onPeriodeChanged(int tahun, int bulan) {
    setState(() {
      _tahun = tahun;
      _bulan = bulan;
    });
    // Hasil/error periode sebelumnya tidak relevan lagi.
    context.read<LaporanCubit>().reset();
  }

  Future<void> _open(String path) async {
    final opened = await AppFileOpenerUtils.openFile(path);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada aplikasi untuk membuka PDF di HP ini.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return BlocConsumer<LaporanCubit, LaporanState>(
      listener: (context, state) {
        if (state is LaporanSuccess) _open(state.filePath);
      },
      builder: (context, state) {
        final isDownloading = state is LaporanDownloading;

        return PopScope(
          canPop: !isDownloading,
          child: Scaffold(
            backgroundColor: palette.background,
            bottomNavigationBar: _DownloadBar(
              state: state,
              periodeLabel: _periodeLabel,
              onDownload: () => context.read<LaporanCubit>().download(
                tahun: _tahun,
                bulan: _bulan,
              ),
            ),
            body: CustomScrollView(
              slivers: [
                const BapendaSliverHeader(
                  title: 'Laporan Kehadiran',
                  showBackButton: true,
                  subtitle: Text('Rekap absensi bulanan (PDF)'),
                  trailing: ThemeToggleButton(),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.list(
                    children: [
                      PeriodePickerCard(
                        tahun: _tahun,
                        bulan: _bulan,
                        now: _now,
                        minTahun: _now.year - _rentangTahun,
                        enabled: !isDownloading,
                        onChanged: _onPeriodeChanged,
                      ),
                      const SizedBox(height: 16),
                      _InfoCard(
                        periodeLabel: _periodeLabel,
                        isBulanBerjalan: _isBulanBerjalan,
                      ),
                      if (state is LaporanFailure) ...[
                        const SizedBox(height: 16),
                        _ErrorBanner(message: state.message),
                      ],
                      if (state is LaporanSuccess) ...[
                        const SizedBox(height: 16),
                        LaporanResultCard(
                          fileName: p.basename(state.filePath),
                          onOpen: () => _open(state.filePath),
                          onShare: () => AppShareUtils.shareFile(
                            state.filePath,
                            text: 'Laporan kehadiran $_periodeLabel',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String periodeLabel;
  final bool isBulanBerjalan;

  const _InfoCard({required this.periodeLabel, required this.isBulanBerjalan});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    Widget point(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: palette.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: palette.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(
            text: 'Periode Terpilih',
            icon: Icons.event_note_rounded,
          ),
          const SizedBox(height: 10),
          Text(
            periodeLabel,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          point(
            Icons.description_outlined,
            'Isi PDF sama dengan cetakan Laporan Kehadiran di web.',
          ),
          if (isBulanBerjalan)
            point(
              Icons.info_outline_rounded,
              'Bulan berjalan: data dihitung sampai hari ini.',
            ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.dangerSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: palette.danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: palette.danger, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bar bawah: tombol unduh, berubah jadi progress saat mengunduh.
class _DownloadBar extends StatelessWidget {
  final LaporanState state;
  final String periodeLabel;
  final VoidCallback onDownload;

  const _DownloadBar({
    required this.state,
    required this.periodeLabel,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = state;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: s is LaporanDownloading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: s.progress,
                        minHeight: 6,
                        backgroundColor: palette.border,
                        color: palette.accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.progress == null
                          ? 'Mengunduh laporan…'
                          : 'Mengunduh laporan ${(s.progress! * 100).round()}%',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                )
              : Button(
                  label: s is LaporanSuccess
                      ? 'Unduh Ulang $periodeLabel'
                      : 'Unduh PDF $periodeLabel',
                  icon: Icons.download_rounded,
                  onPressed: onDownload,
                ),
        ),
      ),
    );
  }
}
