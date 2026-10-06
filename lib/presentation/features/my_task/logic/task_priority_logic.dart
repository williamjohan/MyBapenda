import 'package:bapendacore/domain/entities/my_task/task_entity.dart';
import 'package:bapendacore/domain/entities/my_task/task_status.dart';
import 'package:bapendacore/domain/entities/my_task/task_type.dart';

enum TaskUrgency { overdue, urgent, soon, normal }

/// Aturan penentuan tugas yang di-highlight di dashboard.
///
/// TODO(tech-debt): sementara berdasar status + deadline. Ganti/atur ulang
/// setelah kontrak payload BE (mis. field prioritas dari BE) disepakati.
/// Murni Dart, siap dipindah ke Cubit/UseCase.
abstract final class TaskPriorityLogic {
  static const Duration urgentWindow = Duration(hours: 24);
  static const Duration soonWindow = Duration(hours: 72);

  static TaskUrgency urgencyOf(TaskEntity task, {DateTime? now}) {
    if (task.status != TaskStatus.aktif) return TaskUrgency.normal;
    final remaining = task.deadline.difference(now ?? DateTime.now());
    if (remaining.isNegative) return TaskUrgency.overdue;
    if (remaining <= urgentWindow) return TaskUrgency.urgent;
    if (remaining <= soonWindow) return TaskUrgency.soon;
    return TaskUrgency.normal;
  }

  /// Mendesak atau terlambat -> perlu dilihat pertama.
  static bool isPriority(TaskEntity task, {DateTime? now}) {
    final u = urgencyOf(task, now: now);
    return u == TaskUrgency.overdue || u == TaskUrgency.urgent;
  }

  static int priorityCount(List<TaskEntity> tasks) =>
      tasks.where(isPriority).length;

  static int countByStatus(List<TaskEntity> tasks, TaskStatus status) =>
      tasks.where((t) => t.status == status).length;

  /// Tugas aktif dengan deadline paling dekat.
  static TaskEntity? nearestActive(List<TaskEntity> tasks) {
    final active = forStatus(tasks, TaskStatus.aktif);
    return active.isEmpty ? null : active.first;
  }

  static List<TaskEntity> forStatus(
    List<TaskEntity> tasks,
    TaskStatus status, {
    TaskType? type,
  }) {
    final list = tasks
        .where((t) => t.status == status && (type == null || t.type == type))
        .toList();

    switch (status) {
      case TaskStatus.aktif:
        list.sort((a, b) => a.deadline.compareTo(b.deadline));
      case TaskStatus.selesai:
        list.sort(
          (a, b) => (b.completedAt ?? b.deadline).compareTo(
            a.completedAt ?? a.deadline,
          ),
        );
      case TaskStatus.kedaluwarsa:
        list.sort((a, b) => b.deadline.compareTo(a.deadline));
    }
    return list;
  }
}
