import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../core/services/geo_location_service.dart';
import '../../../../domain/entities/absensi/riwayat_absensi_entity.dart';
import '../../../shared/widgets/section_label.dart';
import '../cubit/absen/absen_cubit.dart';
import '../cubit/absen/absen_state.dart';
import '../cubit/absensi/absensi_cubit.dart';
import '../cubit/absensi/absensi_state.dart';
import '../logic/rekap_harian_logic.dart';
import '../widgets/absen_bottom_panel.dart';
import '../widgets/absensi_hero.dart';
import '../widgets/hasil_absen_sheet.dart';
import '../widgets/riwayat_day_group.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AbsensiCubit>().loadMore();
    }
  }

  void _onBack() {
    if (context.canPop()) context.pop();
  }

  // ---------------------------------------------------------------------------
  // Reaksi alur absen
  // ---------------------------------------------------------------------------

  Future<void> _onAbsenState(BuildContext context, AbsenState state) async {
    final absenCubit = context.read<AbsenCubit>();

    switch (state) {
      case AbsenSuccess(:final result):
        absenCubit.reset();
        context.read<AbsensiCubit>().onAbsenRecorded(result.ringkasan);
        await showHasilAbsenSheet(context, result);
      case AbsenFailure(:final message):
        absenCubit.reset();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: context.palette.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
      case AbsenLocationRequired(:final reason):
        absenCubit.reset();
        await _showLocationDialog(context, reason, absenCubit);
      case AbsenIdle() || AbsenInProgress():
        break;
    }
  }

  Future<void> _showLocationDialog(
    BuildContext context,
    GeoLocationError reason,
    AbsenCubit absenCubit,
  ) {
    final (title, message, actionLabel, VoidCallback action) = switch (reason) {
      GeoLocationError.serviceDisabled => (
        'Aktifkan GPS',
        'GPS di HP Anda mati. Nyalakan GPS untuk melakukan absen.',
        'Buka Pengaturan',
        absenCubit.openLocationSettings,
      ),
      GeoLocationError.permissionDeniedForever => (
        'Izin Lokasi Ditolak',
        'Izin lokasi diperlukan untuk absen. Aktifkan izin lokasi aplikasi di pengaturan.',
        'Buka Pengaturan',
        absenCubit.openAppSettings,
      ),
      GeoLocationError.permissionDenied || GeoLocationError.timeout => (
        'Izin Lokasi Diperlukan',
        'Absen membutuhkan lokasi Anda untuk memastikan berada di area kantor.',
        'Coba Lagi',
        absenCubit.submit,
      ),
    };

    final palette = context.palette;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: palette.surface,
        title: Text(title, style: TextStyle(color: palette.textPrimary)),
        content: Text(message, style: TextStyle(color: palette.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Batal',
              style: TextStyle(color: palette.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              action();
            },
            child: Text(actionLabel, style: TextStyle(color: palette.accent)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocListener<AbsenCubit, AbsenState>(
        listener: _onAbsenState,
        child: Scaffold(
          backgroundColor: palette.background,
          bottomNavigationBar: _buildBottomPanel(),
          body: BlocBuilder<AbsensiCubit, AbsensiState>(
            builder: (context, state) {
              final today = state.ringkasan?.tanggal ?? DateTime.now();
              final rekap = RekapHarianLogic.hitung(state.riwayat, today);

              return RefreshIndicator(
                onRefresh: context.read<AbsensiCubit>().load,
                color: palette.accent,
                backgroundColor: palette.surface,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildTop(context, state, rekap, today),
                    ),
                    const SliverPadding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                      sliver: SliverToBoxAdapter(
                        child: SectionLabel(
                          text: 'Riwayat Absensi',
                          icon: Icons.history_rounded,
                        ),
                      ),
                    ),
                    ..._buildRiwayat(context, state, today),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Hero gradient: sapaan, jam live, jadwal, ringkasan MASUK/PULANG.
  Widget _buildTop(
    BuildContext context,
    AbsensiState state,
    RekapHarian rekap,
    DateTime today,
  ) {
    final ringkasan = state.ringkasan;

    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: context.palette.headerLinearGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          AbsensiHero(
            nama: ringkasan?.nama,
            tanggal: today,
            masuk: rekap.masuk,
            pulang: rekap.pulang,
            menitTelat: rekap.menitTelat(ringkasan?.jamMasukJadwal),
            menitPulangCepat: rekap.menitPulangCepat(
              ringkasan?.jamPulangJadwal,
            ),
            jamMasukJadwal: ringkasan?.jamMasukJadwal,
            jamPulangJadwal: ringkasan?.jamPulangJadwal,
            isLoading:
                state.ringkasanStatus == AbsensiLoadStatus.loading ||
                state.riwayatStatus == AbsensiLoadStatus.loading,
            onBack: _onBack,
          ),
          if (state.ringkasanError != null && ringkasan == null)
            _HeroError(
              message: state.ringkasanError!,
              onRetry: context.read<AbsensiCubit>().loadRingkasan,
            ),
        ],
      ),
    );
  }

  /// Panel tombol absen di bawah layar.
  Widget _buildBottomPanel() {
    return BlocBuilder<AbsensiCubit, AbsensiState>(
      builder: (context, state) {
        final today = state.ringkasan?.tanggal ?? DateTime.now();
        final sudahMasuk =
            RekapHarianLogic.hitung(state.riwayat, today).masuk != null;

        return BlocBuilder<AbsenCubit, AbsenState>(
          builder: (context, absenState) => AbsenBottomPanel(
            busyStep: absenState is AbsenInProgress ? absenState.step : null,
            sudahMasuk: sudahMasuk,
            onAbsen: context.read<AbsenCubit>().submit,
          ),
        );
      },
    );
  }

  List<Widget> _buildRiwayat(
    BuildContext context,
    AbsensiState state,
    DateTime today,
  ) {
    switch (state.riwayatStatus) {
      case AbsensiLoadStatus.initial:
      case AbsensiLoadStatus.loading:
        return [_groupList(_placeholderGroups(today), today, loading: true)];
      case AbsensiLoadStatus.failure:
        return [
          SliverToBoxAdapter(
            child: _RiwayatMessage(
              icon: Icons.wifi_off_rounded,
              message: state.riwayatError ?? 'Gagal memuat riwayat.',
              actionLabel: 'Coba lagi',
              onAction: context.read<AbsensiCubit>().load,
            ),
          ),
        ];
      case AbsensiLoadStatus.loaded:
        if (state.riwayat.isEmpty) {
          return const [
            SliverToBoxAdapter(
              child: _RiwayatMessage(
                icon: Icons.history_rounded,
                message: 'Belum ada riwayat absensi.',
              ),
            ),
          ];
        }
        return [
          _groupList(RekapHarianLogic.kelompokkanPerHari(state.riwayat), today),
          if (state.isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.palette.accent,
                  ),
                ),
              ),
            ),
        ];
    }
  }

  Widget _groupList(
    List<RiwayatHarian> groups,
    DateTime today, {
    bool loading = false,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: Skeletonizer.sliver(
        enabled: loading,
        child: SliverList.separated(
          itemCount: groups.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, i) =>
              RiwayatDayGroup(group: groups[i], today: today),
        ),
      ),
    );
  }

  static List<RiwayatHarian> _placeholderGroups(DateTime today) => [
    for (var d = 0; d < 2; d++)
      RiwayatHarian(
        tanggal: DateTime(today.year, today.month, today.day - d),
        items: [
          for (final h in [16, 7])
            RiwayatAbsensiEntity(
              tglPresensi: DateTime(today.year, today.month, today.day - d, h),
              jenisDevice: 1,
              namaDevice: 'Ponsel placeholder',
              sumber: SumberAbsensi.online,
              isValid: true,
            ),
        ],
      ),
  ];
}

class _HeroError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _HeroError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Coba lagi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiwayatMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _RiwayatMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        children: [
          Icon(icon, color: palette.textTertiary, size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textSecondary, fontSize: 14),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.accent,
                side: BorderSide(color: palette.borderStrong),
              ),
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
