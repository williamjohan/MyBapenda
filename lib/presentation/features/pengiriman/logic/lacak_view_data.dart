import '../../../../core/utils/date_format_id.dart';
import '../../../../domain/entities/pengiriman/berkas_entity.dart';
import '../../../../domain/entities/pengiriman/jejak_entity.dart';
import '../../../../domain/entities/pengiriman/lacak_entity.dart';

typedef InfoBaris = ({String label, String value});
typedef InfoSeksi = ({String judul, List<InfoBaris> baris});

/// Data tampilan lacak berkas (gaya lacak paket), disatukan dari
/// `detail` (tugas petugas) maupun `lacak` bagian monitoring.
class LacakViewData {
  final String noResi;
  final JenisSurat jenis;
  final String jenisNama;
  final StatusBerkas status;
  final String statusNama;
  final DateTime? tglBatasSla;
  final bool terlambat;

  /// Kalimat singkat di bawah status (mis. "Diterima oleh ...").
  final String? ringkasan;
  final String namaWp;
  final String? alamatTujuan;
  final List<InfoSeksi> seksi;
  final List<JejakEntity> jejak;

  const LacakViewData({
    required this.noResi,
    required this.jenis,
    required this.jenisNama,
    required this.status,
    required this.statusNama,
    this.tglBatasSla,
    this.terlambat = false,
    this.ringkasan,
    required this.namaWp,
    this.alamatTujuan,
    this.seksi = const [],
    this.jejak = const [],
  });

  /// Monitoring diutamakan karena memuat foto jejak.
  static LacakViewData? fromLacak(LacakResultEntity r) {
    final m = r.monitoring, t = r.tugas;
    if (m != null) return LacakViewData.fromMonitoring(m);
    if (t != null) return LacakViewData.fromDetail(t);
    return null;
  }

  /// Seksi detail TIDAK mengulang yang sudah tampil di kartu status/list
  /// (status, no resi, jenis, nama WP, alamat tujuan, sisa SLA).
  factory LacakViewData.fromDetail(BerkasDetailEntity d) {
    final b = d.berkas;
    final ambil = _jejakAmbil(d.jejak);
    return LacakViewData(
      noResi: b.noResi,
      jenis: b.jenis,
      jenisNama: b.jenisNama,
      status: b.status,
      statusNama: b.statusNama,
      tglBatasSla: b.tglBatasSla,
      terlambat: b.terlambat,
      ringkasan: _ringkasan(b.status, d.namaPenerima, d.tglTerima),
      namaWp: b.namaWp,
      alamatTujuan: b.alamatTujuan,
      seksi: _seksi([
        (
          judul: 'Info Penerbitan',
          baris: [
            _b('No Surat', b.noSurat),
            _b('Tgl Terbit', _tgl(b.tglSurat)),
            _b('No SKPD', b.noReferensi),
            _b('NPWPD', b.npwpd),
            _b('Alamat WP', _beda(d.alamatWp, b.alamatTujuan)),
          ],
        ),
        (
          judul: 'Info Pengiriman',
          baris: [
            _b(
              'Peran Anda',
              b.penanggungJawab ? 'Penanggung jawab' : 'Anggota tim',
            ),
            _b('Tujuan Antar', b.jenisTujuan),
            _b('Diambil Oleh', ambil?.namaPetugas),
            _b('Tgl Ambil Berkas', _tglJam(ambil?.tglCheckin)),
            _b('Percobaan', b.percobaanKe > 1 ? 'Ke-${b.percobaanKe}' : null),
            _b(
              'Gagal Sebelumnya',
              b.jumlahGagal > 0 ? '${b.jumlahGagal}x' : null,
            ),
            _b('Boleh Ditempel', b.modeTempel ? 'Ya' : null),
            _b('Wajib Foto Objek', b.wajibFotoObjek ? 'Ya' : null),
          ],
        ),
        (
          judul: 'Info Penerimaan',
          baris: [
            _b('Cara Serah', d.caraSerah),
            _b('Penerima', d.namaPenerima),
            _b('Tgl Diterima', _tglJam(d.tglTerima)),
            _b('Batas Waktu Serah', _batas(b.tglBatasSla, b.terlambat)),
          ],
        ),
      ]),
      jejak: d.jejak,
    );
  }

  factory LacakViewData.fromMonitoring(MonitoringBerkasEntity m) {
    final ambil = _jejakAmbil(m.jejak);
    final percobaan = m.maksPercobaan == null
        ? (m.jumlahGagal > 0 ? '${m.jumlahGagal}x gagal' : null)
        : '${m.jumlahGagal} gagal dari maks ${m.maksPercobaan}';
    return LacakViewData(
      noResi: m.noResi,
      jenis: m.jenis,
      jenisNama: m.jenisNama,
      status: m.status,
      statusNama: m.statusNama,
      tglBatasSla: m.tglBatasSla,
      terlambat: m.terlambat,
      ringkasan: _ringkasan(m.status, null, m.tglTerima),
      namaWp: m.namaWp,
      alamatTujuan: m.alamatWp,
      seksi: _seksi([
        (
          judul: 'Info Penerbitan',
          baris: [
            _b('No Surat', m.noSurat),
            _b('Tgl Terbit', _tgl(m.tglSurat)),
            _b('Jatuh Tempo', _tgl(m.tglJatuhTempo)),
            _b('No SKPD', m.noReferensi),
            _b('NPWPD', m.npwpd),
          ],
        ),
        (
          judul: 'Info Pengiriman',
          baris: [
            _b('Petugas', _petugas(m.namaPetugas, m.nipPetugas)),
            _b('Wilayah (UPTB)', m.uptb),
            _b('Ditugaskan', _tglJam(m.tglDitugaskan)),
            _b('Tgl Ambil Berkas', _tglJam(ambil?.tglCheckin)),
            _b('Percobaan', m.jumlahGagal > 0 ? percobaan : null),
            _b('Boleh Ditempel', m.modeTempel ? 'Ya' : null),
            _b('No Resi Pos', m.noResiPos),
            _b('Tgl Kirim Pos', _tglJam(m.tglKirimPos)),
          ],
        ),
        (
          judul: 'Info Penerimaan',
          baris: [
            _b('Cara Serah', m.caraSerah),
            _b('Tgl Diterima', _tglJam(m.tglTerima)),
            _b('Batas Waktu Serah', _batas(m.tglBatasSla, m.terlambat)),
          ],
        ),
        (
          judul: 'Perlu Perhatian',
          baris: [
            _b('Tindakan', m.tindakan),
            _b('Review', m.perluReview ? 'Ada jejak perlu review' : null),
            _b('Fisik Surat', m.fisikBelumKembali ? 'Belum kembali' : null),
          ],
        ),
      ]),
      jejak: m.jejak,
    );
  }

  /// Check-in "Diambil" pertama (jejak urut terbaru di atas).
  static JejakEntity? _jejakAmbil(List<JejakEntity> jejak) {
    for (final j in jejak.reversed) {
      if (j.status == StatusBerkas.diambil && !j.belumTerkirim) return j;
    }
    return null;
  }

  /// Alamat WP hanya ditampilkan bila beda dengan alamat tujuan (kartu).
  static String? _beda(String? nilai, String? pembanding) =>
      nilai?.trim().toLowerCase() == pembanding?.trim().toLowerCase()
      ? null
      : nilai;

  static String? _batas(DateTime? batas, bool terlambat) {
    final t = _tglJam(batas);
    if (t == null) return null;
    return terlambat ? '$t (terlambat)' : t;
  }

  static String? _ringkasan(
    StatusBerkas status,
    String? penerima,
    DateTime? tglTerima,
  ) {
    if (status != StatusBerkas.diterima) return null;
    final oleh = (penerima?.trim().isNotEmpty ?? false)
        ? ' oleh $penerima'
        : '';
    final kapan = tglTerima == null ? '' : ' · ${_tglJam(tglTerima)}';
    return 'Surat diterima$oleh$kapan';
  }

  static InfoBaris? _b(String label, String? value) =>
      (value == null || value.trim().isEmpty)
      ? null
      : (label: label, value: value.trim());

  /// Buang baris kosong dan seksi tanpa baris.
  static List<InfoSeksi> _seksi(
    List<({String judul, List<InfoBaris?> baris})> mentah,
  ) => [
    for (final s in mentah)
      if (s.baris.whereType<InfoBaris>().isNotEmpty)
        (judul: s.judul, baris: s.baris.whereType<InfoBaris>().toList()),
  ];

  static String? _petugas(String? nama, String? nip) {
    if (nama == null || nama.trim().isEmpty) return nip;
    return nip == null ? nama : '$nama ($nip)';
  }

  static String? _tgl(DateTime? d) => d == null ? null : formatTanggalId(d);

  static String? _tglJam(DateTime? d) =>
      d == null ? null : '${formatTanggalId(d)} ${formatJamId(d)}';
}
