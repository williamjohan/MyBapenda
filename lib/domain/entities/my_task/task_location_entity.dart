/// Geotag lokasi petugas saat mengerjakan tugas.
///
/// TODO(tech-debt): DUMMY ENTITY.
class TaskLocationEntity {
  const TaskLocationEntity({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.capturedAt,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime capturedAt;
}
