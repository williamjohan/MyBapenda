class AppConstants {
  AppConstants._();

  static const String appName = "MyBapenda";
  static const String btnLapor = "Laporkan Reklame";
  static const String btnKembali = "Kembali ke Beranda";
  static const String successReportTitle = "Laporan Terkirim";
  static const String successReportSub = "Terima kasih atas partisipasi Anda.";
  static const String errorReportTitle = "Laporan Gagal";
  static const String errorReportSub =
      "Terjadi kesalahan saat mengirim laporan. Silakan coba lagi nanti.";
  static const String noResultTitle = "Tidak Ada Reklame Ditemukan";
  static const String noResultSub =
      "Tidak ada papan reklame terdaftar di area ini. Jika Anda menemukan reklame di sini, silakan lapor.";
  static const String questionReportExpired =
      "Apakah Anda yakin ingin melaporkan reklame ini Expired?";
  static const String questionReportIlegal =
      "Apakah Anda yakin ingin melaporkan reklame ini sebagai Ilegal atau Tidak Sesuai?";
}

enum ReportType {
  ilegal(1, "Reklame Ilegal"),
  expired(2, "Reklame Expired");

  final int value;
  final String label;

  const ReportType(this.value, this.label);
}
