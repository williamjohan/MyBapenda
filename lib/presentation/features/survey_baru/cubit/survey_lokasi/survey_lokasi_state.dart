import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../core/services/geo_location/i_geo_location_service.dart';
import '../../../../../domain/usecases/survey_permohonan/survey_permohonan_usecase.dart';

/// Lokasi reklame satu sisi hasil pinpoint (ikut di `SurveyResult`).
typedef SurveyLokasiHasil = ({
  /// Titik reklame (pin), bukan posisi petugas.
  double lat,
  double lng,
  String alamat,

  /// Jarak garis lurus posisi petugas ke pin.
  double jarakMeter,
  double petugasLat,
  double petugasLng,
  double akurasiMeter,
});

typedef TitikPeta = ({double lat, double lng});

enum SurveyLokasiStatus { memuat, siap, gagal }

class SurveyLokasiState extends Equatable {
  final SurveyLokasiStatus status;

  /// Posisi HP petugas (titik awal "penggaris").
  final GeoPosition? petugas;

  /// Titik reklame = tengah peta; ikut bergeser saat peta digeser.
  final TitikPeta? pin;
  final String? alamat;
  final bool memuatAlamat;
  final String? pesanError;
  
  // 🚀 REFACTOR: Mengganti kodeError menjadi flag boolean universal
  final bool requiresLocationSettings;

  /// Pin reklame paling jauh dari posisi petugas (meter): petugas harus
  /// benar-benar di lokasi reklame. Dari setting server
  /// ([SurveyPermohonanUseCase.radiusSurvey]).
  final int jarakMaksMeter;

  const SurveyLokasiState({
    this.status = SurveyLokasiStatus.memuat,
    this.petugas,
    this.pin,
    this.alamat,
    this.memuatAlamat = false,
    this.pesanError,
    this.jarakMaksMeter = SurveyPermohonanUseCase.radiusBawaanMeter,
    this.requiresLocationSettings = false, // Default false
  });

  /// Jarak petugas ke pin (meter); null bila salah satu belum ada.
  double? get jarakMeter {
    final p = petugas, t = pin;
    if (p == null || t == null) return null;
    return Geolocator.distanceBetween(p.latitude, p.longitude, t.lat, t.lng);
  }

  bool get terlaluJauh => (jarakMeter ?? 0) > jarakMaksMeter;

  /// Pin ada, dalam radius [jarakMaksMeter], dan alamat selesai dimuat.
  bool get lokasiSiap =>
      pin != null && petugas != null && !terlaluJauh && !memuatAlamat;

  SurveyLokasiHasil? get hasil {
    final p = petugas, t = pin, jarak = jarakMeter;
    if (!lokasiSiap || p == null || t == null || jarak == null) return null;
    return (
      lat: t.lat,
      lng: t.lng,
      alamat: alamat ?? '-',
      jarakMeter: jarak,
      petugasLat: p.latitude,
      petugasLng: p.longitude,
      akurasiMeter: p.akurasiMeter,
    );
  }

  SurveyLokasiState copyWith({
    SurveyLokasiStatus? status,
    GeoPosition? petugas,
    TitikPeta? pin,
    String? alamat,
    bool? memuatAlamat,
    String? pesanError,
    bool? requiresLocationSettings,
    int? jarakMaksMeter,
    bool clearError = false,
  }) {
    return SurveyLokasiState(
      status: status ?? this.status,
      petugas: petugas ?? this.petugas,
      pin: pin ?? this.pin,
      alamat: alamat ?? this.alamat,
      memuatAlamat: memuatAlamat ?? this.memuatAlamat,
      pesanError: clearError ? null : pesanError ?? this.pesanError,
      jarakMaksMeter: jarakMaksMeter ?? this.jarakMaksMeter,
      requiresLocationSettings: clearError ? false : requiresLocationSettings ?? this.requiresLocationSettings,
    );
  }

  @override
  List<Object?> get props => [
    status,
    petugas?.latitude,
    petugas?.longitude,
    petugas?.akurasiMeter,
    pin,
    alamat,
    memuatAlamat,
    pesanError,
    jarakMaksMeter,
    requiresLocationSettings,
  ];
}