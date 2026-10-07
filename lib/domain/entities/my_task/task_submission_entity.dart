import 'task_location_entity.dart';
import 'task_photo_entity.dart';

/// Hasil pengerjaan tugas yang dikirim ke BE.
///
/// TODO(tech-debt): DUMMY ENTITY. Bentuk multipart/upload ditentukan saat
/// data layer dibuat.
class TaskSubmissionEntity {
  const TaskSubmissionEntity({
    required this.taskId,
    required this.submittedAt,
    required this.photos,
    required this.extraValues,
    required this.notes,
    this.checkInPhoto,
    this.location,
  });

  final String taskId;
  final DateTime submittedAt;
  final TaskPhotoEntity? checkInPhoto;
  final TaskLocationEntity? location;

  /// Key = id slot foto (mis. 'sebelum', 'sesudah', 'surat').
  final Map<String, TaskPhotoEntity> photos;

  /// Key = key field tambahan di TaskFormConfig.
  final Map<String, String> extraValues;
  final String notes;
}
