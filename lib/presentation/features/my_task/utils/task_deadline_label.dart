import 'package:bapendacore/core/utils/date_format_id.dart';
import 'package:bapendacore/domain/entities/my_task/task_entity.dart';
import 'package:bapendacore/domain/entities/my_task/task_status.dart';

String _duration(Duration d) {
  final a = d.abs();
  if (a.inDays >= 1) return '${a.inDays} hari';
  if (a.inHours >= 1) return '${a.inHours} jam';
  final m = a.inMinutes < 1 ? 1 : a.inMinutes;
  return '$m menit';
}

/// Label waktu singkat untuk card: "Sisa 5 jam", "Terlambat 1 hari", dst.
String taskDeadlineLabel(TaskEntity task, {DateTime? now}) {
  switch (task.status) {
    case TaskStatus.aktif:
      final remaining = task.deadline.difference(now ?? DateTime.now());
      return remaining.isNegative
          ? 'Terlambat ${_duration(remaining)}'
          : 'Sisa ${_duration(remaining)}';
    case TaskStatus.selesai:
      final done = task.completedAt;
      return done == null
          ? 'Selesai'
          : 'Selesai ${formatTanggalId(done)}, ${formatJamId(done)}';
    case TaskStatus.kedaluwarsa:
      return 'Berakhir ${formatTanggalId(task.deadline)}';
  }
}

/// "6 Okt 2026, 17:00"
String taskDeadlineDateTime(TaskEntity task) =>
    '${formatTanggalId(task.deadline)}, ${formatJamId(task.deadline)}';
