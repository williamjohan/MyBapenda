// lib/presentation/features/survey_baru/screens/survey_permohonan_page.dart
import 'package:bapendacore/domain/entities/cek_reklames/survey_permohonan_baru/survey_permohonan_entity.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_list/survey_list_cubit.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_list/survey_list_state.dart';
import 'package:bapendacore/presentation/features/survey_baru/widgets/survey_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';

class SurveyPermohonanBaruPage extends StatelessWidget {
  const SurveyPermohonanBaruPage({super.key});

  Future<void> _open(BuildContext context, SurveyPermohonanEntity e) async {
    final res = await context.read<SurveyListCubit>().fetchSisi(e);
    if (!context.mounted) return;

    if (res.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(res.error!)));
      return;
    }
    final sisi = res.sisi;
    if (sisi == null) return;
    if (sisi.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Permohonan ini belum punya sisi.')),
        );
      return;
    }

    context.pushNamed(
      AppRoutes.surveyInfo,
      extra: (nomor: e.noPelayanan, key: e.key, sisiList: sisi),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SurveyListCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: cubit.load,
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
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

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                      sliver: SliverList.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final e = items[i];
                          return SurveyCard(
                            data: e,
                            onTap: () => _open(context, e),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Overlay loading saat mengambil detail.
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
    );
  }
}
