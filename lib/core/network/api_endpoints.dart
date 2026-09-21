class ApiEndpoints {
  // Private constructor agar tidak bisa di-instantiate (Best Practice)
  ApiEndpoints._();

  // ==========================================
  // AUTHENTICATION
  // ==========================================
  static const String login = '/api/auth/login';
  static const String refreshToken = '/api/auth/refresh';
  static const String logout = '/auth/logout'; 
  static const String validasiKontak = '/api/wajibpajak/validasi-kontak';
  static const String register = '/api/wajibpajak/buat-permohonan';


  static const String historyList = '/api/cekreklame/lihat-history';
}
