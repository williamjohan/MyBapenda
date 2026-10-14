enum TaskExtraFieldType { choice, text }

/// Field tambahan yang hanya muncul untuk jenis tugas / kondisi tertentu.
class TaskExtraField {
  const TaskExtraField({
    required this.key,
    required this.label,
    required this.type,
    this.options = const [],
    this.hint,
    this.isRequired = true,
  });

  final String key;
  final String label;
  final TaskExtraFieldType type;

  /// Pilihan untuk [TaskExtraFieldType.choice].
  final List<String> options;
  final String? hint;
  final bool isRequired;
}
