// TODO: [FIREBASE_SETUP] Uncomment import di bawah jika google-services.json & Firebase Options sudah dikonfigurasi.
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/* 
=============================================================================
  [APP LOGGER & CRASHLYTICS FACADE] - CORE UTILITY
=============================================================================
  Fungsi Utama : Sentralisasi logging terminal (Debug) & Firebase Crashlytics (Release).
  Peruntukan   : Digunakan di seluruh layer (Data, Domain, Presentation).
  Aturan Ketat : DILARANG KERAS menggunakan print() atau memanggil FirebaseCrashlytics 
                 secara langsung di luar file ini! Setiap AppException atau Failure 
                 yang bersifat kritikal WAJIB dilempar menggunakan AppLogger.error().
  Author       : Software Architect (Diperbarui: 2026)
  WARNING      : Modifikasi logika di sini akan berdampak pada hilangnya jejak 
                 error atau bocornya data sensitif di production.
=============================================================================
*/

class AppLogger {
  // Cegah instansiasi (OOP Best Practice)
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5, // Tampilkan 5 baris stacktrace di terminal
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );

  /// Untuk informasi umum alur sistem.
  /// Di mode release, ini akan direkam sebagai "Breadcrumbs" di Crashlytics
  /// agar kita tahu jejak langkah user sebelum terjadi crash.
  static void info(String message) {
    if (kDebugMode) {
      _logger.i(message);
    } else {
      // TODO: [FIREBASE_SETUP] Uncomment baris di bawah jika Firebase Crashlytics sudah aktif
      // FirebaseCrashlytics.instance.log('[INFO] $message');
    }
  }

  /// Untuk proses debugging (contoh: Menampilkan output JSON).
  /// Hanya aktif di fase Development.
  static void debug(dynamic message) {
    _logger.d(message);
    if (!kDebugMode) {
      // TODO: [FIREBASE_SETUP] Uncomment baris di bawah jika Firebase Crashlytics sudah aktif
      // FirebaseCrashlytics.instance.log("🐛 [DEBUG]: $message");
    }
  }

  /// Untuk peringatan yang tidak mematikan sistem.
  static void warning(String message) {
    if (kDebugMode) {
      _logger.w(message);
    } else {
      // TODO: [FIREBASE_SETUP] Uncomment baris di bawah jika Firebase Crashlytics sudah aktif
      // FirebaseCrashlytics.instance.log('[WARNING] $message');
    }
  }

  /// 🚨 CRITICAL ERROR HANDLER
  /// Menangkap error, mencetak di terminal, dan melemparnya ke server Firebase.
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    // 1. Selalu cetak di terminal (berguna saat dicolok kabel)
    _logger.e(message, error: error, stackTrace: stackTrace);

    // 2. Lempar ke Dashboard Crashlytics HANYA jika bukan di mode Debug
    if (!kDebugMode) {
      // TODO: [FIREBASE_SETUP] Uncomment blok di bawah jika Firebase Crashlytics sudah aktif
      /*
      FirebaseCrashlytics.instance.recordError(
        error ?? message, // Kirim object error aslinya (DioException, TypeError, dll)
        stackTrace,       // Baris kode spesifik yang meledak
        reason: message,  // Pesan kustom kita (misal: "Gagal download dokumen")
        fatal: false,     // Set true HANYA jika error ini membuat aplikasi Force Close
      );
      */
    }
  }
}