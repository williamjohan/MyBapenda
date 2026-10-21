import 'package:injectable/injectable.dart';
import 'package:mybapenda/core/utils/app_logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@lazySingleton
class MapService {
  final String? _googleApiKey;
  
  // Constructor bersih, tidak butuh injeksi logger
  MapService() : _googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  String generateStaticMapUrl({required double lat, required double long}) {
    if (_googleApiKey == null || _googleApiKey.isEmpty) {
      // Langsung panggil method static-nya
      AppLogger.warning('MapService: GOOGLE_MAPS_API_KEY missing'); 
      return 'https://via.placeholder.com/400x200?text=MAP+API+KEY+MISSING';
    }

    const String size = '600x200';
    const int zoom = 15;
    final String marker = 'color:red|$lat,$long';

    final url =
        'https://maps.googleapis.com/maps/api/staticmap'
        '?center=$lat,$long'
        '&zoom=$zoom'
        '&size=$size'
        '&scale=2'
        '&maptype=roadmap'
        '&markers=$marker'
        '&key=$_googleApiKey';

    // Langsung panggil method static-nya
    AppLogger.debug('MapService: static map url generated'); 
    return url;
  }
}