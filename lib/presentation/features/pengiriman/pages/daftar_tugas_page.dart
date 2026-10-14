import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../domain/entities/pengiriman/berkas_entity.dart';
import '../../../../routes/app_routes.dart';
import '../cubit/daftar_tugas/daftar_tugas_cubit.dart';
import '../cubit/daftar_tugas/daftar_tugas_state.dart';
import 'aksi/scan_berkas_page.dart';
import '../logic/tugas_tab_logic.dart';
import '../widgets/antrean/antrean_indicator.dart';
import '../widgets/common/pengiriman_message.dart';
import '../widgets/daftar_tugas/berkas_card.dart';
import '../widgets/daftar_tugas/pengiriman_header.dart';
import '../utils/berkas_style.dart';
import '../widgets/common/status_tab_bar.dart';

class DaftarTugasPage extends StatefulWidget {
  const DaftarTugasPage({super.key});

  @override
  State<DaftarTugasPage> createState() => _DaftarTugasPageState();
}

class _DaftarTugasPageState extends State<DaftarTugasPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: TabTugas.values.length, vsync: this)
      ..addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    context.read<DaftarTugasCubit>().changeTab(
      TabTugas.values[_tabController.index],
    );
  }

  void _onBack() {
    if (context.canPop()) context.pop();
  }

  Future<void> _scan(ModeScanBerkas mode) async {
    final cubit = context.read<DaftarTugasCubit>();
    final ok = await context.push<bool>(
      AppRoutes.pengirimanScan,
      extra: (mode: mode, awal: const <String>[]),
    );
    if (ok == true && mounted) cubit.load();
  }

  Future<void> _openBerkas(BerkasEntity berkas) async {
    final cubit = context.read<DaftarTugasCubit>();
    await context.push(AppRoutes.pengirimanDetail, extra: berkas.noResi);
    // Status bisa berubah dari halaman detail (tahap aksi).
    if (!mounted) return;
    cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<DaftarTugasCubit>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: palette.background,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _scan(ModeScanBerkas.ambil),
          backgroundColor: palette.accent,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('Scan Ambil'),
        ),
        body: AntreanReloadListener(
          onBerubah: cubit.load,
          child: Column(
            children: [
              PengirimanHeader(
                onBack: _onBack,
                onSearch: cubit.search,
                actions: [
                  const AntreanIndicator(),
                  IconButton(
                    tooltip: 'Kembalikan surat ke kantor',
                    onPressed: () => _scan(ModeScanBerkas.kembalikan),
                    icon: const Icon(
                      Icons.assignment_return_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              BlocBuilder<DaftarTugasCubit, DaftarTugasState>(
                buildWhen: (p, c) => p.semua != c.semua || p.status != c.status,
                builder: (context, state) => StatusTabBar(
                  controller: _tabController,
                  items: [
                    for (final t in TabTugas.values)
                      (
                        label: t.label,
                        icon: t.icon,
                        jumlah: state.jumlah?[t],
                        sorot: t.perluTindakan,
                      ),
                  ],
                ),
              ),
              BlocBuilder<DaftarTugasCubit, DaftarTugasState>(
                buildWhen: (p, c) => p.tglCache != c.tglCache,
                builder: (context, state) => state.tglCache == null
                    ? const SizedBox.shrink()
                    : OfflineBanner(tglCache: state.tglCache!),
              ),
              Expanded(
                child: BlocConsumer<DaftarTugasCubit, DaftarTugasState>(
                  // Gagal refresh saat daftar sudah ada: cukup snackbar.
                  listenWhen: (p, c) =>
                      c.status == DaftarTugasStatus.failure &&
                      c.semua.isNotEmpty,
                  listener: (context, state) => ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text(state.error ?? 'Gagal memuat.')),
                    ),
                  builder: (context, state) => RefreshIndicator(
                    onRefresh: cubit.load,
                    color: palette.accent,
                    backgroundColor: palette.surface,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        ..._buildList(context, state),
                        // Ruang untuk tombol Scan Ambil.
                        const SliverToBoxAdapter(child: SizedBox(height: 96)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildList(BuildContext context, DaftarTugasState state) {
    final now = DateTime.now();

    switch (state.status) {
      case DaftarTugasStatus.initial:
      case DaftarTugasStatus.loading:
        return [_cardList(_placeholders, now, loading: true)];
      case DaftarTugasStatus.failure when state.semua.isEmpty:
        return [
          SliverToBoxAdapter(
            child: PengirimanMessage(
              icon: Icons.wifi_off_rounded,
              message: state.error ?? 'Gagal memuat daftar tugas.',
              actionLabel: 'Coba lagi',
              onAction: context.read<DaftarTugasCubit>().load,
            ),
          ),
        ];
      case DaftarTugasStatus.failure:
      case DaftarTugasStatus.loaded:
        if (state.items.isEmpty) {
          return [
            SliverToBoxAdapter(
              child: PengirimanMessage(
                icon: state.query.isEmpty
                    ? Icons.inbox_outlined
                    : Icons.search_off_rounded,
                message: state.query.isEmpty
                    ? 'Belum ada berkas di tab ini.'
                    : '"${state.query}" tidak ditemukan di tab ini.',
              ),
            ),
          ];
        }
        return [_cardList(state.items, now)];
    }
  }

  Widget _cardList(
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
          itemBuilder: (_, i) => BerkasCard(
            berkas: items[i],
            now: now,
            onTap: loading ? null : () => _openBerkas(items[i]),
          ),
        ),
      ),
    );
  }

  static final _placeholders = List.generate(
    4,
    (i) => BerkasEntity(
      noResi: 'BPD-2026-00000$i',
      jenis: JenisSurat.himbauan,
      jenisNama: 'Himbauan',
      namaWp: 'Nama Wajib Pajak Placeholder',
      alamatTujuan: 'Jl. Placeholder No. 1, Kecamatan, Surabaya',
      status: StatusBerkas.ditugaskan,
      statusNama: 'Ditugaskan',
    ),
  );
}
