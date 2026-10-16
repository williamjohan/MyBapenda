import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/storage/app_secure_storage.dart';
import '../../../core/utils/va_qris_constants.dart';
import '../../models/va_qris/recent_reference_model.dart';

/// Riwayat "Terakhir dicari" Create VA & QRIS, disimpan per NIP
/// (`va_qris_riwayat_<nip>`) agar tiap pegawai di HP yang sama terpisah.
abstract class IVaQrisLocalDataSource {
  /// Terbaru dulu.
  Future<List<RecentReferenceModel>> getRecent();

  /// Taruh paling atas; entri jenis pajak + nomor yang sama diganti, maksimal
  /// [kRecentReferenceLimit]. Mengembalikan daftar terbaru.
  Future<List<RecentReferenceModel>> saveRecent(RecentReferenceModel item);

  Future<void> clearRecent();
}

@LazySingleton(as: IVaQrisLocalDataSource)
class VaQrisLocalDataSourceImpl implements IVaQrisLocalDataSource {
  static const _kRecentPrefix = 'va_qris_riwayat';

  final SharedPreferences _prefs;
  final AppSecureStorage _secureStorage;

  VaQrisLocalDataSourceImpl(this._prefs, this._secureStorage);

  Future<String> _key() async {
    final nip = await _secureStorage.getCurrentNip();
    return (nip == null || nip.isEmpty)
        ? _kRecentPrefix
        : '${_kRecentPrefix}_$nip';
  }

  List<RecentReferenceModel> _read(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map(
            (e) => RecentReferenceModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (_) {
      // Data rusak / format lama: anggap kosong
      return [];
    }
  }

  @override
  Future<List<RecentReferenceModel>> getRecent() async => _read(await _key());

  @override
  Future<List<RecentReferenceModel>> saveRecent(
    RecentReferenceModel item,
  ) async {
    final key = await _key();
    final list = [
      item,
      ..._read(key).where(
        (e) =>
            !(e.jenisPajak == item.jenisPajak &&
                e.noReferensi == item.noReferensi),
      ),
    ].take(kRecentReferenceLimit).toList();
    await _prefs.setString(
      key,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
    return list;
  }

  @override
  Future<void> clearRecent() async => _prefs.remove(await _key());
}
