import 'package:bapendacore/domain/entities/my_task/task_entity.dart';
import 'package:bapendacore/domain/entities/my_task/task_status.dart';
import 'package:bapendacore/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors_new.dart';
import '../../va_qris/widgets/common/va_qris_app_bar.dart';
import '../../va_qris/widgets/common/va_qris_primary_button.dart';
import '../widgets/detail/task_completed_banner.dart';
import '../widgets/detail/task_detail_header.dart';
import '../widgets/detail/task_info_card.dart';
import '../widgets/detail/task_instruction_card.dart';

/// Detail tugas + tombol "Mulai kerjakan" untuk tugas aktif.
class MyTaskDetailPage extends StatelessWidget {
  const MyTaskDetailPage({super.key, required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    final isActive = task.status == TaskStatus.aktif;

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
                  if (task.status == TaskStatus.selesai) ...[
                    TaskCompletedBanner(completedAt: task.completedAt),
                    const SizedBox(height: 12),
                  ],
                  if (task.instruction != null) ...[
                    TaskInstructionCard(instruction: task.instruction!),
                    const SizedBox(height: 12),
                  ],
                  TaskInfoCard(task: task),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isActive
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
                  onPressed: () =>
                      context.push(AppRoutes.myTaskWork, extra: task),
                ),
              ),
            )
          : null,
    );
  }
}
