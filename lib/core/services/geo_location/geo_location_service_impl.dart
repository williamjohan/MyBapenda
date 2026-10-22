import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import '../../enums/app_permission_enum.dart';
import '../../errors/exception.dart';
import '../../errors/failure.dart';
import '../permission/i_permission_service.dart';
import 'i_geo_location_service.dart';

@LazySingleton(as: IGeoLocationService)
class GeoLocationServiceImpl implements IGeoLocationService {
  final IPermissionService _permissionService;

  GeoLocationServiceImpl(this._permissionService);

  @override
  Future<Either<Failure, GeoPosition>> getCurrentPosition({double maxAccuracy = 50}) async {
    try {
      //  1. DELEGASIKAN IZIN KE PERMISSION SERVICE
      final gpsStatus = await _permissionService.requestPermission(AppPermissionType.locationService);
      if (gpsStatus != AppPermissionStatus.granted) {
        return const Left(PermissionFailure('Sensor GPS mati. Nyalakan lokasi perangkat Anda terlebih dahulu.'));
      }

      final permStatus = await _permissionService.requestPermission(AppPermissionType.location);
      if (permStatus != AppPermissionStatus.granted) {
        return const Left(PermissionFailure('Izin akses lokasi ditolak. Buka pengaturan aplikasi untuk memberikan izin.'));
      }

      //  2. NYALAKAN SENSOR GPS
      final p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 20),
      );

      //  3. LOGIKA EMAS BAPENDA (Migrasi dari LocationUtil)
      
      // A. Tolak Fake GPS (Mock Location)
      if (p.isMocked) {
        return const Left(LocationHardwareFailure(
          'Terdeteksi lokasi palsu (Fake GPS). Matikan aplikasi mock location Anda.',
        ));
      }

      // B. Tolak Akurasi Buruk
      if (p.accuracy > maxAccuracy) {
        return Left(LocationHardwareFailure(
          'Akurasi GPS rendah (±${p.accuracy.round()} m). Pindah ke area terbuka lalu coba lagi.',
        ));
      }

      // C. Tolak Kecurangan Waktu HP
      final gpsTime = p.timestamp.toLocal();
      if (DateTime.now().difference(gpsTime).abs() > const Duration(minutes: 5)) {
        return const Left(LocationHardwareFailure(
          'Jam HP tidak sesuai waktu GPS Satelit. Aktifkan "Tanggal & waktu otomatis" di pengaturan HP.',
        ));
      }

      //  4. KEMBALIKAN DATA BERSIH
      return Right((
        latitude: p.latitude,
        longitude: p.longitude,
        akurasiMeter: p.accuracy,
        time: gpsTime,
      ));

    } on TimeoutException {
      return const Left(TimeoutFailure('Sinyal GPS lemah atau tidak stabil, pencarian koordinat kehabisan waktu.'));
    } catch (e) {
      return const Left(UnknownFailure('Terjadi kesalahan tidak terduga pada sensor lokasi perangkat.'));
    }
  }
}