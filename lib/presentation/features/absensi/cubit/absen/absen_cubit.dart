import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/services/geo_location/i_geo_location_service.dart';
import '../../../../../core/services/permission/i_permission_service.dart';
import '../../../../../domain/entities/absensi/absen_entity.dart';
import '../../../../../domain/usecases/absensi/absensi_usecase.dart';
import 'absen_state.dart';

@injectable
class AbsenCubit extends Cubit<AbsenState> {
  final AbsensiUseCase _useCase;
  final IGeoLocationService _locationService;
  final IPermissionService _permissionService;

  AbsenCubit(
    this._useCase,
    this._locationService,
    this._permissionService,
  ) : super(const AbsenState.idle()); 

  /// Dipanggil setelah tombol ditahan sampai penuh.
  Future<void> submit() async {
    final isProcessing = state.maybeWhen(
      inProgress: (_) => true,
      orElse: () => false,
    );
    if (isProcessing) return;

    emit(const AbsenState.inProgress(AbsenStep.locating));
    
    final locationResult = await _locationService.getCurrentPosition();

    if (isClosed) return;

    await locationResult.fold(
      (failure) async {
        if (failure is PermissionFailure) {
          emit(AbsenState.locationRequired(failure.message));
        } else {
          emit(AbsenState.failure(failure.message));
        }
      },
      (position) async {
        emit(const AbsenState.inProgress(AbsenStep.submitting));
        
        // 3. Kirim ke Server. 
        final result = await _useCase.absen(
          AbsenParams(
            latitude: position.latitude,
            longitude: position.longitude,
            akurasiMeter: position.akurasiMeter,
            isMockLocation: false, 
          ),
        );
        
        if (isClosed) return;
        
        result.fold(
          (failure) => emit(AbsenState.failure(failure.message)),
          (absen) => emit(AbsenState.success(absen)),
        );
      },
    );
  }

  Future<void> openLocationSettings() => _permissionService.openLocationSettings();

  Future<void> openAppSettings() => _permissionService.openSettings();

  void reset() => emit(const AbsenState.idle());
}