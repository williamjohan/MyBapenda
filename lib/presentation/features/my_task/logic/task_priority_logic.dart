import 'package:mybapenda/domain/entities/my_task/my_task_entity.dart';

enum TaskUrgency { overdue, urgent, soon, normal }

abstract final class TaskPriorityLogic {
  static const Duration urgentWindow = Duration(hours: 24);
  static const Duration soonWindow = Duration(hours: 72);

  static final int _urgentDays = urgentWindow.inDays;
  static final int _soonDays = soonWindow.inDays;

  static TaskUrgency urgencyOf(MyTaskEntity task) {
    if (task.statusType != MyTaskStatus.berjalan) return TaskUrgency.normal;
    final days = task.sisaHari;
    if (days < 0) return TaskUrgency.overdue;
    if (days <= _urgentDays) return TaskUrgency.urgent;
    if (days <= _soonDays) return TaskUrgency.soon;
    return TaskUrgency.normal;
  }

  static bool isPriority(MyTaskEntity task) {
    if (!task.bisaDikerjakan) return false;
    final u = urgencyOf(task);
    return u == TaskUrgency.overdue || u == TaskUrgency.urgent;
  }

  static int priorityCount(List<MyTaskEntity> tasks) =>
      tasks.where(isPriority).length;

  static int countByStatus(List<MyTaskEntity> tasks, MyTaskStatus status) =>
      tasks.where((t) => t.statusType == status).length;

  static MyTaskEntity? nearestActive(List<MyTaskEntity> tasks) {
    final active = forStatus(
      tasks,
      MyTaskStatus.berjalan,
    ).where((t) => t.bisaDikerjakan);
    return active.isEmpty ? null : active.first;
  }

  static List<MyTaskEntity> forStatus(
    List<MyTaskEntity> tasks,
    MyTaskStatus status, {
    String? jenis,
  }) {
    final list = tasks
        .where(
          (t) =>
              t.statusType == status &&
              (jenis == null || t.jenis.toLowerCase() == jenis),
        )
        .toList();

    switch (status) {
      case MyTaskStatus.berjalan:
        list.sort(_byUrgency);
      case MyTaskStatus.selesai:
      case MyTaskStatus.terlewat:
        list.sort((a, b) => _exp(b).compareTo(_exp(a)));
      case MyTaskStatus.unknown:
        break;
    }
    return list;
  }

  static int _byUrgency(MyTaskEntity a, MyTaskEntity b) {
    if (a.bisaDikerjakan != b.bisaDikerjakan) return a.bisaDikerjakan ? -1 : 1;
    final byDays = a.sisaHari.compareTo(b.sisaHari);
    if (byDays != 0) return byDays;
    final byNumber = a.noSkpd.compareTo(b.noSkpd);
    return byNumber != 0 ? byNumber : a.keyTask.compareTo(b.keyTask);
  }

  static DateTime _exp(MyTaskEntity t) =>
      t.expTask ?? DateTime.fromMillisecondsSinceEpoch(0);
}
