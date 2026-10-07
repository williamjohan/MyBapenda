import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

import '../services/app_integrity_service.dart';
import '../utils/app_logger.dart';
import 'api_endpoints.dart';

/// Menandatangani request ke `/api/kantor/*` (SurabayaTaxApi) dengan header HMAC.
///
/// Endpoint lain tidak disentuh. Rumus dari BE:
/// `X-App-Signature = base64(HMAC-SHA256(appId + timestamp, appKey))`,
/// timestamp = unix detik (toleransi server ±300 dtk).
///
/// `APP_SECRET_KEY` dibaca dari `.env` saat runtime (flutter_dotenv), bukan dari
/// `EnvConfig`, agar `env_config.g.dart` yang sudah di-commit tidak perlu
/// di-generate ulang. CI menulis `.env` dari secret `ENV_FILE`, jadi key ini
/// wajib ada di sana.
@lazySingleton
class HmacKantorInterceptor extends Interceptor {
  final AppIntegrityService _integrityService;

  HmacKantorInterceptor(this._integrityService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.path.startsWith(ApiEndpoints.kantorPrefix)) {
      return handler.next(options);
    }

    final appKey = dotenv.maybeGet('APP_SECRET_KEY') ?? '';
    if (appKey.isEmpty) {
      AppLogger.error(
        '🚨 APP_SECRET_KEY kosong di .env, request kantor akan ditolak server',
      );
      return handler.next(options);
    }

    final appId = await _integrityService.getAppId();
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toString();
    final signature = base64.encode(
      Hmac(
        sha256,
        utf8.encode(appKey),
      ).convert(utf8.encode('$appId$timestamp')).bytes,
    );

    options.headers.addAll({
      'X-App-Id': appId,
      'X-App-Key': appKey,
      'X-App-Timestamp': timestamp,
      'X-App-Signature': signature,
    });

    return handler.next(options);
  }
}
