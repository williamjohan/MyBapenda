import 'dart:io';
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import '../network/bapenda_http_client.dart';
import '../network/connectivity_check_interceptor.dart';
import '../network/dio_auth_interceptor.dart';
import '../network/hmac_kantor_interceptor.dart';
import '../network/env_config/env_config.dart';


@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @lazySingleton
  Dio getDio(
    // HmacSecurityInterceptor global telah dihapus; HMAC kini hanya untuk /api/kantor/*
    DioAuthInterceptor authInterceptor,
    HmacKantorInterceptor hmacKantorInterceptor,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.baseUrl, 
        connectTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 45),
        contentType: 'application/json',
      ),
    );

    // =========================================================================
    // 🛡️ ENGINE KONEKSI CUSTOM (Anti-Blokir & Anti-Hang)
    // =========================================================================
    // DoH + bypass sertifikat khusus host Bapenda (lihat bapenda_http_client.dart).
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => pasangKoneksiBapenda(HttpClient()),
    );

    // =========================================================================
    //  RANTAI INTERCEPTOR
    // =========================================================================

    // 1. ConnectivityCheck: Gagal paling awal jika tidak ada sinyal (Mode Pesawat).
    dio.interceptors.add(ConnectivityCheckInterceptor(Connectivity()));

    // 2. Smart Retry: Otomatis coba lagi jika RTO atau jaringan putus sesaat.
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 4),
        ],
        logPrint: (message) {
          if (kDebugMode) debugPrint('>>> [DIO RETRY] 🔄 $message');
        },
        retryEvaluator: (error, attempt) {
          // Jangan pernah me-retry request pengiriman file (FormData) jika sudah
          // setengah jalan, untuk mencegah duplikat data masuk ke database Bapenda.
          if (error.requestOptions.data is FormData) {
            return error.type == DioExceptionType.connectionError;
          }
          return DefaultRetryEvaluator({
            ...defaultRetryableStatuses,
            status408RequestTimeout,
          }).evaluate(error, attempt);
        },
      ),
    );

    // 3. HMAC: Header X-App-* khusus endpoint /api/kantor/* (absensi).
    //    Dipasang setelah Retry agar timestamp & signature dihitung ulang tiap percobaan.
    dio.interceptors.add(hmacKantorInterceptor);

    // 4. Auth: Masukkan Bearer Token Bapenda.
    dio.interceptors.add(authInterceptor);

    // 5. Chucker: Tampilkan log cantik di layar HP saat Debug.
    if (kDebugMode) {
      dio.interceptors.add(ChuckerDioInterceptor());
    }

    return dio;
  }
}