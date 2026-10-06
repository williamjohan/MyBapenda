import 'package:bapendacore/domain/entities/my_task/task_location_entity.dart';
import 'package:bapendacore/domain/entities/my_task/task_photo_entity.dart';

/// TODO(tech-debt): SIMULASI. Ganti dengan:
/// - foto  -> AppFilePickerUtils.pickImage() (sudah kompres via
///            AppImageCompressUtils). Kamera langsung + Android Photo Picker
///            untuk galeri. Tambahkan watermark waktu & koordinat.
/// - lokasi-> geolocator (permission, GPS mati, akurasi rendah, deteksi
///            mock location).
abstract final class TaskMediaSimulator {
  static Future<TaskPhotoEntity> pickPhoto(TaskPhotoSource source) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return TaskPhotoEntity(source: source, capturedAt: DateTime.now());
  }

  static Future<TaskLocationEntity> getCurrentLocation() async {
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    return TaskLocationEntity(
      latitude: -7.257472,
      longitude: 112.752088,
      accuracyMeters: 8.6,
      capturedAt: DateTime.now(),
    );
  }
}
