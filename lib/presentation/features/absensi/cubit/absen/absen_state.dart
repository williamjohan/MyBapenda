import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../domain/entities/absensi/absen_entity.dart';

part 'absen_state.freezed.dart';

enum AbsenStep { locating, submitting }

@freezed
class AbsenState with _$AbsenState {
  /// State awal saat idle
  const factory AbsenState.idle() = _Idle;

  /// Saat proses loading (mencari lokasi atau submit API)
  const factory AbsenState.inProgress(AbsenStep step) = _InProgress;

  /// Saat absen berhasil
  const factory AbsenState.success(AbsenResultEntity result) = _Success;

  /// GPS mati / izin lokasi ditolak → layar menampilkan dialog pengaturan.
  /// (Telah diubah menjadi String agar sinkron dengan PermissionFailure)
  const factory AbsenState.locationRequired(String message) = _LocationRequired;

  /// Pesan error umum atau dari API
  const factory AbsenState.failure(String message) = _Failure;
}