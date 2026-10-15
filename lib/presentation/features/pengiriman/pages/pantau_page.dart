import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../domain/entities/pengiriman/berkas_entity.dart';
import '../../../../routes/app_routes.dart';
import '../cubit/pantau/pantau_cubit.dart';
import '../cubit/pantau/pantau_state.dart';
import '../logic/pantau_logic.dart';
import '../utils/berkas_style.dart';
import '../widgets/antrean/antrean_indicator.dart';
import '../widgets/common/status_tab_bar.dart';
import '../widgets/common/pengiriman_message.dart';
import '../widgets/daftar_tugas/pengiriman_header.dart';
import '../widgets/pantau/pantau_berkas_card.dart';

/// Pantau Surat Pengiriman: berkas milik NIP login langsung tampil,
/// ketuk untuk melihat jejak (gaya lacak paket). No resi di luar daftar
/// tetap bisa dilacak dari kolom cari.
class PantauPage extends StatefulWidget {
  const PantauPage({super.key});

  @override
  State<PantauPage> createState() => _PantauPageState();
}

class _PantauPageState extends State<PantauPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: PantauFilter.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _lacak(BuildContext context, String kode) {
    final k = kode.trim();
    if (k.isEmpty) return;
    context.push(AppRoutes.pengirimanLacakDetail, extra: k);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<PantauCubit>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: palette.background,
        body: AntreanReloadListener(
          onBerubah: cubit.load,
          child: Column(
            children: [
              PengirimanHeader(
                title: 'Pantau Surat Pengiriman',
                hintText: 'Cari no resi / nama WP',
                onBack: () {
                  if (context.canPop()) context.pop();
                },
                onSearch: cubit.search,
                actions: const [AntreanIndicator()],
              ),
              BlocBuilder<PantauCubit, PantauState>(
                buildWhen: (p, c) => p.semua != c.semua || p.status != c.status,
                builder: (context, state) {
                  final jumlah = state.status == PantauStatus.loading
                      ? null
                      : state.jumlah;
                  return StatusTabBar(
                    controller: _tabController,
                    items: [
                      for (final f in PantauFilter.values)
                        (
                          label: f.label,
                          icon: f.icon,
                          jumlah: jumlah?[f],
                          sorot: f == PantauFilter.bermasalah,
                        ),
                    ],
                  );
                },
              ),
              BlocBuilder<PantauCubit, PantauState>(
                buildWhen: (p, c) => p.tglCache != c.tglCache,
                builder: (context, state) => state.tglCache == null
                    ? const SizedBox.shrink()
                    : OfflineBanner(tglCache: state.tglCache!),
              ),
              Expanded(
                child: BlocConsumer<PantauCubit, PantauState>(
                  // Gagal refresh saat daftar sudah ada: cukup snackbar.
                  listenWhen: (p, c) =>
                      c.status == PantauStatus.failure && c.semua.isNotEmpty,
                  listener: (context, state) => ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text(state.error ?? 'Gagal memuat.')),
                    ),
                  // Geser kiri/kanan untuk pindah tab; tiap halaman
                  // menghitung isinya sendiri dari daftar yang sama.
                  builder: (context, state) => TabBarView(
                    controller: _tabController,
                    children: [
                      for (final f in PantauFilter.values)
                        RefreshIndicator(
                          onRefresh: cubit.load,
                          color: palette.accent,
                          backgroundColor: palette.surface,
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              ..._isi(context, state, f),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 24),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _isi(
    BuildContext context,
    PantauState state,
    PantauFilter filter,
  ) {
    final now = DateTime.now();

    if (state.status == PantauStatus.loading) {
      return [_daftar(context, _placeholders, now, loading: true)];
    }
    if (state.status == PantauStatus.failure && state.semua.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: PengirimanMessage(
            icon: Icons.wifi_off_rounded,
            message: state.error ?? 'Gagal memuat daftar berkas.',
            actionLabel: 'Coba lagi',
            onAction: context.read<PantauCubit>().load,
          ),
        ),
      ];
    }

    final items = PantauLogic.filter(state.semua, filter, state.query);
    if (items.isEmpty) {
      final cari = state.query;
      return [
        SliverToBoxAdapter(
          child: PengirimanMessage(
            icon: cari.isEmpty
                ? Icons.inbox_outlined
                : Icons.search_off_rounded,
            message: cari.isEmpty
                ? (filter == PantauFilter.semua
                      ? 'Belum ada berkas yang terhubung dengan akun Anda.'
                      : 'Tidak ada berkas "${filter.label}".')
                : '"$cari" tidak ada di daftar Anda. '
                      'Lacak langsung dengan no resi ini?',
            actionLabel: cari.isEmpty ? null : 'Lacak "$cari"',
            onAction: cari.isEmpty ? null : () => _lacak(context, cari),
          ),
        ),
      ];
    }

    return [_daftar(context, items, now)];
  }

  Widget _daftar(
    BuildContext context,
    List<BerkasEntity> items,
    DateTime now, {
    bool loading = false,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      sliver: Skeletonizer.sliver(
        enabled: loading,
        child: SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, i) => PantauBerkasCard(
            berkas: items[i],
            now: now,
            onTap: loading ? null : () => _lacak(context, items[i].noResi),
          ),
        ),
      ),
    );
  }

  static final _placeholders = List.generate(
    3,
    (i) => BerkasEntity(
      noResi: 'HMB261000000$i',
      jenis: JenisSurat.himbauan,
      jenisNama: 'Himbauan',
      namaWp: 'Nama Wajib Pajak Placeholder',
      alamatTujuan: 'Jl. Placeholder No. 1, Kecamatan, Surabaya',
      status: StatusBerkas.diambil,
      statusNama: 'Diambil',
    ),
  );
}
