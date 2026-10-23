import 'package:mybapenda/core/utils/date_format_id.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_entity.dart';

String taskDeadlineLabel(MyTaskEntity task) {
  switch (task.statusType) {
    case MyTaskStatus.berjalan:
    case MyTaskStatus.unknown:
      final days = task.sisaHari;
      if (days < 0) return 'Terlambat ${-days} hari';
      if (days == 0) return 'Batas hari ini';
      return 'Sisa $days hari';
    case MyTaskStatus.selesai:
      return 'Selesai';
    case MyTaskStatus.terlewat:
      final exp = task.expTask;
      return exp == null ? 'Terlewat' : 'Berakhir ${formatTanggalId(exp)}';
  }
}

String taskDeadlineDateTime(MyTaskEntity task) => taskDateLabel(task.expTask);

String taskDateLabel(DateTime? date) =>
    date == null ? '-' : formatTanggalId(date);
