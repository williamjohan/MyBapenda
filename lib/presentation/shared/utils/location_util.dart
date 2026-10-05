// lib/presentation/shared/utils/bapenda_location.dart
import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);

  @override
  String toString() => message;
}

class LocationUtil {
  LocationUtil._();

  static Future<({double lat, double lng})> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException('GPS belum aktif. Nyalakan dulu ya.');
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      throw const LocationException('Izin lokasi dibutuhkan.');
    }
    // geolocator ^11: desiredAccuracy (bukan locationSettings)
    final p = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
    return (lat: p.latitude, lng: p.longitude);
  }
}
