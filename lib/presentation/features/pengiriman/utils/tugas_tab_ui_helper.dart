import '../../../../domain/entities/pengiriman/berkas_entity.dart';

/// Tab daftar tugas. `GET daftar` mengembalikan semua tugas sekaligus
/// (termasuk yang sudah diterima, untuk Pantau), jadi pembagian tab, jumlah
/// badge, dan pencarian dilakukan di HP.
enum TabTugas {
  ambil('Untuk Diambil'),
  diantar('Diantar'),
  gagal('Gagal/Kembali');

  final String label;
  const TabTugas(this.label);

  /// null = bukan tugas lagi ([BerkasEntity.masihTugas]): tidak tampil di
  /// Pengiriman Surat, cukup di Pantau.
  static TabTugas? dari(BerkasEntity b) {
    if (b.perluDikembalikan) return TabTugas.gagal;
    if (!b.masihTugas) return null;
    return switch (b.status) {
      StatusBerkas.disiapkan || StatusBerkas.ditugaskan => TabTugas.ambil,
      // Diterima/via pos dari aksi yang masih di antrean HP: tetap di
      // Diantar (bertanda "Belum terkirim") sampai terkirim.
      StatusBerkas.diambil ||
      StatusBerkas.dalamPerjalanan ||
      StatusBerkas.tiba ||
      StatusBerkas.diterima ||
      StatusBerkas.dikirimViaPos => TabTugas.diantar,
      StatusBerkas.gagalAntar ||
      StatusBerkas.dibatalkan ||
      StatusBerkas.dikembalikan ||
      StatusBerkas.tidakTerkirim => TabTugas.gagal,
    };
  }
}

class TugasTabUiHelper {
  TugasTabUiHelper._();

  /// Cari di no resi, nama WP, no surat, dan NPWPD (tidak peka huruf).
  static List<BerkasEntity> filter(
    List<BerkasEntity> semua,
    TabTugas tab,
    String query,
  ) {
    final q = query.trim().toLowerCase();
    return semua.where((b) {
      if (TabTugas.dari(b) != tab) return false;
      if (q.isEmpty) return true;
      return [
        b.noResi,
        b.namaWp,
        b.noSurat,
        b.npwpd,
      ].any((v) => v?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  static Map<TabTugas, int> hitung(List<BerkasEntity> semua) {
    final jumlah = {for (final t in TabTugas.values) t: 0};
    for (final b in semua) {
      final t = TabTugas.dari(b);
      if (t != null) jumlah[t] = jumlah[t]! + 1;
    }
    return jumlah;
  }
}
