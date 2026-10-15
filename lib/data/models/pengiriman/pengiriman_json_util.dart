/// Konverter longgar untuk respons `/api/pengiriman` (tipe dari server bisa
/// angka atau teks).
library;

String? jsonAsString(Object? v) => v == null ? null : '$v';

bool jsonAsBool(Object? v) => switch (v) {
  bool b => b,
  num n => n != 0,
  String s => const {'true', '1', 'y', 'ya'}.contains(s.toLowerCase()),
  _ => false,
};

/// Dipakai `readValue` untuk mem-parse objek induk sebagai model lain.
Object? jsonSelf(Map json, String _) => json;

DateTime? parseTgl(String? v) => v == null ? null : DateTime.tryParse(v);

/// Nama tampilan jenis surat: label dari kode yang dikenal (HMB/TGR/SKB);
/// selain itu nama server dirapikan ("SKReklameBongkar" → "SK Reklame
/// Bongkar") supaya kode mentah tidak tampil.
String namaJenisSurat(String labelKode, bool kodeDikenal, String? namaServer) {
  if (kodeDikenal) return labelKode;
  final n = namaServer?.trim() ?? '';
  if (n.isEmpty) return labelKode;
  return n
      // "SKReklame" → "SK Reklame" (akhir singkatan kapital).
      .replaceAllMapped(
        RegExp(r'([A-Z]+)([A-Z][a-z])'),
        (m) => '${m[1]} ${m[2]}',
      )
      // "ReklameBongkar" → "Reklame Bongkar".
      .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
      .replaceAll('_', ' ')
      .replaceAll(RegExp(r'\s+'), ' ');
}
