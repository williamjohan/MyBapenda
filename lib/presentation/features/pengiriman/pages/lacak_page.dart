import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/theme_toggle_button.dart';
import '../cubit/lacak/lacak_cubit.dart';
import '../cubit/lacak/lacak_state.dart';
import '../utils/lacak_ui_helper.dart';
import '../widgets/common/pengiriman_message.dart';
import '../widgets/lacak/lacak_detail_view.dart';

/// Hasil lacak satu berkas (`GET lacak?kode=`), tampil seperti lacak paket:
/// kartu status + peta jejak, riwayat, lalu info. Foto jejak hanya ada bila
/// login punya akses monitoring.
class LacakPage extends StatelessWidget {
  const LacakPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<LacakCubit>();

    return Scaffold(
      backgroundColor: palette.background,
      bottomNavigationBar: BlocBuilder<LacakCubit, LacakState>(
        buildWhen: (a, b) => a.result != b.result,
        builder: (context, state) {
          final result = state.result;
          if (result == null || !result.tugasSaya) {
            return const SizedBox.shrink();
          }
          return _TugasSayaBar(noResi: result.noResi);
        },
      ),
      body: BlocBuilder<LacakCubit, LacakState>(
        builder: (context, state) => RefreshIndicator(
          onRefresh: cubit.refresh,
          color: palette.accent,
          backgroundColor: palette.surface,
          edgeOffset: 120,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const BapendaSliverHeader(
                title: 'Lacak Berkas',
                showBackButton: true,
                trailing: ThemeToggleButton(),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                sliver: SliverToBoxAdapter(child: _body(context, state)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, LacakState state) {
    final result = state.result;
    if (result != null) {
      final data = LacakViewData.fromLacak(result);
      if (data == null) {
        return const PengirimanMessage(
          icon: Icons.search_off_rounded,
          message: 'Data berkas tidak tersedia untuk akun Anda.',
        );
      }
      return LacakDetailView(data: data, rute: state.rute);
    }
    if (state.status == LacakStatus.failure) {
      return PengirimanMessage(
        icon: Icons.search_off_rounded,
        message: state.error ?? 'Berkas tidak ditemukan.',
        actionLabel: 'Coba lagi',
        onAction: context.read<LacakCubit>().refresh,
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

/// Berkas ini tugas login: satu tombol tetap di bawah supaya aksi tugas
/// selalu terjangkau tanpa menggulir.
class _TugasSayaBar extends StatelessWidget {
  final String noResi;
  const _TugasSayaBar({required this.noResi});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        8 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Button(
        label: 'Tugas Anda · Buka Detail Tugas',
        icon: Icons.assignment_ind_outlined,
        height: 42,
        onPressed: () =>
            context.push(AppRoutes.pengirimanDetail, extra: noResi),
      ),
    );
  }
}
