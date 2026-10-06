import '../config/task_form_config.dart';
import 'task_draft.dart';

class TaskFormProgress {
  const TaskFormProgress({required this.total, required this.missing});

  final int total;

  /// Nama langkah yang belum lengkap, urut sesuai form.
  final List<String> missing;

  int get done => total - missing.length;
  bool get isComplete => missing.isEmpty;
  double get fraction => total == 0 ? 1 : done / total;
}

/// Menilai kelengkapan form berdasarkan [TaskFormConfig]. Murni Dart.
abstract final class TaskValidationLogic {
  static TaskFormProgress evaluate(TaskFormConfig config, TaskDraft draft) {
    final missing = <String>[];
    var total = 0;

    void check(String label, bool isDone) {
      total++;
      if (!isDone) missing.add(label);
    }

    if (config.requireCheckIn) {
      check('Selfie check-in', draft.checkInPhoto != null);
    }
    if (config.requireLocation) {
      check('Lokasi', draft.location != null);
    }
    for (final slot in config.photoSlots) {
      check(slot.label, draft.photos.containsKey(slot.id));
    }
    for (final field in config.extraFields) {
      if (!field.isRequired) {
        continue;
      }
      check(field.label, (draft.extraValues[field.key] ?? '').trim().isNotEmpty);
    }
    if (config.notesRequired) {
      final min = config.notesMinLength < 1 ? 1 : config.notesMinLength;
      check('Keterangan', draft.notes.trim().length >= min);
    }

    return TaskFormProgress(total: total, missing: missing);
  }
}
