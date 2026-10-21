import 'package:mybapenda/domain/entities/cek_reklames/survey_permohonan_baru/survey_permohonan_entity.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    show LatLng; // [UBAH] dulu latlong2
import 'survey_deadline.dart';

class SurveyMapPoint {
  final String id;
  final String nomor;
  final String lokasi;
  final int jumlahSisi;
  final LatLng position;
  final DateTime? deadline;

  final SurveyPermohonanEntity source;

  const SurveyMapPoint({
    required this.id,
    required this.nomor,
    required this.lokasi,
    required this.jumlahSisi,
    required this.position,
    required this.deadline,
    required this.source,
  });

  int? get daysLeft => SurveyDeadline.daysLeft(deadline);
}

class SurveyMapPoints {
  SurveyMapPoints._();

  static List<SurveyMapPoint> build(List<SurveyPermohonanEntity> items) {
    return [
      for (final item in items)
        if (_isValidCoordinate(item.latitude, item.longitude))
          SurveyMapPoint(
            id: item.key,
            nomor: item.noPelayanan,
            lokasi: item.lokPenyelenggaraan,
            jumlahSisi: item.jumlahSisi,
            position: LatLng(item.latitude, item.longitude),
            deadline: SurveyDeadline.parse(item.expTask),
            source: item,
          ),
    ];
  }

  static bool _isValidCoordinate(double lat, double lng) {
    final inRange = lat.abs() <= 90 && lng.abs() <= 180; 
    final isEmpty = lat == 0 && lng == 0;
    return inRange && !isEmpty;
  }
}
