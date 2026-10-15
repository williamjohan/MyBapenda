import '../../../../domain/entities/pengiriman/berkas_entity.dart';

/// Filter cepat di halaman Pantau.
enum PantauFilter {
  semua('Semua'),
  menunggu('Belum Diambil'),
  diantar('Sedang Diantar'),
  tiba('Tiba di Tujuan'),
  diterima('Diterima'),
  bermasalah('Perlu Perhatian');

  final String label;
  const PantauFilter(this.label);

  bool cocok(BerkasEntity b) => switch (this) {
    PantauFilter.semua => true,
    PantauFilter.menunggu =>
      b.status == StatusBerkas.disiapkan || b.status == StatusBerkas.ditugaskan,
    PantauFilter.diantar =>
      b.status == StatusBerkas.diambil ||
          b.status == StatusBerkas.dalamPerjalanan,
    PantauFilter.tiba => b.status == StatusBerkas.tiba,
    // Sudah diserahterimakan ke WP (termasuk yang masih di antrean HP).
    PantauFilter.diterima => b.status == StatusBerkas.diterima,
    PantauFilter.bermasalah => b.perluPerhatian,
  };
}

/// Tahap progres ringkas di kartu (gaya lacak paket).
enum TahapKirim {
  ditugaskan('Ditugaskan'),
  diambil('Diambil'),
  diantar('Diantar'),
  diterima('Diterima');

  final String label;
  const TahapKirim(this.label);
}

class PantauUiHelper {
  PantauUiHelper._();

  /// Indeks tahap yang sudah dicapai; null bila alur terputus
  /// (gagal/dibatalkan/dikembalikan) sehingga progres tidak ditampilkan.
  static int? tahap(StatusBerkas s) => switch (s) {
    StatusBerkas.disiapkan || StatusBerkas.ditugaskan => 0,
    StatusBerkas.diambil => 1,
    StatusBerkas.dalamPerjalanan || StatusBerkas.tiba => 2,
    StatusBerkas.diterima || StatusBerkas.dikirimViaPos => 3,
    _ => null,
  };

  /// Cari di no resi, nama WP, no surat, NPWPD, alamat (tidak peka huruf).
  static List<BerkasEntity> filter(
    List<BerkasEntity> semua,
    PantauFilter f,
    String query,
  ) {
    final q = query.trim().toLowerCase();
    return semua.where((b) {
      if (!f.cocok(b)) return false;
      if (q.isEmpty) return true;
      return [
        b.noResi,
        b.namaWp,
        b.noSurat,
        b.npwpd,
        b.alamatTujuan,
      ].any((v) => v?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  static Map<PantauFilter, int> hitung(List<BerkasEntity> semua) => {
    for (final f in PantauFilter.values) f: semua.where(f.cocok).length,
  };
}
