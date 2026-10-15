/// Helper parsing JSON master yang toleran terhadap perbedaan nama field
/// (tidak case-sensitive). Kalau nama field di API beda, tambahkan di sini.
class MasterJson {
  MasterJson._();

  static const idKeys = ['id', 'kode'];
  static const namaKeys = ['nama', 'name', 'keterangan', 'deskripsi'];

  static dynamic pick(Map<String, dynamic> json, List<String> keys) {
    final lower = {for (final e in json.entries) e.key.toLowerCase(): e.value};
    for (final k in keys) {
      final v = lower[k.toLowerCase()];
      if (v != null) return v;
    }
    return null;
  }

  /// ID selalu dibaca sebagai String (API mengirim "3578270", bisa juga angka).
  static String requireId(
    Map<String, dynamic> json,
    List<String> keys,
    String field,
  ) {
    final v = pick(json, keys);
    final s = v == null ? '' : '$v'.trim();
    if (s.isEmpty) {
      throw FormatException(
        'Field "$field" tidak ditemukan. '
        'Key yang tersedia: ${json.keys.toList()}',
      );
    }
    return s;
  }

  static String requireString(
    Map<String, dynamic> json,
    List<String> keys,
    String field,
  ) {
    final v = pick(json, keys);
    if (v == null) {
      throw FormatException(
        'Field "$field" tidak ditemukan. '
        'Key yang tersedia: ${json.keys.toList()}',
      );
    }
    return '$v';
  }
}
