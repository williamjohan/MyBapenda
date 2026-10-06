import 'package:bapendacore/core/utils/app_logger.dart';
import 'package:bapendacore/domain/entities/my_task/task_entity.dart';
import 'package:bapendacore/domain/entities/my_task/task_status.dart';
import 'package:bapendacore/domain/entities/my_task/task_type.dart';
import 'package:bapendacore/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors_new.dart';
import '../../va_qris/widgets/common/va_qris_app_bar.dart';
import '../logic/task_priority_logic.dart';
import '../mock/my_task_mock_data.dart';
import '../widgets/dashboard/my_task_summary_header.dart';
import '../widgets/dashboard/task_list_view.dart';
import '../widgets/dashboard/task_status_tab_bar.dart';
import '../widgets/dashboard/task_type_filter_bar.dart';

/// Dashboard My Task: ringkasan, tab status, filter jenis, daftar tugas.
class MyTaskDashboardPage extends StatefulWidget {
  const MyTaskDashboardPage({super.key});

  @override
  State<MyTaskDashboardPage> createState() => _MyTaskDashboardPageState();
}

class _MyTaskDashboardPageState extends State<MyTaskDashboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // TODO(tech-debt): pindahkan ke MyTaskState (tasks, status, filter).
  List<TaskEntity> _tasks = const [];
  bool _isLoading = true;
  TaskType? _filterType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      // TODO(tech-debt): ganti dengan MyTaskCubit.fetchTasks().
      final tasks = await MyTaskMockData.fetchTasks();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e, st) {
      // TODO(tech-debt): tampilkan state error + tombol "Coba lagi".
      AppLogger.error('Gagal memuat My Task', e, st);
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<TaskEntity> _forStatus(TaskStatus status) =>
      TaskPriorityLogic.forStatus(_tasks, status, type: _filterType);

  void _openDetail(TaskEntity task) {
    context.push(AppRoutes.myTaskDetail, extra: task);
  }

  @override
  Widget build(BuildContext context) {
    final active = _forStatus(TaskStatus.aktif);
    final done = _forStatus(TaskStatus.selesai);
    final expired = _forStatus(TaskStatus.kedaluwarsa);
    final nearest = TaskPriorityLogic.nearestActive(_tasks);

    return Scaffold(
      backgroundColor: AppThemeColors.defaultBackground,
      appBar: const VaQrisAppBar(title: 'My Task'),
      body: Column(
        children: [
          MyTaskSummaryHeader(
            isLoading: _isLoading,
            activeCount: TaskPriorityLogic.countByStatus(_tasks, TaskStatus.aktif),
            priorityCount: TaskPriorityLogic.priorityCount(_tasks),
            doneCount: TaskPriorityLogic.countByStatus(_tasks, TaskStatus.selesai),
            nearest: nearest,
            onOpenNearest: () {
              if (nearest != null) _openDetail(nearest);
            },
          ),
          TaskStatusTabBar(
            controller: _tabController,
            activeCount: active.length,
            doneCount: done.length,
            expiredCount: expired.length,
          ),
          TaskTypeFilterBar(
            selected: _filterType,
            onChanged: (type) => setState(() => _filterType = type),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TaskListView(
                  tasks: active,
                  isLoading: _isLoading,
                  groupPriority: true,
                  onRefresh: _load,
                  onTapTask: _openDetail,
                  emptyTitle: 'Tidak ada tugas aktif',
                  emptyMessage:
                      'Tugas baru dari supervisor akan muncul di sini. Tarik ke bawah untuk memuat ulang.',
                ),
                TaskListView(
                  tasks: done,
                  isLoading: _isLoading,
                  onRefresh: _load,
                  onTapTask: _openDetail,
                  emptyTitle: 'Belum ada tugas selesai',
                  emptyMessage: 'Tugas yang sudah dikirim akan tercatat di sini.',
                ),
                TaskListView(
                  tasks: expired,
                  isLoading: _isLoading,
                  onRefresh: _load,
                  onTapTask: _openDetail,
                  emptyTitle: 'Tidak ada tugas kedaluwarsa',
                  emptyMessage: 'Tugas yang melewati batas waktu akan muncul di sini.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
