// lib/presentation/features/my_task/pages/my_task_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mybapenda/core/di/injection.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_entity.dart';
import 'package:mybapenda/domain/usecases/my_task/my_task_usecase.dart';
import 'package:mybapenda/presentation/features/my_task/cubit/my_task_detail_cubit.dart';
import 'package:mybapenda/presentation/features/my_task/cubit/my_task_detail_state.dart';
import 'package:mybapenda/presentation/features/my_task/widgets/detail/task_locked_banner.dart';
import 'package:mybapenda/routes/app_routes.dart';
import '../../../../core/constants/app_colors_new.dart';
import '../../va_qris/widgets/common/va_qris_app_bar.dart';
import '../../va_qris/widgets/common/va_qris_primary_button.dart';
import '../widgets/detail/task_completed_banner.dart';
import '../widgets/detail/task_detail_header.dart';
import '../widgets/detail/task_info_card.dart';

class MyTaskDetailPage extends StatelessWidget {
  const MyTaskDetailPage({super.key, required this.task});

  final MyTaskEntity task;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MyTaskDetailCubit(useCase: getIt<MyTaskUseCase>(), task: task)
            ..load(),
      child: _MyTaskDetailView(task: task),
    );
  }
}

class _MyTaskDetailView extends StatelessWidget {
  const _MyTaskDetailView({required this.task});

  final MyTaskEntity task;

  @override
  Widget build(BuildContext context) {
    final isRunning = task.statusType == MyTaskStatus.berjalan;
    final canStart = isRunning && task.bisaDikerjakan;
    final lockReason = task.keterangan;

    return Scaffold(
      backgroundColor: AppThemeColors.defaultBackground,
      appBar: const VaQrisAppBar(title: 'Detail tugas'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TaskDetailHeader(task: task),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  if (task.isSelesai) ...[
                    // API belum mengirim waktu selesai.
                    const TaskCompletedBanner(completedAt: null),
                    const SizedBox(height: 12),
                  ],
                  if (isRunning && !task.bisaDikerjakan) ...[
                    TaskLockedBanner(message: lockReason),
                    const SizedBox(height: 12),
                  ],
                  BlocBuilder<MyTaskDetailCubit, MyTaskDetailState>(
                    builder: (context, state) {
                      final detail = state.detail;
                      return switch (state.status) {
                        MyTaskDetailStatus.loading => const TaskInfoSkeleton(),
                        MyTaskDetailStatus.failure => TaskInfoError(
                          message: state.error ?? 'Gagal memuat detail tugas.',
                          onRetry: context.read<MyTaskDetailCubit>().load,
                        ),
                        MyTaskDetailStatus.success when detail != null =>
                          TaskInfoCard(task: task, detail: detail),
                        _ => const TaskInfoSkeleton(),
                      };
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: canStart
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: AppThemeColors.defaultSurface,
                border: Border(
                  top: BorderSide(color: AppThemeColors.subtleBorder),
                ),
              ),
              child: SafeArea(
                top: false,
                child: VaQrisPrimaryButton(
                  label: 'Mulai kerjakan',
                  icon: Icons.play_arrow_rounded,
                  // TODO(my-task-work): halaman kerja masih memakai TaskEntity
                  // lama; sesuaikan ke MyTaskEntity di tahap berikutnya.
                  onPressed: () =>
                      context.push(AppRoutes.myTaskWork, extra: task),
                ),
              ),
            )
          : null,
    );
  }
}
