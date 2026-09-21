import 'package:bapendacore/core/constants/app_colors_new.dart';
import 'package:bapendacore/core/di/injection.dart';
import 'package:bapendacore/core/utils/date_format_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';
import '../widgets/history_card.dart';
import '../widgets/history_detail_sheet.dart';
import '../widgets/history_shimmer.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistoryCubit>(
      create: (_) => getIt<HistoryCubit>()..loadHistory(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatefulWidget {
  const _HistoryView();

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<HistoryCubit>().loadMore();
    }
  }

  Future<void> _pickDateRange(BuildContext context, HistoryLoaded state) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: state.tanggalAwal,
        end: state.tanggalAkhir,
      ),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppThemeColors.primary),
        ),
        child: child!,
      ),
    );
    if (range != null && context.mounted) {
      context.read<HistoryCubit>().loadHistory(
        tanggalAwal: range.start,
        tanggalAkhir: range.end,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.defaultBackground,
      body: RefreshIndicator(
        color: AppThemeColors.primary,
        onRefresh: () => context.read<HistoryCubit>().loadHistory(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            BapendaSliverHeader(
              title: 'Riwayat Pemeriksaan',
              showBackButton: true, 
              subtitle: BlocBuilder<HistoryCubit, HistoryState>(
                builder: (context, state) {
                  final count = state is HistoryLoaded ? state.filtered.length : null;
                  return Text(
                    count != null ? '$count reklame ditemukan' : 'Memuat data…',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  );
                },
              ),
            ),
            
            // 🚀 FIX: KEMBALIKAN KOLOM SEARCH DAN FILTER TANGGAL
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _buildSearchAndFilter(context),
              ),
            ),
            BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                if (state is HistoryLoading || state is HistoryInitial) {
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => const HistoryCardShimmer(),
                        childCount: 5,
                      ),
                    ),
                  );
                }

                if (state is HistoryError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorState(
                      message: state.message,
                      onRetry: () => context.read<HistoryCubit>().loadHistory(),
                    ),
                  );
                }

                final loaded = state as HistoryLoaded;
                if (loaded.filtered.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  );
                }

                final itemCount =
                    loaded.filtered.length + (loaded.hasMore ? 1 : 0);

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index >= loaded.filtered.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppThemeColors.primary,
                              ),
                            ),
                          ),
                        );
                      }
                      final item = loaded.filtered[index];
                      return HistoryCard(
                        item: item,
                        onTap: () => showHistoryDetailSheet(context, item),
                      );
                    }, childCount: itemCount),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  

  Widget _buildSearchAndFilter(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppThemeColors.defaultSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppThemeColors.defaultBorder),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => context.read<HistoryCubit>().search(v),
            style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Cari alamat…',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: AppThemeColors.tertiaryText,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppThemeColors.tertiaryText,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state is! HistoryLoaded) return const SizedBox.shrink();
            return Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: AppThemeColors.secondaryText,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDateRange(context, state),
                    child: Text(
                      '${formatTanggalId(state.tanggalAwal)} — ${formatTanggalId(state.tanggalAkhir)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppThemeColors.secondaryText,
                      ),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _pickDateRange(context, state),
                  icon: const Icon(Icons.filter_alt_rounded, size: 16),
                  label: Text(
                    'Ubah',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppThemeColors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppThemeColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_toggle_off_rounded,
                size: 40,
                color: AppThemeColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Belum ada riwayat',
              style: GoogleFonts.lora(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppThemeColors.titleText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Riwayat pemeriksaan reklame pada rentang tanggal ini belum tersedia.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppThemeColors.secondaryText,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppThemeColors.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: AppThemeColors.danger,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppThemeColors.titleText,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
