import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

enum GeoLocationError {
  /// GPS / layanan lokasi HP mati.
  serviceDisabled,

  /// Izin ditolak (masih bisa diminta lagi).
  permissionDenied,

  /// Izin ditolak permanen, harus dibuka dari pengaturan.
  permissionDeniedForever,

  /// Tidak dapat posisi dalam batas waktu.
  timeout,
}

class GeoLocationException implements Exception {
  final GeoLocationError error;
  const GeoLocationException(this.error);
}

/// Posisi untuk absen: koordinat + akurasi + flag fake GPS.
class GeoPosition {
  final double latitude;
  final double longitude;
  final double akurasiMeter;
  final bool isMocked;

  const GeoPosition({
    required this.latitude,
    required this.longitude,
    required this.akurasiMeter,
    required this.isMocked,
  });
}

abstract class GeoLocationService {
  /// Cek izin & GPS lalu ambil posisi akurasi tinggi.
  /// Melempar [GeoLocationException] bila tidak bisa.
  Future<GeoPosition> getCurrentPosition();

  Future<void> openLocationSettings();
  Future<void> openAppSettings();
}

@LazySingleton(as: GeoLocationService)
class GeoLocationServiceImpl implements GeoLocationService {
  @override
  Future<GeoPosition> getCurrentPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const GeoLocationException(
        GeoLocationError.permissionDeniedForever,
      );
    }
    if (permission == LocationPermission.denied) {
      throw const GeoLocationException(GeoLocationError.permissionDenied);
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const GeoLocationException(GeoLocationError.serviceDisabled);
    }

    try {
      // geolocator ^11: desiredAccuracy (bukan locationSettings)
      final p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      return GeoPosition(
        latitude: p.latitude,
        longitude: p.longitude,
        akurasiMeter: p.accuracy,
        isMocked: p.isMocked,
      );
    } on TimeoutException {
      throw const GeoLocationException(GeoLocationError.timeout);
    } on LocationServiceDisabledException {
      throw const GeoLocationException(GeoLocationError.serviceDisabled);
    }
  }

  @override
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  Future<void> openAppSettings() => Geolocator.openAppSettings();
}
