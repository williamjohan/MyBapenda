import 'package:mybapenda/presentation/features/survey_baru/cubit/survey_history/survey_history_list_cubit.dart';
import 'package:mybapenda/presentation/features/survey_baru/cubit/survey_history/survey_history_list_state.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_history/history_filter_bar.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_history/history_format.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_history/survey_history_card.dart';
import 'package:mybapenda/presentation/shared/widgets/bapenda_sliver_header.dart';
import 'package:mybapenda/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SurveyHistoryPage extends StatelessWidget {
  const SurveyHistoryPage({super.key});

  Future<void> _pickRange(BuildContext context) async {
    final cubit = context.read<SurveyHistoryListCubit>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: today,
      initialDateRange: cubit.state.range,
      helpText: 'Pilih rentang tanggal survey',
      saveText: 'Terapkan',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: const Color(0xFFB8680F)),
        ),
        child: child!,
      ),
    );
    if (picked != null) cubit.setCustomRange(picked);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SurveyHistoryListCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: RefreshIndicator(
        onRefresh: cubit.load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            BapendaSliverHeader(
              title: 'Riwayat Survey Permohonan',
              showBackButton: true,
              subtitle: Text(
                'Survey yang sudah selesai dikirim',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),

            // Pencarian
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
                child: TextField(
                  onChanged: cubit.search,
                  style: const TextStyle(fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Cari nomor, NPWPD, pemohon, atau lokasi',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9AA5B1),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF9AA5B1),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            // Filter tanggal
            SliverToBoxAdapter(
              child:
                  BlocBuilder<SurveyHistoryListCubit, SurveyHistoryListState>(
                    buildWhen: (p, c) =>
                        p.preset != c.preset || p.range != c.range,
                    builder: (context, s) => HistoryFilterBar(
                      selected: s.preset,
                      range: s.range,
                      onPreset: cubit.setPreset,
                      onPickCustom: () => _pickRange(context),
                    ),
                  ),
            ),

            BlocBuilder<SurveyHistoryListCubit, SurveyHistoryListState>(
              builder: (context, state) {
                // Memuat
                if (state.status == SurveyHistoryStatus.initial ||
                    (state.status == SurveyHistoryStatus.loading &&
                        state.items.isEmpty)) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // Gagal dan belum ada data
                if (state.status == SurveyHistoryStatus.failure &&
                    state.items.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _Message(
                      icon: Icons.cloud_off_rounded,
                      title: 'Gagal memuat riwayat',
                      subtitle:
                          state.error ?? 'Periksa koneksi lalu coba lagi.',
                      actionLabel: 'Coba lagi',
                      onAction: cubit.load,
                    ),
                  );
                }

                // Kosong pada rentang ini
                if (state.items.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _Message(
                      icon: Icons.history_toggle_off_rounded,
                      title: 'Belum ada survey terkirim',
                      subtitle:
                          'Tidak ada data pada ${HistoryFmt.range(state.range)}.',
                      actionLabel: 'Ubah rentang tanggal',
                      onAction: () => _pickRange(context),
                    ),
                  );
                }

                // Kosong karena pencarian
                final groups = state.groups;
                if (groups.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _Message(
                      icon: Icons.search_off_rounded,
                      title: 'Tidak ditemukan',
                      subtitle: 'Coba kata kunci lain.',
                    ),
                  );
                }

                // Baris: String = judul bulan, entity = kartu.
                final rows = <Object>[
                  for (final g in groups) ...[g.label, ...g.items],
                ];

                return SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                        child: Row(
                          children: [
                            Text(
                              '${state.filtered.length} survey',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F2933),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                HistoryFmt.range(state.range),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7B8794),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
                      sliver: SliverList.builder(
                        itemCount: rows.length,
                        itemBuilder: (context, i) {
                          final row = rows[i];
                          if (row is String) {
                            final count = groups
                                .firstWhere((g) => g.label == row)
                                .items
                                .length;
                            return _MonthHeader(label: row, count: count);
                          }
                          final e = row as dynamic;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SurveyHistoryCard(
                              data: e,
                              onTap: () => context.pushNamed(
                                AppRoutes.surveyHistoryDetail,
                                extra: (key: e.key, nomor: e.noPelayanan),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final String label;
  final int count;
  const _MonthHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFFB8680F),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2933),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF52606D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Message({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3DC),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: const Color(0xFFB8680F)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2933),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: Color(0xFF7B8794),
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFB8680F),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
