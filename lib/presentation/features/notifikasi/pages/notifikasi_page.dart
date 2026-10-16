import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../domain/entities/notifikasi/notifikasi_entity.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../../../shared/widgets/theme_toggle_button.dart';
import '../../pengiriman/widgets/common/pengiriman_message.dart';
import '../cubit/notifikasi_cubit.dart';
import '../cubit/notifikasi_state.dart';
import '../widgets/notifikasi_tile.dart';

/// Kotak masuk notifikasi petugas.
class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<NotifikasiCubit>();

    return Scaffold(
      backgroundColor: palette.background,
      body: BlocConsumer<NotifikasiCubit, NotifikasiState>(
        listenWhen: (a, b) =>
            b.pesan != null &&
            b.pesan != a.pesan &&
            b.status == NotifikasiStatus.success,
        listener: (context, state) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.pesan!))),
        builder: (context, state) {
          return NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.extentAfter < 300) cubit.muatLagi();
              return false;
            },
            child: RefreshIndicator(
              onRefresh: cubit.load,
              edgeOffset: 110,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  BapendaSliverHeader(
                    compact: true,
                    title: 'Notifikasi',
                    showBackButton: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state.adaBelumDibaca)
                          IconButton(
                            tooltip: 'Tandai semua dibaca',
                            onPressed: cubit.bacaSemua,
                            icon: const Icon(
                              Icons.done_all_rounded,
                              color: Colors.white,
                            ),
                          ),
                        const ThemeToggleButton(),
                      ],
                    ),
                  ),
                  ..._isi(context, state, cubit),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _isi(
    BuildContext context,
    NotifikasiState state,
    NotifikasiCubit cubit,
  ) {
    if (state.items.isEmpty) {
      final Widget isi = switch (state.status) {
        NotifikasiStatus.initial || NotifikasiStatus.loading => const Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator()),
        ),
        NotifikasiStatus.failure => PengirimanMessage(
          icon: Icons.cloud_off_rounded,
          message: state.pesan ?? 'Gagal memuat notifikasi.',
          actionLabel: 'Coba Lagi',
          onAction: cubit.load,
        ),
        NotifikasiStatus.success => const PengirimanMessage(
          icon: Icons.notifications_none_rounded,
          message: 'Belum ada notifikasi.',
        ),
      };
      return [SliverToBoxAdapter(child: isi)];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        sliver: SliverList.separated(
          itemCount: state.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final n = state.items[i];
            return NotifikasiTile(
              notif: n,
              onTap: () => _buka(context, cubit, n),
            );
          },
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: state.memuatLagi
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink(),
        ),
      ),
    ];
  }

  void _buka(BuildContext context, NotifikasiCubit cubit, NotifikasiEntity n) {
    cubit.baca(n);
    final noResi = n.noResiBerkas;
    if (noResi != null) {
      context.push(AppRoutes.pengirimanDetail, extra: noResi);
    }
  }
}
