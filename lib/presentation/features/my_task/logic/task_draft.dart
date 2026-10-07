import 'package:bapendacore/domain/entities/my_task/task_location_entity.dart';
import 'package:bapendacore/domain/entities/my_task/task_photo_entity.dart';

/// Isian form pengerjaan tugas yang sedang berjalan (immutable).
///
/// TODO(tech-debt): pindahkan ke state Cubit, dan simpan lokal sebagai draft
/// agar bisa dilanjutkan saat sinyal hilang.
class TaskDraft {
  const TaskDraft({
    this.checkInPhoto,
    this.location,
    this.photos = const {},
    this.extraValues = const {},
    this.notes = '',
  });

  final TaskPhotoEntity? checkInPhoto;
  final TaskLocationEntity? location;
  final Map<String, TaskPhotoEntity> photos;
  final Map<String, String> extraValues;
  final String notes;

  bool get hasAnyData =>
      checkInPhoto != null ||
      location != null ||
      photos.isNotEmpty ||
      extraValues.isNotEmpty ||
      notes.trim().isNotEmpty;

  TaskDraft _copy({
    TaskPhotoEntity? checkInPhoto,
    bool clearCheckIn = false,
    TaskLocationEntity? location,
    Map<String, TaskPhotoEntity>? photos,
    Map<String, String>? extraValues,
    String? notes,
  }) {
    return TaskDraft(
      checkInPhoto: clearCheckIn ? null : (checkInPhoto ?? this.checkInPhoto),
      location: location ?? this.location,
      photos: photos ?? this.photos,
      extraValues: extraValues ?? this.extraValues,
      notes: notes ?? this.notes,
    );
  }

  TaskDraft withCheckIn(TaskPhotoEntity? photo) =>
      photo == null ? _copy(clearCheckIn: true) : _copy(checkInPhoto: photo);

  TaskDraft withLocation(TaskLocationEntity location) =>
      _copy(location: location);

  TaskDraft withPhoto(String slotId, TaskPhotoEntity? photo) {
    final next = Map<String, TaskPhotoEntity>.of(photos);
    if (photo == null) {
      next.remove(slotId);
    } else {
      next[slotId] = photo;
    }
    return _copy(photos: next);
  }

  TaskDraft withExtra(String key, String value) {
    final next = Map<String, String>.of(extraValues);
    if (value.trim().isEmpty) {
      next.remove(key);
    } else {
      next[key] = value;
    }
    return _copy(extraValues: next);
  }

  TaskDraft withNotes(String value) => _copy(notes: value);
}
