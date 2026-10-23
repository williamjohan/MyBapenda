import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mybapenda/core/services/geo_location/i_geo_location_service.dart';
import 'package:mybapenda/domain/entities/my_task/task_location_entity.dart';
import 'package:mybapenda/domain/entities/my_task/task_photo_entity.dart';
import 'package:mybapenda/presentation/features/my_task/logic/task_draft.dart';
import 'my_task_work_state.dart';

class MyTaskWorkCubit extends Cubit<MyTaskWorkState> {
  final IGeoLocationService _geoLocation;

  MyTaskWorkCubit({required IGeoLocationService geoLocation})
    : _geoLocation = geoLocation,
      super(const MyTaskWorkState());

  void setCheckIn(TaskPhotoEntity? photo) => _updateDraft(
    photo == null
        ? state.draft.withCheckIn(null)
        : state.draft.withCheckIn(photo),
  );

  void setPhoto(String slotId, TaskPhotoEntity? photo) =>
      _updateDraft(state.draft.withPhoto(slotId, photo));

  void setExtra(String key, String value) =>
      _updateDraft(state.draft.withExtra(key, value));

  void setNotes(String value) => _updateDraft(state.draft.withNotes(value));

  Future<void> fetchLocation() async {
    if (state.isLocating) return;
    emit(state.copyWith(isLocating: true, locationError: () => null));

    try {
      final result = await _geoLocation.getCurrentPosition();
      if (isClosed) return;

      result.fold(
        (failure) => emit(
          state.copyWith(
            isLocating: false,
            locationError: () => failure.message,
          ),
        ),
        (position) => emit(
          state.copyWith(
            isLocating: false,
            locationError: () => null,
            draft: state.draft.withLocation(
              TaskLocationEntity(
                latitude: position.latitude,
                longitude: position.longitude,
                accuracyMeters: position.akurasiMeter,
                capturedAt: position.time,
              ),
            ),
          ),
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLocating: false,
          locationError: () => 'Lokasi belum bisa diambil. Coba lagi.',
        ),
      );
    }
  }

  void _updateDraft(TaskDraft draft) => emit(state.copyWith(draft: draft));
}
