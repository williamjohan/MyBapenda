import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/services/geo_location_service.dart';
import '../../../../../domain/entities/coordinate_entity.dart';
import '../../../../../domain/repositories/geocoding/geocoding_repository.dart';
import '../../../../../domain/usecases/survey_permohonan/survey_permohonan_usecase.dart';
import 'survey_lokasi_state.dart';

/// Pinpoint lokasi reklame: posisi petugas (GPS), pin yang bisa digeser,
/// alamat pin (reverse geocoding), dan jarak petugas ke pin.
@injectable
class SurveyLokasiCubit extends Cubit<SurveyLokasiState> {
  final GeoLocationService _lokasi;
  final GeocodingRepository _geocoding;
  final SurveyPermohonanUseCase _survey;
  StreamSubscription<int>? _radiusBerubah;
  bool _radiusDariPush = false;

  // Hasil reverse geocoding lama dibuang bila pin sudah digeser lagi.
  int _permintaanAlamat = 0;

  SurveyLokasiCubit(this._lokasi, this._geocoding, this._survey)
    : super(const SurveyLokasiState());

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

  /// Ambil posisi HP. Pin awal = posisi petugas bila belum ada pin.
  Future<void> perbaruiPosisiPetugas() async {
    emit(state.copyWith(status: SurveyLokasiStatus.memuat, clearError: true));
    try {
      final p = await _lokasi.getCurrentPosition();
      if (isClosed) return;
      if (p.isMocked) {
        emit(
          state.copyWith(
            status: SurveyLokasiStatus.gagal,
            pesanError:
                'Terdeteksi lokasi palsu (Fake GPS). Matikan aplikasi mock location.',
          ),
        );
        return;
      }
      final pinBaru = state.pin == null;
      emit(
        state.copyWith(
          status: SurveyLokasiStatus.siap,
          petugas: p,
          pin: pinBaru ? (lat: p.latitude, lng: p.longitude) : null,
        ),
      );
      if (pinBaru || state.alamat == null) await muatAlamatPin();
    } on GeoLocationException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: SurveyLokasiStatus.gagal,
          kodeError: e.error,
          pesanError: switch (e.error) {
            GeoLocationError.serviceDisabled => 'GPS HP mati. Nyalakan GPS.',
            GeoLocationError.permissionDenied => 'Izin lokasi dibutuhkan.',
            GeoLocationError.permissionDeniedForever =>
              'Izin lokasi ditolak. Aktifkan dari pengaturan aplikasi.',
            GeoLocationError.timeout =>
              'Sinyal GPS lemah. Coba di area yang lebih terbuka.',
          },
        ),
      );
    }
  }

  Future<void> bukaPengaturanLokasi() async {
    switch (state.kodeError) {
      case GeoLocationError.serviceDisabled:
        await _lokasi.openLocationSettings();
      case GeoLocationError.permissionDeniedForever:
        await _lokasi.openAppSettings();
      default:
        break;
    }
  }

  /// Dipanggil terus selama peta digeser: jarak ikut berubah, alamat
  /// ditandai usang sampai peta berhenti ([muatAlamatPin]).
  void geserPin(double lat, double lng) {
    final pin = state.pin;
    if (pin != null && pin.lat == lat && pin.lng == lng) return;
    _permintaanAlamat++;
    emit(state.copyWith(pin: (lat: lat, lng: lng), memuatAlamat: true));
  }

  /// Peta berhenti digeser. Idle juga terpanggil saat peta pertama tampil;
  /// alamat hanya dimuat ulang bila pin memang berpindah.
  Future<void> pinBerhenti() async {
    if (state.memuatAlamat) await muatAlamatPin();
  }

  /// Reverse geocoding untuk pin saat ini.
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
        // Alamat gagal tidak menghalangi survey: koordinat tetap tersimpan.
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
