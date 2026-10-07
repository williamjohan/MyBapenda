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
import '../network/resilent_dns_resolver.dart';
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
        // 🚀 REFAKTOR: Timeout dipangkas menjadi taktis (mencegah loading muter abadi)
        connectTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 45),
        contentType: 'application/json',
      ),
    );

    // =========================================================================
    // 🛡️ ENGINE KONEKSI CUSTOM (Anti-Blokir & Anti-Hang)
    // =========================================================================
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 25);

        // Security Upgrade: Jangan terima semua sertifikat, batasi ke Bapenda saja.
        bool isCertBypassAllowed(String host) {
          final parsedBaseHost = Uri.tryParse(EnvConfig.baseUrl)?.host ?? '';
          const allowedHosts = [
            'apibapenda.surabaya.go.id',
            'drivebapenda.surabaya.go.id',
          ];
          return host == parsedBaseHost || allowedHosts.contains(host);
        }

        // Modifikasi alur pembuatan Socket untuk bypass DNS OS (Provider Seluler)
        client.connectionFactory =
            (Uri uri, String? proxyHost, int? proxyPort) async {
          final originalHost = uri.host;
          var targetHost = originalHost;

          try {
            // 1. Tembak DNS Custom (Google/Cloudflare via DoH) dgn budget 8 detik
            final resolvedIp = await ResilientDnsResolver.resolveIp(
              originalHost,
            ).timeout(const Duration(seconds: 8));
            if (resolvedIp != null) targetHost = resolvedIp;
          } catch (_) {}

          // 2. TCP Connect (Budget 8 detik untuk mencegah hang di Firewall)
          final connectTask = await Socket.startConnect(
            targetHost,
            uri.port,
          ).timeout(const Duration(seconds: 8));
          final rawSocket = await connectTask.socket;

          if (uri.scheme != 'https') {
            return ConnectionTask.fromSocket(
              Future.value(rawSocket),
              () => rawSocket.destroy(),
            );
          }

          try {
            // 3. TLS Handshake (Budget 8 detik)
            final secureSocket = await SecureSocket.secure(
              rawSocket,
              host: originalHost,
              onBadCertificate: (cert) => isCertBypassAllowed(originalHost),
            ).timeout(const Duration(seconds: 8));

            return ConnectionTask.fromSocket(
              Future.value(secureSocket),
              () => secureSocket.destroy(),
            );
          } catch (e) {
            rawSocket.destroy();
            rethrow;
          }
        };

        return client;
      },
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