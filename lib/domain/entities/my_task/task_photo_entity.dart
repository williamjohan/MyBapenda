enum TaskPhotoSource { camera, gallery }

/// Foto bukti. [path] null berarti foto SIMULASI (belum tersambung kamera).
///
/// TODO(tech-debt): DUMMY ENTITY.
class TaskPhotoEntity {
  const TaskPhotoEntity({
    required this.source,
    required this.capturedAt,
    this.path,
  });

  final TaskPhotoSource source;
  final DateTime capturedAt;
  final String? path;

  bool get isSimulated => path == null;
}
