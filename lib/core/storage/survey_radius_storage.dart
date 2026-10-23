import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Salinan terakhir radius maksimal pin survey reklame (meter) dari
/// `pengaturan-radius-survey` / `survey-form`, supaya tetap dipakai saat
/// offline atau API gagal.
@lazySingleton
class SurveyRadiusStorage {
  final SharedPreferences _prefs;

  SurveyRadiusStorage(this._prefs);

  static const _key = 'survey_radius_maks_meter_v1';

  Future<void> simpan(int meter) => _prefs.setString(
    _key,
    jsonEncode({'tgl': DateTime.now().toIso8601String(), 'meter': meter}),
  );

  ({int meter, DateTime tgl})? baca() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return (
        meter: j['meter'] as int,
        tgl: DateTime.parse(j['tgl'] as String),
      );
    } catch (_) {
      return null;
    }
  }
}
