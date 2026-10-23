// lib/presentation/features/my_task/cubit/my_task_checkin/my_task_checkin_cubit.dart
//
// Kirim hasil pengerjaan tugas ke POST /api/mytask/checkin.
// State = true selama sedang mengirim (pola yang sama dengan SurveySubmitCubit).
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mybapenda/core/utils/app_logger.dart';
import 'package:mybapenda/domain/entities/coordinate_entity.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_checkin_entity.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_entity.dart';
import 'package:mybapenda/domain/entities/my_task/task_photo_entity.dart';
import 'package:mybapenda/domain/repositories/geocoding/geocoding_repository.dart';
import 'package:mybapenda/domain/usecases/my_task/my_task_usecase.dart';
import 'package:mybapenda/presentation/features/my_task/config/task_photo_slot.dart';
import 'package:mybapenda/presentation/features/my_task/logic/task_draft.dart';

typedef PetugasLoader = Future<TaskPetugasEntity?> Function();

class MyTaskCheckinCubit extends Cubit<bool> {
  final MyTaskUseCase _useCase;
  final IGeocodingRepository _geocoding;

  final PetugasLoader _loadPetugas;

  MyTaskCheckinCubit({
    required MyTaskUseCase useCase,
    required IGeocodingRepository geocoding,
    required PetugasLoader loadPetugas,
  }) : _useCase = useCase,
       _geocoding = geocoding,
       _loadPetugas = loadPetugas,
       super(false);

  /// [slots] = `TaskFormConfig.photoSlots`, dipakai untuk menentukan foto mana
  /// "sebelum" dan mana "sesudah" (lihat [_assignPhotos]).
  Future<({bool ok, String? error})> submit({
    required MyTaskEntity task,
    required TaskDraft draft,
    required List<TaskPhotoSlot> slots,
  }) async {
    if (state) return (ok: false, error: null); // sedang mengirim
    emit(true);

    try {
      // [BARU] Petugas diambil dari profil yang login (sama seperti survey).
      final petugas = await _loadPetugas();
      if (petugas == null) {
        return (
          ok: false,
          error: 'Data petugas tidak ditemukan. Coba login ulang.',
        );
      }

      final request = await _buildRequest(task, draft, slots, petugas);
      final result = await _useCase.checkin(request);
      if (isClosed) return (ok: false, error: null);

      return result.fold<({bool ok, String? error})>(
        (failure) => (ok: false, error: failure.message),
        (_) => (ok: true, error: null),
      );
    } catch (e, st) {
      AppLogger.error('Gagal menyiapkan hasil tugas ${task.noSkpd}', e, st);
      return (
        ok: false,
        error: 'Hasil tugas belum bisa disiapkan. Periksa foto lalu coba lagi.',
      );
    } finally {
      if (!isClosed) emit(false);
    }
  }

  // ---- Susun request dari isian form ----

  Future<MyTaskCheckinRequestEntity> _buildRequest(
    MyTaskEntity task,
    TaskDraft draft,
    List<TaskPhotoSlot> slots,
    TaskPetugasEntity petugas,
  ) async {
    final loc = draft.location;
    final alamat = loc == null
        ? null
        : await _alamatDari(loc.latitude, loc.longitude);

    TaskCheckinPhotoEntity? photo(TaskPhotoEntity? p) {
      final path = p?.path;
      if (path == null) return null;
      return TaskCheckinPhotoEntity(
        path: path,
        latitude: loc?.latitude,
        longitude: loc?.longitude,
        alamat: alamat,
      );
    }

    final (sebelum, sesudah) = _assignPhotos(draft, slots);

    return MyTaskCheckinRequestEntity(
      jenis: task.jenis,
      key: task.keyTask,
      keterangan: draft.notes.trim(),
      petugas: [petugas],
      fotoCheckin: photo(draft.checkInPhoto),
      fotoSebelum: photo(sebelum),
      fotoSesudah: photo(sesudah),
    );
  }

  (TaskPhotoEntity?, TaskPhotoEntity?) _assignPhotos(
    TaskDraft draft,
    List<TaskPhotoSlot> slots,
  ) {
    final ordered = [for (final s in slots) draft.photos[s.id]];
    if (ordered.length >= 2) return (ordered[0], ordered[1]);
    if (ordered.length == 1) return (null, ordered[0]);
    return (null, null);
  }

  Future<String> _alamatDari(double lat, double lng) async {
    try {
      final result = await _geocoding
          .getAddressFromCoordinate(
            CoordinateEntity(latitude: lat, longitude: lng),
          )
          .timeout(const Duration(seconds: 8));
      return result.fold((_) => '-', (a) => a);
    } catch (_) {
      return '-';
    }
  }
}
