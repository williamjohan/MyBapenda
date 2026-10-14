import '../../../domain/entities/pengiriman/antrean_entity.dart';
import '../../../domain/entities/pengiriman/berkas_entity.dart';
import '../../../domain/entities/pengiriman/jejak_entity.dart';

/// Tampilan sementara (optimistic) dari aksi yang masih di antrean:
/// status, tombol aksi, dan jejak "belum terkirim" diterapkan ke data
/// server/cache sampai antrean terkirim.
class PengirimanAntreanOverlay {
  PengirimanAntreanOverlay._();

  /// Cermin aturan tombol di server (`SuratKirim.AksiTersedia`).
  static List<AksiBerkas> aksiUntuk(StatusBerkas s, bool perluDikembalikan) =>
      switch (s) {
        StatusBerkas.ditugaskan => const [AksiBerkas.ambil],
        StatusBerkas.diambil || StatusBerkas.dalamPerjalanan => const [
          AksiBerkas.perjalanan,
          AksiBerkas.tiba,
          AksiBerkas.gagal,
        ],
        StatusBerkas.tiba => const [AksiBerkas.serah, AksiBerkas.gagal],
        StatusBerkas.gagalAntar => const [AksiBerkas.kembalikan],
        StatusBerkas.dibatalkan when perluDikembalikan => const [
          AksiBerkas.kembalikan,
        ],
        _ => const [],
      };

  static List<AntreanPengirimanEntity> _milik(
    String noResi,
    List<AntreanPengirimanEntity> menunggu,
  ) => menunggu.where((a) => a.noResi.contains(noResi)).toList();

  static BerkasEntity berkas(
    BerkasEntity b,
    List<AntreanPengirimanEntity> menunggu,
  ) {
    final milik = _milik(b.noResi, menunggu);
    if (milik.isEmpty) return b;

    var status = b.status;
    var perluKembali = b.perluDikembalikan;
    for (final a in milik) {
      status = a.jenis.statusSetelah;
      perluKembali = switch (a.jenis) {
        JenisAksiAntrean.gagal => true,
        JenisAksiAntrean.kembalikan || JenisAksiAntrean.serah => false,
        _ => perluKembali,
      };
    }
    return b.copyWith(
      status: status,
      statusNama: status.label,
      perluDikembalikan: perluKembali,
      aksi: aksiUntuk(status, perluKembali),
      antreanTertunda: milik.length,
    );
  }

  static BerkasDetailEntity detail(
    BerkasDetailEntity d,
    List<AntreanPengirimanEntity> menunggu,
  ) {
    final milik = _milik(d.berkas.noResi, menunggu);
    if (milik.isEmpty) return d;
    return d.copyWith(
      berkas: berkas(d.berkas, menunggu),
      jejak: [
        // Terbaru di atas, sama seperti jejak server.
        for (final a in milik.reversed)
          JejakEntity(
            status: a.jenis.statusSetelah,
            statusNama: a.jenis.label,
            tglCheckin: a.tglDibuat,
            keterangan: a.pesan == null
                ? 'Menunggu terkirim ke server.'
                : 'Menunggu terkirim: ${a.pesan}',
            belumTerkirim: true,
          ),
        ...d.jejak,
      ],
    );
  }
}
