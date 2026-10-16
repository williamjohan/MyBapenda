/// Helper tampilan teks VA & QRIS.
class VaQrisUiHelper {
  const VaQrisUiHelper._();

  /// Teks dari API siap tampil: spasi beruntun dirapikan jadi satu, dan
  /// kosong ditampilkan "-" (mis. nama WP yang belum diisi di master).
  static String teks(String? value) {
    final rapi = (value ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
    return rapi.isEmpty ? '-' : rapi;
  }

  /// Nomor referensi di kartu tagihan: "NOP 35.78..." tetap berlabel,
  /// No SKPD cukup nomornya saja.
  static String nomorReferensi(String label, String nomor) =>
      label.trim().toUpperCase() == 'NO SKPD' ? nomor : '$label $nomor';
}
