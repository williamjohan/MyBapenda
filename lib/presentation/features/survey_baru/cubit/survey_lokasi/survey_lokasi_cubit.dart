import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/services/geo_location/i_geo_location_service.dart';
import '../../../../../core/services/permission/i_permission_service.dart';
import '../../../../../domain/entities/coordinate_entity.dart';
import '../../../../../domain/repositories/geocoding/geocoding_repository.dart';
import '../../../../../domain/usecases/survey_permohonan/survey_permohonan_usecase.dart';
import 'survey_lokasi_state.dart';

/// Pinpoint lokasi reklame: posisi petugas (GPS), pin yang bisa digeser,
/// alamat pin (reverse geocoding), dan jarak petugas ke pin.
@injectable
class SurveyLokasiCubit extends Cubit<SurveyLokasiState> {
  final IGeoLocationService _lokasi;
  final IPermissionService _permissionService;
  final IGeocodingRepository _geocoding;
  final SurveyPermohonanUseCase _survey;
  StreamSubscription<int>? _radiusBerubah;
  bool _radiusDariPush = false;

  int _permintaanAlamat = 0;

  SurveyLokasiCubit(
    this._lokasi,
    this._permissionService,
    this._geocoding,
    this._survey,
  ) : super(const SurveyLokasiState());

  /// [awal] = hasil sebelumnya (buka ulang sisi): pin & alamat dipulihkan,
  /// posisi petugas tetap diambil ulang.
  /// [awal] = hasil sisi ini sebelumnya di app; [pinDraft] = titik reklame
  /// dari draft server (alamatnya dimuat ulang). [jarakMaksMeter] = radius
  /// dari `survey-form`; kosong = setting `pengaturan-radius-survey`.
  Future<void> mulai({
    SurveyLokasiHasil? awal,
    TitikPeta? pinDraft,
    int? jarakMaksMeter,
  }) async {
    // Setting berubah (push SignalR) saat halaman terbuka: langsung dipakai.
    _radiusBerubah ??= _survey.radiusBerubah.listen((m) {
      _radiusDariPush = true;
      if (!isClosed) emit(state.copyWith(jarakMaksMeter: m));
    });
    // Nilai survey-form langsung dipasang; setting cadangan dimuat bersamaan
    // dengan GPS dan tidak menimpa push yang datang lebih dulu.
    final dariForm = jarakMaksMeter != null && jarakMaksMeter > 0;
    if (dariForm) emit(state.copyWith(jarakMaksMeter: jarakMaksMeter));
    final radius = dariForm
        ? Future<void>.value()
        : _survey.radiusSurvey().then((m) {
            if (!isClosed && !_radiusDariPush) {
              emit(state.copyWith(jarakMaksMeter: m));
            }
          });
    if (awal != null) {
      emit(
        state.copyWith(
          pin: (lat: awal.lat, lng: awal.lng),
          alamat: awal.alamat,
        ),
      );
    } else if (pinDraft != null) {
      emit(state.copyWith(pin: pinDraft));
    }
    await perbaruiPosisiPetugas();
    await radius;
  }

  Future<void> perbaruiPosisiPetugas() async {
    // 🚀 Menggunakan clearError: true gaya Equatable asli
    emit(state.copyWith(status: SurveyLokasiStatus.memuat, clearError: true));

    final locationResult = await _lokasi.getCurrentPosition();
    if (isClosed) return;

    await locationResult.fold(
      (failure) async {
        final isPermissionIssue = failure is PermissionFailure;
        emit(
          state.copyWith(
            status: SurveyLokasiStatus.gagal,
            pesanError: failure.message,
            requiresLocationSettings: isPermissionIssue,
          ),
        );
      },
      (position) async {
        final pinBaru = state.pin == null;
        emit(
          state.copyWith(
            status: SurveyLokasiStatus.siap,
            petugas: position,
            pin: pinBaru
                ? (lat: position.latitude, lng: position.longitude)
                : null,
          ),
        );
        if (pinBaru || state.alamat == null) await muatAlamatPin();
      },
    );
  }

  Future<void> bukaPengaturanLokasi() async {
    await _permissionService.openSettings();
  }

  void geserPin(double lat, double lng) {
    final pin = state.pin;
    if (pin != null && pin.lat == lat && pin.lng == lng) return;
    _permintaanAlamat++;
    emit(state.copyWith(pin: (lat: lat, lng: lng), memuatAlamat: true));
  }

  Future<void> pinBerhenti() async {
    if (state.memuatAlamat) await muatAlamatPin();
  }

  Future<void> muatAlamatPin() async {
    final pin = state.pin;
    if (pin == null) return;
    final id = ++_permintaanAlamat;
    emit(state.copyWith(memuatAlamat: true));

    final hasil = await _geocoding.getAddressFromCoordinate(
      CoordinateEntity(latitude: pin.lat, longitude: pin.lng),
    );
    if (isClosed || id != _permintaanAlamat) return;

    emit(
      state.copyWith(
        memuatAlamat: false,
        alamat: hasil.fold((_) => '-', (a) => a),
      ),
    );
  }

  @override
  Future<void> close() {
    _permintaanAlamat++;
    _radiusBerubah?.cancel();
    return super.close();
  }
}
