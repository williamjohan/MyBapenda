import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failure.dart';
import '../../../domain/entities/coordinate_entity.dart';
import '../../../domain/repositories/geocoding/geocoding_repository.dart';


@LazySingleton(as: GeocodingRepository)
class GeocodingRepositoryImpl implements GeocodingRepository {
  @override
  Future<Either<Failure, String>> getAddressFromCoordinate(
    CoordinateEntity coordinate,
  ) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        coordinate.latitude,
        coordinate.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Format alamat bisa disesuaikan dengan kebutuhan Bapenda
        final address =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}";
        return Right(address);
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
