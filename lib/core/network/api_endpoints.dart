class ApiEndpoints {
  // Private constructor agar tidak bisa di-instantiate (Best Practice)
  ApiEndpoints._();

  // ==========================================
  // AUTHENTICATION
  // ==========================================
  static const String login = '/api/auth/login';
  static const String refreshToken = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String validasiKontak = '/api/wajibpajak/validasi-kontak';
  static const String register = '/api/wajibpajak/buat-permohonan';

  // ==========================================
  // PROFILE
  // ==========================================
  static const String profile = '/api/profile';

  static const String historyList = '/api/cekreklame/lihat-history';
  static const String uploadReklame = '/api/cekreklame/upload-reklame';

  // ==========================================
  // ABSENSI PEGAWAI (SurabayaTaxApi - KantorController)
  // Wajib header HMAC X-App-*, lihat HmacKantorInterceptor.
  // ==========================================
  static const String kantorPrefix = '/api/kantor/';
  static const String absensiRingkasan = '/api/kantor/absensi/ringkasan';
  static const String absensiRiwayat = '/api/kantor/absensi/riwayat';
  static const String absensiAbsen = '/api/kantor/absensi/absen';
  static const String absensiLaporanPdf = '/api/kantor/absensi/laporan/pdf';

  // ==========================================
  // BALAI RW
  // ==========================================
  static const String masterPertanyaan = '/api/umpeg/master/pertanyaan';
  static const String masterKategori = '/api/umpeg/master/kategori';
  static const String rosterPegawai = '/api/umpeg/transaksi/roster';
  static const String laporanAbsensi = '/api/umpeg/transaksi/laporan';
  static const String checkin = '/api/umpeg/transaksi/checkin';
  static const String checkout = '/api/umpeg/transaksi/checkout';


  // ==========================================
  // SURVEY PERMOHONAN BARU
  // ==========================================
  static const String surveyPermohonanHeader = '/api/reklame/bo/simpan-survey';
  static const String surveyPermohonanDetail = '/api/reklame/bo/survey-form';
  static const String surveySimpan = '/api/reklame/bo/simpan-survey';
  static const String surveyCariNor = '/api/reklame/bo/cari-nor';
}
