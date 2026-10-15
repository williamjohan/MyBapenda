import 'dart:convert';
import 'package:bapendacore/presentation/shared/master_data/data/models/master_option_model.dart';
import 'package:bapendacore/presentation/shared/master_data/domain/entities/master_option_type.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef CachedOptions = ({List<MasterOptionModel> items, DateTime savedAt});

abstract class IMasterLocalDataSource {
  CachedOptions? readOptions(MasterOptionType type);
  Future<void> saveOptions(
    MasterOptionType type,
    List<MasterOptionModel> items,
  );

  CachedOptions? readKelurahan(String kecamatanId);
  Future<void> saveKelurahan(String kecamatanId, List<MasterOptionModel> items);

  Future<void> clear();
}

@LazySingleton(as: IMasterLocalDataSource)
class MasterLocalDataSourceImpl implements IMasterLocalDataSource {
  // Key lama (cache "semua sekaligus"), cuma dipakai untuk dibersihkan.
  static const _kLegacyData = 'master_reklame_data_v2';
  static const _kLegacySavedAt = 'master_reklame_saved_at_v2';

  // Naikkan versi kalau bentuk data cache berubah.
  static const _kOptPrefix = 'master_reklame_opt_v1_';
  static const _kKelPrefix = 'master_reklame_kel_v2_';

  final SharedPreferences _prefs;

  MasterLocalDataSourceImpl(this._prefs);

  // ---- Generic helper ----

  CachedOptions? _read(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final items = (json['items'] as List)
          .map(
            (e) =>
                MasterOptionModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
      final savedAt = DateTime.fromMillisecondsSinceEpoch(
        json['savedAt'] as int,
      );
      return (items: items, savedAt: savedAt);
    } catch (_) {
      return null;
    }
  }

  Future<void> _save(String key, List<MasterOptionModel> items) async {
    await _prefs.setString(
      key,
      jsonEncode({
        'savedAt': DateTime.now().millisecondsSinceEpoch,
        'items': items.map((e) => e.toJson()).toList(),
      }),
    );
  }

  // ---- Options per tipe ----

  @override
  CachedOptions? readOptions(MasterOptionType type) =>
      _read('$_kOptPrefix${type.name}');

  @override
  Future<void> saveOptions(
    MasterOptionType type,
    List<MasterOptionModel> items,
  ) => _save('$_kOptPrefix${type.name}', items);

  // ---- Kelurahan per kecamatan ----

  @override
  CachedOptions? readKelurahan(String kecamatanId) =>
      _read('$_kKelPrefix$kecamatanId');

  @override
  Future<void> saveKelurahan(
    String kecamatanId,
    List<MasterOptionModel> items,
  ) => _save('$_kKelPrefix$kecamatanId', items);

  @override
  Future<void> clear() async {
    await _prefs.remove(_kLegacyData);
    await _prefs.remove(_kLegacySavedAt);
    for (final key in _prefs.getKeys().where(
      (k) => k.startsWith(_kOptPrefix) || k.startsWith(_kKelPrefix),
    )) {
      await _prefs.remove(key);
    }
  }
}
