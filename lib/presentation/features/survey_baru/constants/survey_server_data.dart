import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_lokasi/survey_lokasi_state.dart';
import 'package:flutter/foundation.dart';

Map<String, dynamic>? apiDataOf(Map<String, dynamic> sisi) {
  final raw = sisi['survey'];
  if (raw is! Map) return null;

  final s = Map<String, dynamic>.from(raw)..remove('fotos');

  dynamic pick(List<String> keys) {
    for (final k in keys) {
      final v = s[k];
      if (v != null && '$v'.trim().isNotEmpty) return v;
    }
    return null;
  }

  int? idOf(List<String> keys) {
    final v = pick(keys);
    if (v == null) return null;
    return v is num ? v.toInt() : int.tryParse('$v'.trim());
  }

  num? numOf(List<String> keys) {
    final v = pick(keys);
    if (v == null) return null;
    return v is num ? v : num.tryParse('$v'.trim().replaceAll(',', '.'));
  }

  String? textOf(List<String> keys) {
    final v = pick(keys);
    return v == null ? null : '$v'.trim();
  }

  final nb = s['norBaru'];

  final data = <String, dynamic>{
    'lokasiTertentuId': idOf([
      'lokasiTertentuId',
      'idLokasiTertentu',
      'lokasiTertentu',
    ]),
    'letakReklame': idOf([
      'letakReklame',
      'letakReklameId',
      'idLetakReklame',
      'letakId',
    ]),
    'statusTanah': idOf(['statusTanah', 'statusTanahId', 'idStatusTanah']),
    'idJenisReklame': idOf([
      'idJenisReklame',
      'jenisReklameId',
      'jenisReklame',
    ]),
    'idJenisProduk': idOf(['idJenisProduk', 'jenisProdukId', 'jenisProduk']),
    'sudutPandang': idOf(['sudutPandang', 'sudutPandangId', 'idSudutPandang']),
    'panjang': numOf(['panjang']),
    'lebar': numOf(['lebar']),
    'tinggi': numOf(['tinggi']),
    'lokPenyelenggaraan': textOf([
      'lokPenyelenggaraan',
      'lokPenyelenggaraanSurvey',
    ]),
    'materiReklame': textOf(['materiReklame', 'materi']),
    'ketSisi': textOf(['ketSisi']),
    'ketSurvey': textOf(['ketSurvey']),
    if (nb is Map) 'norBaru': Map<String, dynamic>.from(nb),
  }..removeWhere((_, v) => v == null);

  if (data.isEmpty) {
    if (kDebugMode && s.isNotEmpty) {
      debugPrint('[survey] key dari server tidak dikenali: ${s.keys.toList()}');
    }
    return null;
  }
  return data;
}

SurveyLokasiHasil? lokasiAwalDariSisi(Map<String, dynamic> sisi) {
  final sv = sisi['survey'];
  if (sv is! Map) return null;
  final lat = sv['latitude'];
  final lng = sv['longitude'];
  if (lat is! num || lng is! num) return null;

  return (
    lat: lat.toDouble(),
    lng: lng.toDouble(),
    alamat: '', // kosong = alamat dimuat ulang oleh cubit
    jarakMeter: 0,
    petugasLat: lat.toDouble(),
    petugasLng: lng.toDouble(),
    akurasiMeter: 0,
  );
}
