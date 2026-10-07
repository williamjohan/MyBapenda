import '../../../../domain/entities/absensi/riwayat_absensi_entity.dart';

/// Jam MASUK/PULANG yang ditampilkan di layar absensi.
///
/// Aturan (permintaan user): scan valid paling awal hari itu = MASUK,
/// scan valid paling akhir = PULANG. Bila baru ada satu scan, PULANG kosong.
///
/// Catatan: server (rekap & PDF laporan) memakai aturan window jadwal,
/// jadi angka di sini bisa berbeda dengan laporan resmi.
class RekapHarian {
  final DateTime? masuk;
  final DateTime? pulang;
  final int jumlahScan;

  const RekapHarian({this.masuk, this.pulang, this.jumlahScan = 0});

  /// Menit terlambat terhadap jadwal "HH:mm", 0 bila tepat waktu / tak ada data.
  int menitTelat(String? jamMasukJadwal) {
    final jadwal = _jadwalPada(masuk, jamMasukJadwal);
    if (masuk == null || jadwal == null) return 0;
    final diff = masuk!.difference(jadwal).inMinutes;
    return diff > 0 ? diff : 0;
  }

  /// Menit pulang lebih cepat dari jadwal "HH:mm".
  int menitPulangCepat(String? jamPulangJadwal) {
    final jadwal = _jadwalPada(pulang, jamPulangJadwal);
    if (pulang == null || jadwal == null) return 0;
    final diff = jadwal.difference(pulang!).inMinutes;
    return diff > 0 ? diff : 0;
  }

  static DateTime? _jadwalPada(DateTime? hari, String? jam) {
    if (hari == null || jam == null) return null;
    final parts = jam.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return DateTime(hari.year, hari.month, hari.day, h, m);
  }
}

class RiwayatHarian {
  final DateTime tanggal;
  final List<RiwayatAbsensiEntity> items;

  RiwayatHarian({required this.tanggal, required this.items});

  RekapHarian get rekap => RekapHarianLogic.hitung(items, tanggal);
}

class RekapHarianLogic {
  const RekapHarianLogic._();

  /// Hitung dari daftar riwayat (urutan bebas). Scan ditolak diabaikan.
  static RekapHarian hitung(
    List<RiwayatAbsensiEntity> riwayat,
    DateTime tanggal,
  ) {
    final scans =
        riwayat
            .where((e) => e.isValid && _samaHari(e.tglPresensi, tanggal))
            .map((e) => e.tglPresensi)
            .toList()
          ..sort();

    if (scans.isEmpty) return const RekapHarian();
    return RekapHarian(
      masuk: scans.first,
      pulang: scans.length > 1 ? scans.last : null,
      jumlahScan: scans.length,
    );
  }

  /// Kelompokkan riwayat per tanggal, urutan hari & item dipertahankan
  /// (API mengirim terbaru di atas).
  static List<RiwayatHarian> kelompokkanPerHari(
    List<RiwayatAbsensiEntity> riwayat,
  ) {
    final groups = <RiwayatHarian>[];
    for (final item in riwayat) {
      final t = item.tglPresensi;
      final hari = DateTime(t.year, t.month, t.day);
      if (groups.isEmpty || groups.last.tanggal != hari) {
        groups.add(RiwayatHarian(tanggal: hari, items: [item]));
      } else {
        groups.last.items.add(item);
      }
    }
    return groups;
  }

  static bool _samaHari(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
