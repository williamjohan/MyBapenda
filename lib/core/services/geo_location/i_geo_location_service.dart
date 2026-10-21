import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';

typedef GeoPosition = ({double latitude, double longitude, double akurasiMeter, DateTime time});

abstract class IGeoLocationService {
  /// Mengambil titik koordinat dengan aturan ketat (Anti-Fake GPS, Akurasi Maksimal, Sinkronisasi Waktu).
  Future<Either<Failure, GeoPosition>> getCurrentPosition({double maxAccuracy = 50});
}


