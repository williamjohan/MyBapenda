
class ApiEndpoints {
  ApiEndpoints._();

  // ==========================================
  // AUTHENTICATION
  // ==========================================
  static const String login = '/api/auth/login';
  static const String refreshToken = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String lupaPassword = '/api/auth/lupapassword';
  static const String resetPassword = '/api/auth/resetpassword';
  static const String validasiKontak = '/api/wajibpajak/validasi-kontak';
  static const String register = '/api/wajibpajak/buat-permohonan';

  // ==========================================
  // PROFILE
  // ==========================================
  static const String profile = '/api/profile';
  static const String profileGantiFoto = '/api/profile/ganti-foto';
  static const String profileKirimOtpKontak =
      '/api/profile/kontak/kirim-otp';
  static const String profileVerifikasiOtpKontak =
      '/api/profile/kontak/verifikasi-otp';

  static const String historyList = '/api/cekreklame/lihat-history';
  static const String uploadReklame = '/api/cekreklame/upload-reklame';

  // ==========================================
  // ABSENSI PEGAWAI
  // SurabayaTaxApi - KantorController
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
  static const String surveySummary = '/api/reklame/bo/header/summary';
  static const String surveyPermohonanHeader = '/api/reklame/bo/header';
  static const String surveyPermohonanDetail = '/api/reklame/bo/survey-form';
  static const String surveySimpan = '/api/reklame/bo/simpan-survey';
  static const String surveyCariNor = '/api/reklame/bo/cari-nor';
  static const String surveyPengaturanRadius =
      '/api/reklame/bo/pengaturan-radius-survey';
  static const String surveyHistory = '/api/reklame/bo/history-survey';
  static const String surveyHistoryDetail =
      '/api/reklame/bo/history-survey/detail';

  // ==========================================
  // CREATE VA & QRIS
  // ==========================================
  static const String pembayaranJenisPajak =
      '/api/pembayaran/jenis-pajak';
  static const String pembayaranTagihan = '/api/pembayaran/tagihan';
  static const String pembayaranCariObjek = '/api/pembayaran/cari-objek';
  static const String pembayaranCheckNominal =
      '/api/pembayaran/check-nominal';
  static const String pembayaranBayar = '/api/pembayaran/bayar';
  static const String pembayaranStatus = '/api/pembayaran/status';

  // ==========================================
  // MASTER DATA REKLAME
  // ==========================================
  static const String reklameMasterLokasiTertentu =
      '/api/reklame/master/lokasi-tertentu';
  static const String reklameMasterJenisReklame =
      '/api/reklame/master/jenis-reklame';
  static const String reklameMasterLetakReklame =
      '/api/reklame/master/letak-reklame';
  static const String reklameMasterStatusTanah =
      '/api/reklame/master/status-tanah';
  static const String reklameMasterSudutPandang =
      '/api/reklame/master/sudut-pandang';
  static const String reklameMasterPersil =
      '/api/reklame/master/persil';
  static const String reklameMasterJenisBangunan =
      '/api/reklame/master/jenis-bangunan';
  static const String reklameMasterNamaJalan =
      '/api/reklame/master/nama-jalan';
  static const String reklameMasterKecamatan =
      '/api/reklame/master/kecamatan';
  static const String reklameMasterKelurahan =
      '/api/reklame/master/kelurahan';
  static const String reklameMasterJenisProduk =
      '/api/reklame/master/jenis-produk';
  static const String reklameMasterPegawaiSurvey =
      '/api/reklame/master/pegawai-survey';
  static const String reklameMasterLokasiPenyelenggaraan =
      '/api/reklame/master/lokasi-penyelenggaraan';

  // ==========================================
  // PENGIRIMAN SURAT
  // CekReklameApi, Bearer NIP
  // ==========================================
  static const String pengirimanMaster = '/api/pengiriman/master';
  static const String pengirimanDaftar = '/api/pengiriman/daftar';
  static const String pengirimanDetail = '/api/pengiriman/detail';
  static const String pengirimanLacak = '/api/pengiriman/lacak';
  static const String pengirimanAmbil = '/api/pengiriman/ambil';
  static const String pengirimanPerjalanan = '/api/pengiriman/perjalanan';
  static const String pengirimanTiba = '/api/pengiriman/tiba';
  static const String pengirimanSerah = '/api/pengiriman/serah';
  static const String pengirimanGagal = '/api/pengiriman/gagal';
  static const String pengirimanKembalikan = '/api/pengiriman/kembalikan';

  /// `?key=`; tanpa header Authorization, key berlaku hari itu saja.
  static const String pengirimanFoto = '/api/pengiriman/foto';

  // ==========================================
  // NOTIFIKASI PETUGAS
  // CekReklameApi, Bearer NIP
  // ==========================================
  static const String notifikasiJumlahBelumDibaca =
      '/api/notifikasi/jumlah-belum-dibaca';
  static const String notifikasiInbox = '/api/notifikasi/inbox';
  static const String notifikasiBaca = '/api/notifikasi/baca';
  static const String notifikasiBacaSemua = '/api/notifikasi/baca-semua';

  /// Hub SignalR; token lewat query `access_token` (accessTokenFactory).
  static const String notifikasiHub = '/hubs/notifikasi';

  // ==========================================
  // GOOGLE ROUTES API
  // Rute motor di peta lacak.
  // ==========================================
  static const String googleRoutes =
      'https://routes.googleapis.com/directions/v2:computeRoutes';
}
