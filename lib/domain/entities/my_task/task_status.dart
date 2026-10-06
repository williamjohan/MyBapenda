/// TODO(tech-debt): DUMMY. Status final & cara BE menentukannya (termasuk
/// kedaluwarsa otomatis berdasarkan deadline) menunggu kontrak payload.
enum TaskStatus {
  aktif('Aktif'),
  selesai('Selesai'),
  kedaluwarsa('Kedaluwarsa');

  const TaskStatus(this.label);

  final String label;
}
