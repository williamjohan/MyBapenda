import '../../../../domain/entities/pengiriman/master_pengiriman_entity.dart';

/// Slot foto di form aksi; nama field multipart ditentukan di payload.
enum FotoSlot {
  ambil('Foto Pengambilan'),
  lokasi('Foto Lokasi'),
  serah('Foto Penyerahan'),
  tempel('Foto Surat Tertempel'),
  objek('Foto Objek Pajak'),
  gagal('Foto Bukti Gagal');

  final String label;
  const FotoSlot(this.label);
}

/// Aturan wajib isian form aksi (sesuai kontrak `POST serah/gagal/tiba`).
/// Mengembalikan pesan kesalahan pertama, atau null bila lengkap.
class AksiValidasi {
  AksiValidasi._();

  static String? tiba(Set<FotoSlot> foto) =>
      foto.contains(FotoSlot.lokasi) ? null : 'Foto lokasi wajib saat tiba.';

  static String? ambil({required int jumlahResi, required Set<FotoSlot> foto}) {
    if (jumlahResi == 0) return 'Scan minimal satu QR berkas.';
    if (!foto.contains(FotoSlot.ambil)) return 'Foto pengambilan wajib.';
    return null;
  }

  static String? serah({
    required CaraSerah? cara,
    required String namaPenerima,
    required int? idHubungan,
    required bool adaTtd,
    required bool wajibFotoObjek,
    required Set<FotoSlot> foto,
  }) {
    if (cara == null) return 'Pilih cara serah.';
    if (cara.butuhPenerima) {
      if (namaPenerima.trim().isEmpty) return 'Nama penerima wajib diisi.';
      if (idHubungan == null) return 'Pilih hubungan penerima.';
      if (!foto.contains(FotoSlot.serah)) return 'Foto penyerahan wajib.';
      if (!adaTtd) return 'Penerima belum tanda tangan.';
    } else {
      if (!foto.contains(FotoSlot.tempel)) {
        return 'Foto surat tertempel wajib.';
      }
      if (!foto.contains(FotoSlot.lokasi)) return 'Foto lokasi wajib.';
    }
    if (wajibFotoObjek && !foto.contains(FotoSlot.objek)) {
      return 'Foto objek pajak wajib untuk berkas ini.';
    }
    return null;
  }

  static String? gagal({
    required OpsiMasterEntity? alasan,
    required String keterangan,
    required Set<FotoSlot> foto,
  }) {
    if (alasan == null) return 'Pilih alasan gagal antar.';
    if (alasan.wajibKeterangan && keterangan.trim().isEmpty) {
      return 'Keterangan wajib untuk alasan "${alasan.nama}".';
    }
    if (!foto.contains(FotoSlot.gagal)) return 'Foto bukti gagal wajib.';
    return null;
  }
}
