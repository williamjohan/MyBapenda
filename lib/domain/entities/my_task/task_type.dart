/// Jenis tugas lapangan yang di-assign dari Back Office.
///
/// TODO(tech-debt): DUMMY ENTITY. Sesuaikan kode/enum dengan kontrak API BE.
enum TaskType {
  himbauanPembayaran('Himbauan Pembayaran', 'Himbauan'),
  teguranPembayaran('Teguran Pembayaran', 'Teguran'),
  silang('Silang', 'Silang'),
  unsilang('Unsilang', 'Unsilang'),
  bongkar('Bongkar', 'Bongkar'),
  pengawasanExisting('Pengawasan Existing', 'Pengawasan Existing'),
  pengawasanTemuanBaru('Pengawasan Temuan Baru', 'Temuan Baru');

  const TaskType(this.label, this.shortLabel);

  /// Nama lengkap (judul card/detail).
  final String label;

  /// Nama singkat (chip filter).
  final String shortLabel;
}
