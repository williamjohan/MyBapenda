import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../domain/entities/pengiriman/lacak_entity.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../../../shared/widgets/theme_toggle_button.dart';
import '../cubit/lacak/lacak_cubit.dart';
import '../cubit/lacak/lacak_state.dart';
import '../logic/lacak_view_data.dart';
import '../widgets/common/pengiriman_message.dart';
import '../widgets/lacak/lacak_detail_view.dart';

/// Hasil lacak satu berkas (`GET lacak?kode=`), tampil seperti lacak paket.
/// Foto jejak hanya ada bila login punya akses monitoring.
class LacakPage extends StatelessWidget {
  const LacakPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<LacakCubit>();

    return Scaffold(
      backgroundColor: palette.background,
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
      return LacakDetailView(
        data: data,
        header: result.tugasSaya ? _TugasSayaBanner(result: result) : null,
      );
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

/// Berkas ini tugas login: tawarkan buka detail tugas (tempat tombol aksi).
class _TugasSayaBanner extends StatelessWidget {
  final LacakResultEntity result;
  const _TugasSayaBanner({required this.result});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: palette.accentSoft,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            context.push(AppRoutes.pengirimanDetail, extra: result.noResi),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.assignment_ind_outlined, color: palette.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Berkas ini tugas Anda. Buka detail tugas.',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: palette.accent),
            ],
          ),
        ),
      ),
    );
  }
}
