import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failure.dart';
import '../../../domain/entities/coordinate_entity.dart';
import '../../../domain/repositories/geocoding/geocoding_repository.dart';

@LazySingleton(as: IGeocodingRepository)
class GeocodingRepositoryImpl implements IGeocodingRepository {
  @override
  Future<Either<Failure, String>> getAddressFromCoordinate(
    CoordinateEntity coordinate,
  ) async {
    try {
      await geo.setLocaleIdentifier('id_ID');
      List<geo.Placemark> placemarks = await geo
          .placemarkFromCoordinates(coordinate.latitude, coordinate.longitude)
          .timeout(const Duration(seconds: 8));

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Bagian kosong/null dan nama wilayah yang berulang dilewati, supaya
        // tidak muncul "null, ..." di alamat.
        final bagian = <String>[];
        for (final b in [
          place.street,
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.postalCode,
        ]) {
          final t = (b ?? '').trim();
          if (t.isEmpty) continue;
          if (bagian.any((x) => x.toLowerCase() == t.toLowerCase())) continue;
          bagian.add(t);
        }
        if (bagian.isEmpty) return const Left(LocationNotFoundFailure());
        return Right(bagian.join(', '));
      } else {
        return const Left(LocationNotFoundFailure());
      }
    } catch (e) {
      return const Left(GeocodingFailure());
    }
  }

  @override
  Future<Either<Failure, CoordinateEntity>> getCoordinateFromAddress(
    String query,
  ) async {
    try {
      List<geo.Location> locations = await geo.locationFromAddress(query);

      if (locations.isNotEmpty) {
        final loc = locations.first;
        return Right(
          CoordinateEntity(latitude: loc.latitude, longitude: loc.longitude),
        );
      } else {
        return const Left(LocationNotFoundFailure());
      }
    } catch (e) {
      return const Left(GeocodingFailure());
    }
  }
}
