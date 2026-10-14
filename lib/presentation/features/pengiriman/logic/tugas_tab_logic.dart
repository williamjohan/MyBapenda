import '../../../../domain/entities/pengiriman/berkas_entity.dart';

/// Tab daftar tugas. `GET daftar` mengembalikan semua tugas sekaligus,
/// jadi pembagian tab, jumlah badge, dan pencarian dilakukan di HP.
enum TabTugas {
  ambil('Untuk Diambil'),
  diantar('Diantar'),
  selesai('Selesai'),
  gagal('Gagal/Kembali');

  final String label;
  const TabTugas(this.label);

  static TabTugas dari(BerkasEntity b) {
    if (b.perluDikembalikan) return TabTugas.gagal;
    return switch (b.status) {
      StatusBerkas.disiapkan || StatusBerkas.ditugaskan => TabTugas.ambil,
      StatusBerkas.diambil ||
      StatusBerkas.dalamPerjalanan ||
      StatusBerkas.tiba => TabTugas.diantar,
      StatusBerkas.gagalAntar || StatusBerkas.dibatalkan => TabTugas.gagal,
      _ => TabTugas.selesai,
    };
  }

  /// Tab yang butuh tindakan petugas (badge disorot).
  bool get perluTindakan => this != TabTugas.selesai;
}

class TugasTabLogic {
  TugasTabLogic._();

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
      jumlah[t] = jumlah[t]! + 1;
    }
    return jumlah;
  }
}
