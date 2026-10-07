// lib/presentation/shared/utils/bapenda_location.dart
import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);

  @override
  String toString() => message;
}

/// Hasil fix GPS. time = waktu dari satelit (bukan jam HP).
typedef BapendaFix = ({double lat, double lng, double accuracy, DateTime time});

class LocationUtil {
  LocationUtil._();

  /// Cek GPS aktif + izin saja, TANPA mengambil koordinat.
  /// Dipanggil sebelum kamera dibuka supaya gagalnya cepat.
  static Future<void> ensureReady() async {
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
  }

  /// Ambil koordinat SEKARANG. Lempar [LocationException] kalau GPS mati,
  /// izin ditolak, lokasi palsu, akurasi rendah, atau jam HP tidak cocok
  /// dengan waktu GPS. TimeoutException kalau sinyal lemah.
  static Future<BapendaFix> current({double maxAccuracy = 50}) async {
    await ensureReady();

    // geolocator ^11: desiredAccuracy (bukan locationSettings)
    final p = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: const Duration(seconds: 20),
    );

    // ✏️ BARU: tolak lokasi palsu (hanya terdeteksi di Android)
    if (p.isMocked) {
      throw const LocationException(
        'Terdeteksi lokasi palsu (Fake GPS). Matikan aplikasi mock location.',
      );
    }

    // ✏️ BARU: tolak akurasi buruk
    if (p.accuracy > maxAccuracy) {
      throw LocationException(
        'Akurasi GPS rendah (±${p.accuracy.round()} m). '
        'Pindah ke area terbuka lalu coba lagi.',
      );
    }

    // ✏️ BARU: waktu dari satelit, dan cocokkan dengan jam HP
    final gpsTime = (p.timestamp ?? DateTime.now()).toLocal();
    if (DateTime.now().difference(gpsTime).abs() > const Duration(minutes: 5)) {
      throw const LocationException(
        'Jam HP tidak sesuai waktu GPS. Aktifkan "Tanggal & waktu otomatis".',
      );
    }

    return (
      lat: p.latitude,
      lng: p.longitude,
      accuracy: p.accuracy,
      time: gpsTime,
    );
  }
}
