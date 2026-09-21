import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../entities/coordinate_entity.dart';

abstract class GeocodingRepository {
  /// Mengubah koordinat menjadi teks alamat
  Future<Either<Failure, String>> getAddressFromCoordinate(
    CoordinateEntity coordinate,
  );

  /// Mengubah teks pencarian (nama jalan/gedung) menjadi koordinat
  Future<Either<Failure, CoordinateEntity>> getCoordinateFromAddress(
    String query,
  );
}
