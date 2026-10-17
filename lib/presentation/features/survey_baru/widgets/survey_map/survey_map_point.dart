import 'package:bapendacore/domain/entities/cek_reklames/survey_permohonan_baru/survey_permohonan_entity.dart';
import 'package:latlong2/latlong.dart';
import 'survey_deadline.dart';

class SurveyMapPoint {
  final String id;
  final String nomor;
  final String lokasi;
  final int jumlahSisi;
  final LatLng position;
  final DateTime? deadline;

  /// null = data contoh (bukan dari API).
  final SurveyPermohonanEntity? source;

  const SurveyMapPoint({
    required this.id,
    required this.nomor,
    required this.lokasi,
    required this.jumlahSisi,
    required this.position,
    required this.deadline,
    this.source,
  });

  bool get isDemo => source == null;
  int? get daysLeft => SurveyDeadline.daysLeft(deadline);
}

class SurveyMapPoints {
  SurveyMapPoints._();

  // TODO: ganti dengan lat/lng dari BE (per permohonan atau per sisi).
  static const _dummyPositions = <LatLng>[
    LatLng(-7.2458, 112.7378), // Tugu Pahlawan
    LatLng(-7.2998, 112.7370), // Wonokromo
    LatLng(-7.2756, 112.7800), // Galaxy Mall
    LatLng(-7.2893, 112.6731), // Pakuwon Mall
  ];

  /// Data header asli dipasangkan ke koordinat dummy berdasarkan urutan.
  /// [withDemo]: kalau data asli kurang dari [minCount], sisanya diisi
  /// titik contoh supaya peta bisa dicoba. Hapus kalau sudah ada data nyata.
  static List<SurveyMapPoint> build(
    List<SurveyPermohonanEntity> items, {
    bool withDemo = true,
    int minCount = 4,
  }) {
    final out = <SurveyMapPoint>[
      for (var i = 0; i < items.length; i++)
        SurveyMapPoint(
          id: items[i].key,
          nomor: items[i].noPelayanan,
          lokasi: items[i].lokPenyelenggaraan,
          jumlahSisi: items[i].jumlahSisi,
          position: _dummyPositions[i % _dummyPositions.length],
          deadline: SurveyDeadline.parse(items[i].expTask),
          source: items[i],
        ),
    ];

    if (withDemo && out.length < minCount) {
      final today = DateTime.now();
      final base = DateTime(today.year, today.month, today.day);
      const demo = [
        (n: 'DEMO-00002', l: 'Jl. Raya Darmo (contoh)', s: 2, d: -1),
        (n: 'DEMO-00003', l: 'Jl. Kenjeran (contoh)', s: 1, d: 2),
        (n: 'DEMO-00004', l: 'Jl. Mayjen Sungkono (contoh)', s: 3, d: 9),
      ];
      for (var i = out.length; i < minCount; i++) {
        final d = demo[(i - 1) % demo.length];
        out.add(
          SurveyMapPoint(
            id: d.n,
            nomor: d.n,
            lokasi: d.l,
            jumlahSisi: d.s,
            position: _dummyPositions[i % _dummyPositions.length],
            deadline: base.add(Duration(days: d.d)),
          ),
        );
      }
    }
    return out;
  }
}
