import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../../../shared/widgets/theme_toggle_button.dart';
import '../cubit/detail_berkas/detail_berkas_cubit.dart';
import '../cubit/detail_berkas/detail_berkas_state.dart';
import '../utils/lacak_ui_helper.dart';
import '../widgets/aksi/aksi_bar.dart';
import '../widgets/antrean/antrean_indicator.dart';
import '../widgets/common/pengiriman_message.dart';
import '../widgets/lacak/lacak_detail_view.dart';

/// Detail tugas petugas: status (tanpa riwayat; riwayat ada di Lacak),
/// info surat & pengantaran, plus tombol aksi sesuai `aksi[]` dari server.
class DetailBerkasPage extends StatelessWidget {
  final String noResi;

  const DetailBerkasPage({super.key, required this.noResi});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<DetailBerkasCubit>();

    return Scaffold(
      backgroundColor: palette.background,
      bottomNavigationBar: BlocBuilder<DetailBerkasCubit, DetailBerkasState>(
        buildWhen: (p, c) => p.detail != c.detail,
        builder: (context, state) {
          final berkas = state.detail?.berkas;
          if (berkas == null) return const SizedBox.shrink();
          return AksiBar(berkas: berkas, onSelesai: () => cubit.load(noResi));
        },
      ),
      body: AntreanReloadListener(
        onBerubah: () => cubit.load(noResi),
        child: BlocConsumer<DetailBerkasCubit, DetailBerkasState>(
          // Gagal refresh saat data sudah ada: cukup snackbar.
          listenWhen: (p, c) =>
              c.status == DetailBerkasStatus.failure && c.detail != null,
          listener: (context, state) => ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.error ?? 'Gagal memuat.')),
            ),
          builder: (context, state) => RefreshIndicator(
            onRefresh: () => cubit.load(noResi),
            color: palette.accent,
            backgroundColor: palette.surface,
            edgeOffset: 120,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const BapendaSliverHeader(
                  compact: true,
                  title: 'Detail Berkas',
                  showBackButton: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [AntreanIndicator(), ThemeToggleButton()],
                  ),
                ),
                if (state.tglCache != null)
                  SliverToBoxAdapter(
                    child: OfflineBanner(tglCache: state.tglCache!),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  sliver: SliverToBoxAdapter(child: _body(context, state)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, DetailBerkasState state) {
    final detail = state.detail;
    if (detail != null) {
      return LacakDetailView(
        data: LacakViewData.fromDetail(detail),
        tampilkanRiwayat: false,
      );
    }
    if (state.status == DetailBerkasStatus.failure) {
      return PengirimanMessage(
        icon: Icons.wifi_off_rounded,
        message: state.error ?? 'Gagal memuat detail berkas.',
        actionLabel: 'Coba lagi',
        onAction: () => context.read<DetailBerkasCubit>().load(noResi),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: CircularProgressIndicator(color: context.palette.accent),
      ),
    );
  }
}
