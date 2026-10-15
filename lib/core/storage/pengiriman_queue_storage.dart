import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';

/// Satu aksi pengiriman yang menunggu dikirim (atau ditolak server).
/// Disimpan sebagai JSON; foto disalin ke folder aplikasi supaya tidak
/// hilang saat cache sementara dibersihkan.
class AntreanRecord {
  /// UUID check-in; tetap sama saat dikirim ulang (idempoten di server).
  final String checkinUuid;

  /// Kode aksi: perjalanan | tiba | serah | gagal | kembalikan.
  final String jenis;
  final String endpoint;
  final List<String> noResi;

  /// Field multipart berurutan `[nama, nilai]` (boleh berulang).
  final List<List<String>> fields;

  /// Nama field file → path file di folder antrean.
  final Map<String, String> files;
  final DateTime tglDibuat;
  final int jmlCoba;

  /// Pesan galat terakhir (sementara) atau alasan penolakan server.
  final String? pesanError;

  /// true = tersimpan di server sebagai jejak tapi status tidak berubah.
  final bool diabaikan;

  const AntreanRecord({
    required this.checkinUuid,
    required this.jenis,
    required this.endpoint,
    required this.noResi,
    required this.fields,
    required this.files,
    required this.tglDibuat,
    this.jmlCoba = 0,
    this.pesanError,
    this.diabaikan = false,
  });

  AntreanRecord copyWith({
    Map<String, String>? files,
    int? jmlCoba,
    String? pesanError,
    bool? diabaikan,
  }) => AntreanRecord(
    checkinUuid: checkinUuid,
    jenis: jenis,
    endpoint: endpoint,
    noResi: noResi,
    fields: fields,
    files: files ?? this.files,
    tglDibuat: tglDibuat,
    jmlCoba: jmlCoba ?? this.jmlCoba,
    pesanError: pesanError ?? this.pesanError,
    diabaikan: diabaikan ?? this.diabaikan,
  );

  Map<String, dynamic> toJson() => {
    'checkinUuid': checkinUuid,
    'jenis': jenis,
    'endpoint': endpoint,
    'noResi': noResi,
    'fields': fields,
    'files': files,
    'tglDibuat': tglDibuat.toIso8601String(),
    'jmlCoba': jmlCoba,
    'pesanError': pesanError,
    'diabaikan': diabaikan,
  };

  factory AntreanRecord.fromJson(Map<String, dynamic> j) => AntreanRecord(
    checkinUuid: j['checkinUuid'] as String,
    jenis: j['jenis'] as String,
    endpoint: j['endpoint'] as String,
    noResi: (j['noResi'] as List).map((e) => '$e').toList(),
    fields: (j['fields'] as List)
        .map((e) => (e as List).map((x) => '$x').toList())
        .toList(),
    files: (j['files'] as Map).map((k, v) => MapEntry('$k', '$v')),
    tglDibuat: DateTime.parse(j['tglDibuat'] as String),
    jmlCoba: (j['jmlCoba'] as num?)?.toInt() ?? 0,
    pesanError: j['pesanError'] as String?,
    diabaikan: j['diabaikan'] as bool? ?? false,
  );
}

/// Antrean offline Pengiriman Surat per NIP (SharedPreferences + folder foto).
/// - `menunggu`: dikirim berurutan (FIFO) oleh repository.
/// - `gagal`: ditolak server / diabaikan; ditampilkan ke petugas sampai
///   dihapus.
@lazySingleton
class PengirimanQueueStorage {
  final SharedPreferences _prefs;

  PengirimanQueueStorage(this._prefs);

  static String _keyMenunggu(String nip) => 'pengiriman_antrean_$nip';
  static String _keyGagal(String nip) => 'pengiriman_antrean_gagal_$nip';

  List<AntreanRecord> menunggu(String nip) => _baca(_keyMenunggu(nip));
  List<AntreanRecord> gagal(String nip) => _baca(_keyGagal(nip));

  /// Salin foto ke folder antrean lalu tambahkan di akhir antrean.
  Future<AntreanRecord> tambah(String nip, AntreanRecord record) async {
    final dir = await _folder(record.checkinUuid);
    final files = <String, String>{};
    for (final e in record.files.entries) {
      final src = File(e.value);
      final ext = e.value.contains('.') ? e.value.split('.').last : 'jpg';
      final dst = await src.copy('${dir.path}/${e.key}.$ext');
      files[e.key] = dst.path;
    }
    final disimpan = record.copyWith(files: files);
    await _tulis(_keyMenunggu(nip), [...menunggu(nip), disimpan]);
    return disimpan;
  }

  Future<void> perbarui(String nip, AntreanRecord record) =>
      _tulis(_keyMenunggu(nip), [
        for (final r in menunggu(nip))
          r.checkinUuid == record.checkinUuid ? record : r,
      ]);

  /// Terkirim: hapus dari antrean beserta fotonya.
  Future<void> selesai(String nip, String checkinUuid) async {
    await _tulis(_keyMenunggu(nip), [
      for (final r in menunggu(nip))
        if (r.checkinUuid != checkinUuid) r,
    ]);
    await _hapusFolder(checkinUuid);
  }

  /// Ditolak/diabaikan server: pindah ke daftar gagal, foto dihapus.
  Future<void> pindahKeGagal(String nip, AntreanRecord record) async {
    await _tulis(_keyMenunggu(nip), [
      for (final r in menunggu(nip))
        if (r.checkinUuid != record.checkinUuid) r,
    ]);
    await _tulis(_keyGagal(nip), [
      ...gagal(nip),
      record.copyWith(files: const {}),
    ]);
    await _hapusFolder(record.checkinUuid);
  }

  Future<void> hapusGagal(String nip, String checkinUuid) =>
      _tulis(_keyGagal(nip), [
        for (final r in gagal(nip))
          if (r.checkinUuid != checkinUuid) r,
      ]);

  List<AntreanRecord> _baca(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => AntreanRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.error('[Antrean] data antrean rusak: $key', e, st);
      return [];
    }
  }

  Future<void> _tulis(String key, List<AntreanRecord> list) => list.isEmpty
      ? _prefs.remove(key)
      : _prefs.setString(key, jsonEncode(list.map((e) => e.toJson()).toList()));

  static Future<Directory> _lokasi(String uuid) async {
    final base = await getApplicationDocumentsDirectory();
    return Directory('${base.path}/pengiriman_antrean/$uuid');
  }

  static Future<Directory> _folder(String uuid) async =>
      (await _lokasi(uuid)).create(recursive: true);

  static Future<void> _hapusFolder(String uuid) async {
    try {
      final dir = await _lokasi(uuid);
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (e) {
      AppLogger.warning('[Antrean] gagal hapus foto $uuid: $e');
    }
  }
}
