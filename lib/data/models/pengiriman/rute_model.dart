import '../../../domain/entities/pengiriman/lacak_entity.dart';

/// Respons Google Routes API `computeRoutes` (field mask
/// `routes.polyline.encodedPolyline`). Format Google, bukan envelope
/// `BaseApiResponseModel`, jadi diurai manual.
class RuteModel {
  /// Encoded polyline rute pertama; null bila tidak ada rute.
  final String? encodedPolyline;

  const RuteModel({this.encodedPolyline});

  factory RuteModel.fromJson(Map<String, dynamic> json) {
    final routes = json['routes'] as List? ?? const [];
    final polyline = routes.isEmpty
        ? null
        : (routes.first as Map<String, dynamic>)['polyline']
              as Map<String, dynamic>?;
    return RuteModel(encodedPolyline: polyline?['encodedPolyline'] as String?);
  }

  /// Body permintaan rute motor melewati [titik] berurutan.
  static Map<String, dynamic> permintaan(List<TitikRute> titik) {
    Map<String, dynamic> lokasi(TitikRute t) => {
      'location': {
        'latLng': {'latitude': t.lat, 'longitude': t.lng},
      },
    };
    return {
      'origin': lokasi(titik.first),
      'destination': lokasi(titik.last),
      if (titik.length > 2)
        'intermediates': [
          for (final t in titik.sublist(1, titik.length - 1)) lokasi(t),
        ],
      'travelMode': 'TWO_WHEELER',
    };
  }
}

extension RuteModelX on RuteModel {
  List<TitikRute> toEntity() =>
      encodedPolyline == null ? const [] : decodePolyline(encodedPolyline!);
}

/// Algoritma Encoded Polyline Google (presisi 1e-5).
List<TitikRute> decodePolyline(String encoded) {
  final hasil = <TitikRute>[];
  var i = 0, lat = 0, lng = 0;
  int baca() {
    var shift = 0, nilai = 0, b = 0;
    do {
      b = encoded.codeUnitAt(i++) - 63;
      nilai |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    return (nilai & 1) != 0 ? ~(nilai >> 1) : nilai >> 1;
  }

  while (i < encoded.length) {
    lat += baca();
    lng += baca();
    hasil.add(TitikRute(lat / 1e5, lng / 1e5));
  }
  return hasil;
}
