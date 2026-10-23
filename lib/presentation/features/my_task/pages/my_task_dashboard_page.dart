// lib/presentation/features/my_task/pages/my_task_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mybapenda/core/di/injection.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_entity.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_header_entity.dart';
import 'package:mybapenda/domain/usecases/my_task/my_task_usecase.dart';
import 'package:mybapenda/presentation/features/my_task/cubit/my_task_cubit.dart';
import 'package:mybapenda/presentation/features/my_task/cubit/my_task_state.dart';
import 'package:mybapenda/presentation/features/my_task/widgets/dashboard/my_task_error_state.dart';
import 'package:mybapenda/presentation/shared/widgets/mb_dialog.dart';
import 'package:mybapenda/routes/app_routes.dart';
import '../../../../core/constants/app_colors_new.dart';
import '../../va_qris/widgets/common/va_qris_app_bar.dart';
import '../widgets/dashboard/my_task_summary_header.dart';
import '../widgets/dashboard/task_list_view.dart';
import '../widgets/dashboard/task_status_tab_bar.dart';
import '../widgets/dashboard/task_type_filter_bar.dart';

class MyTaskDashboardPage extends StatelessWidget {
  const MyTaskDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyTaskCubit(useCase: getIt<MyTaskUseCase>())..load(),
      child: const _MyTaskDashboardView(),
    );
  }
}

class _MyTaskDashboardView extends StatefulWidget {
  const _MyTaskDashboardView();

  @override
  State<_MyTaskDashboardView> createState() => _MyTaskDashboardViewState();
}

class _MyTaskDashboardViewState extends State<_MyTaskDashboardView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openDetail(MyTaskEntity task) {
    context.push(AppRoutes.myTaskDetail, extra: task);
  }

  /// Gagal memuat ulang (daftar lama tetap tampil di belakang dialog).
  Future<void> _showRefreshError(String message) async {
    final cubit = context.read<MyTaskCubit>();
    cubit.clearError();

    final retry = await BapendaDialog.showError(
      context,
      title: 'Gagal Memuat Ulang',
      message: message,
      retryLabel: 'Coba Lagi',
    );
    if (retry && mounted) cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyTaskCubit, MyTaskState>(
      listenWhen: (p, c) =>
          c.error != null &&
          p.error != c.error &&
          c.status == MyTaskLoadStatus.success,
      listener: (context, state) => _showRefreshError(state.error!),
      builder: (context, state) {
        final cubit = context.read<MyTaskCubit>();
        final summary = state.summary;

        final active = state.tasksOf(MyTaskStatus.berjalan);
        final done = state.tasksOf(MyTaskStatus.selesai);
        final missed = state.tasksOf(MyTaskStatus.terlewat);

        final failed =
            state.status == MyTaskLoadStatus.failure && state.tasks.isEmpty;

        return Scaffold(
          backgroundColor: AppThemeColors.defaultBackground,
          appBar: const VaQrisAppBar(title: 'My Task'),
          body: Column(
            children: [
              MyTaskSummaryHeader(
                isLoading: state.isLoading,
                activeCount: summary?.aktif ?? 0,
                priorityCount: summary?.mendesak ?? 0,
                doneCount: summary?.selesai ?? 0,
                nearest: summary?.tugasTerdekat,
                onOpenNearest: () {
                  final nearest = summary?.tugasTerdekat;
                  if (nearest != null) _openDetail(nearest);
                },
              ),
              TaskStatusTabBar(
                controller: _tabController,
                activeCount: active.length,
                doneCount: done.length,
                expiredCount: missed.length,
              ),
              TaskTypeFilterBar(
                options: summary?.jenisList ?? const <MyTaskFilterEntity>[],
                selected: state.jenisFilter,
                onChanged: cubit.setJenisFilter,
              ),
              Expanded(
                child: failed
                    ? MyTaskErrorState(
                        message: state.error ?? 'Terjadi kesalahan.',
                        onRetry: cubit.load,
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          TaskListView(
                            tasks: active,
                            isLoading: state.isLoading,
                            groupPriority: true,
                            onRefresh: cubit.refresh,
                            onTapTask: _openDetail,
                            emptyTitle: 'Tidak ada tugas aktif',
                            emptyMessage:
                                'Tugas baru dari supervisor akan muncul di sini. Tarik ke bawah untuk memuat ulang.',
                          ),
                          TaskListView(
                            tasks: done,
                            isLoading: state.isLoading,
                            onRefresh: cubit.refresh,
                            onTapTask: _openDetail,
                            emptyTitle: 'Belum ada tugas selesai',
                            emptyMessage:
                                'Tugas yang sudah dikirim akan tercatat di sini.',
                          ),
                          TaskListView(
                            tasks: missed,
                            isLoading: state.isLoading,
                            onRefresh: cubit.refresh,
                            onTapTask: _openDetail,
                            emptyTitle: 'Tidak ada tugas terlewat',
                            emptyMessage:
                                'Tugas yang melewati batas waktu akan muncul di sini.',
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
