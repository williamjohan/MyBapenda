class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String camera = '/camera';
  static const String map = '/map';
  static const String detail = '/detail';
  static const String login = '/login';
  static const String lupaPassword = '/lupa-password';
  static const String resetPassword = '/reset-password';
  static const String splashscreen = '/splashscreen';
  static const String results = '/reklame-results';
  static const String reklameDashboard = '/reklame-dashboard';
  static const String history = '/history';
  static const String surveyPermohonanBaru = '/survey-permohonan-baru';
  static const String surveySisi = '/survey-sisi';
  static const String surveyFoto = '/survey-foto';
  static const String surveyData = '/survey-data';
  static const String surveyReview = '/survey-review';
  static const String surveyInfo = '/survey-info';

  /// Absensi pegawai
  static const String absensi = '/absensi';
  static const String laporanKehadiran = '/laporan-kehadiran';

  /// VA & QRIS
  static const String nop = '/va-qris';
  static const String billing = '/va-qris/tagihan';
  static const String qris = '/va-qris/qris';
  static const String va = '/va-qris/va';
  static const String success = '/va-qris/sukses';

  /// Balai RW
  static const String balaiRw = '/balai-rw';
  static const String balaiRwAbsen = '/balai-rw-absen';
  static const String balaiRwLaporan = '/balai-rw-laporan';

  /// Pengiriman Surat
  static const String pengiriman = '/pengiriman';
  static const String pengirimanDetail = '/pengiriman/detail';
  static const String pengirimanLacak = '/pengiriman/pantau';
  static const String pengirimanLacakDetail = '/pengiriman/lacak';
  static const String pengirimanScan = '/pengiriman/scan';
  static const String pengirimanCheckin = '/pengiriman/checkin';
  static const String pengirimanSerah = '/pengiriman/serah';
  static const String pengirimanGagal = '/pengiriman/gagal';
  static const String pengirimanAntrean = '/pengiriman/antrean';

  /// App Link QR surat: `https://{host}:9191/lacak/{noResi}`.
  static const String lacakDeepLink = '/lacak/:kode';

  // MY TASK
  static const String myTask = '/my-task';
  static const String myTaskDetail = '/my-task/detail';
  static const String myTaskWork = '/my-task/kerjakan';
  static const String myTaskSuccess = '/my-task/terkirim';
}
