enum TaskPhotoSource { camera, gallery }

/// Foto bukti yang sudah dipilih dari kamera atau galeri.
class TaskPhotoEntity {
  const TaskPhotoEntity({
    required this.source,
    required this.capturedAt,
    required this.path,
  });

  final TaskPhotoSource source;
  final DateTime capturedAt;
  final String path;
}
