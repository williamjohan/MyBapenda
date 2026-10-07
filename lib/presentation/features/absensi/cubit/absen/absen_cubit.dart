import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/services/geo_location_service.dart';
import '../../../../../domain/entities/absensi/absen_entity.dart';
import '../../../../../domain/usecases/absensi/absensi_usecase.dart';
import 'absen_state.dart';

/// Alur absen: user menahan tombol sampai penuh → GPS → POST /absen.
/// Tanpa PIN/biometrik HP. Tidak ada absen offline; waktu selalu dari server.
@injectable
class AbsenCubit extends Cubit<AbsenState> {
  final AbsensiUseCase _useCase;
  final GeoLocationService _locationService;

  AbsenCubit(this._useCase, this._locationService) : super(const AbsenIdle());

  /// Dipanggil setelah tombol ditahan sampai penuh.
  Future<void> submit() async {
    // Cegah dobel kirim selama proses berjalan.
    if (state is AbsenInProgress) return;

    emit(const AbsenInProgress(AbsenStep.locating));
    final GeoPosition position;
    try {
      position = await _locationService.getCurrentPosition();
    } on GeoLocationException catch (e) {
      if (isClosed) return;
      if (e.error == GeoLocationError.timeout) {
        emit(
          const AbsenFailure(
            'Gagal mendapatkan lokasi. Coba lagi di area terbuka.',
          ),
        );
      } else {
        emit(AbsenLocationRequired(e.error));
      }
      return;
    }
    if (isClosed) return;

    // Fake GPS tetap dikirim (isMockLocation=true) agar server menolak
    // & mencatatnya untuk audit.
    emit(const AbsenInProgress(AbsenStep.submitting));
    final result = await _useCase.absen(
      AbsenParams(
        latitude: position.latitude,
        longitude: position.longitude,
        akurasiMeter: position.akurasiMeter,
        isMockLocation: position.isMocked,
      ),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(AbsenFailure(failure.message)),
      (absen) => emit(AbsenSuccess(absen)),
    );
  }

  Future<void> openLocationSettings() =>
      _locationService.openLocationSettings();

  Future<void> openAppSettings() => _locationService.openAppSettings();

  void reset() => emit(const AbsenIdle());
}
