// lib/presentation/features/survey_baru/screens/survey_permohonan_page.dart
import 'package:bapendacore/domain/entities/cek_reklames/survey_permohonan_baru/survey_permohonan_entity.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_list/survey_list_cubit.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_list/survey_list_state.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_map/survey_map_cubit.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_map/survey_map_state.dart';
import 'package:bapendacore/presentation/features/survey_baru/widgets/survey_card.dart';
import 'package:bapendacore/presentation/features/survey_baru/widgets/survey_map/survey_map_card.dart';
import 'package:bapendacore/presentation/features/survey_baru/widgets/survey_map/survey_map_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import 'survey_map_page.dart';
import 'survey_start.dart';

class SurveyPermohonanBaruPage extends StatelessWidget {
  const SurveyPermohonanBaruPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SurveyListCubit>();

    // Daftar tugas -> titik di peta (sumber urutan ada di SurveyMapCubit).
    return BlocListener<SurveyListCubit, SurveyListState>(
      listenWhen: (p, c) => p.items != c.items,
      listener: (context, s) => context.read<SurveyMapCubit>().setPoints(
        SurveyMapPoints.build(s.items),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await cubit.load();
                if (context.mounted)
                  context.read<SurveyMapCubit>().locate();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  BapendaSliverHeader(
                    title: 'Survey Permohonan Baru',
                    showBackButton: true,
                    subtitle: Text(
                      'Pilih permohonan yang akan disurvey',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),

                  // Peta mini
                  BlocBuilder<SurveyMapCubit, SurveyMapState>(
                    buildWhen: (p, c) => p.points.isEmpty != c.points.isEmpty,
                    builder: (context, s) {
                      if (s.points.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                      }
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                          child: SurveyMapCard(
                            onStart: (e) => startSurvey(context, e),
                            onOpenMap: () => SurveyMapPage.open(context),
                            onArrange: () =>
                                SurveyMapPage.open(context, arrange: true),
                          ),
                        ),
                      );
                    },
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                      child: TextField(
                        onChanged: cubit.search,
                        style: const TextStyle(fontSize: 13.5),
                        decoration: InputDecoration(
                          hintText: 'Cari nomor pelayanan / wajib pajak',
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
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),

                  BlocBuilder<SurveyListCubit, SurveyListState>(
                    builder: (context, state) {
                      if (state.status == SurveyListStatus.initial ||
                          state.status == SurveyListStatus.loading) {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (state.status == SurveyListStatus.failure &&
                          state.items.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  child: Text(
                                    state.error ?? 'Terjadi kesalahan',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF7B8794),
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: cubit.load,
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Coba lagi'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final items = state.filtered;
                      if (items.isEmpty) {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              'Permohonan tidak ditemukan',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7B8794),
                              ),
                            ),
                          ),
                        );
                      }

                      // Daftar mengikuti urutan yang sama dengan peta.
                      return BlocBuilder<
                        SurveyMapCubit,
                        SurveyMapState
                      >(
                        builder: (context, prio) {
                          final plan = prio.plan;
                          int rank(SurveyPermohonanEntity e) {
                            final n = plan.numberOf(e.key);
                            return n > 0 ? n : 1000; // dilewati di paling bawah
                          }

                          final sorted = [...items]
                            ..sort((a, b) => rank(a).compareTo(rank(b)));

                          return SliverPadding(
                            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                            sliver: SliverList.separated(
                              itemCount: sorted.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, i) {
                                final e = sorted[i];
                                final n = plan.numberOf(e.key);
                                return SurveyCard(
                                  key: ValueKey(e.key),
                                  data: e,
                                  orderNumber: n > 0 ? n : null,
                                  pinned: plan.isPinned(e.key),
                                  skipped: plan.isSkipped(e.key),
                                  onTap: () => startSurvey(context, e),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            BlocSelector<SurveyListCubit, SurveyListState, bool>(
              selector: (s) => s.isOpening,
              builder: (context, opening) {
                if (!opening) return const SizedBox.shrink();
                return const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x66000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
