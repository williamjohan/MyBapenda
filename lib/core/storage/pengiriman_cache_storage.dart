import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';

/// Salinan data terakhir Pengiriman Surat per NIP (daftar tugas & detail),
/// supaya tetap bisa dibuka saat offline. Disimpan sebagai JSON mentah.
@lazySingleton
class PengirimanCacheStorage {
  final SharedPreferences _prefs;

  PengirimanCacheStorage(this._prefs);

  /// Batas jumlah detail berkas yang disimpan (yang terlama dibuang).
  static const _maksDetail = 100;

  static String _keyDaftar(String nip) => 'pengiriman_cache_daftar_$nip';
  static String _keyDetail(String nip) => 'pengiriman_cache_detail_$nip';

  Future<void> simpanDaftar(String nip, List<Map<String, dynamic>> data) =>
      _prefs.setString(
        _keyDaftar(nip),
        jsonEncode({'tgl': DateTime.now().toIso8601String(), 'data': data}),
      );

  ({List<Map<String, dynamic>> data, DateTime tgl})? bacaDaftar(String nip) {
    final j = _decode(_prefs.getString(_keyDaftar(nip)));
    if (j == null) return null;
    return (
      data: (j['data'] as List).cast<Map<String, dynamic>>(),
      tgl: DateTime.parse(j['tgl'] as String),
    );
  }

  Future<void> simpanDetail(
    String nip,
    String noResi,
    Map<String, dynamic> data,
  ) {
    final semua = _decode(_prefs.getString(_keyDetail(nip))) ?? {};
    semua.remove(noResi); // pindah ke paling baru
    semua[noResi] = {'tgl': DateTime.now().toIso8601String(), 'data': data};
    while (semua.length > _maksDetail) {
      semua.remove(semua.keys.first);
    }
    return _prefs.setString(_keyDetail(nip), jsonEncode(semua));
  }

  ({Map<String, dynamic> data, DateTime tgl})? bacaDetail(
    String nip,
    String noResi,
  ) {
    final semua = _decode(_prefs.getString(_keyDetail(nip)));
    final j = semua?[noResi] as Map<String, dynamic>?;
    if (j == null) return null;
    return (
      data: j['data'] as Map<String, dynamic>,
      tgl: DateTime.parse(j['tgl'] as String),
    );
  }

  Map<String, dynamic>? _decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.warning('[Pengiriman] cache rusak, diabaikan: $e');
      return null;
    }
  }
}
