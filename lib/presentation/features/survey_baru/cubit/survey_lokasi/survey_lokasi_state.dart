import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../../core/services/geo_location_service.dart';

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
  final GeoLocationError? kodeError;

  const SurveyLokasiState({
    this.status = SurveyLokasiStatus.memuat,
    this.petugas,
    this.pin,
    this.alamat,
    this.memuatAlamat = false,
    this.pesanError,
    this.kodeError,
  });

  /// Jarak petugas ke pin (meter); null bila salah satu belum ada.
  double? get jarakMeter {
    final p = petugas, t = pin;
    if (p == null || t == null) return null;
    return Geolocator.distanceBetween(p.latitude, p.longitude, t.lat, t.lng);
  }

  /// Pin reklame paling jauh sejauh ini dari posisi petugas (keputusan
  /// user 2026-10-17, diperketat dari 50 m): petugas harus benar-benar di
  /// lokasi reklame.
  static const jarakMaksMeter = 20.0;

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
    GeoLocationError? kodeError,
    bool clearError = false,
  }) {
    return SurveyLokasiState(
      status: status ?? this.status,
      petugas: petugas ?? this.petugas,
      pin: pin ?? this.pin,
      alamat: alamat ?? this.alamat,
      memuatAlamat: memuatAlamat ?? this.memuatAlamat,
      pesanError: clearError ? null : pesanError ?? this.pesanError,
      kodeError: clearError ? null : kodeError ?? this.kodeError,
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
    kodeError,
  ];
}
