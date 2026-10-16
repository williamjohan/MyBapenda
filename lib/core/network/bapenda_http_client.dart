import 'dart:io';

import 'env_config/env_config.dart';
import 'resilent_dns_resolver.dart';

/// Pasang aturan koneksi Bapenda ke [client]:
/// - DNS lewat DoH ([ResilientDnsResolver]) untuk bypass DNS provider seluler.
/// - Sertifikat bermasalah HANYA diterima untuk host Bapenda.
/// Dipakai Dio (register_module) dan [BapendaHttpOverrides] (SignalR di
/// isolate foreground service, yang tidak lewat Dio).
HttpClient pasangKoneksiBapenda(HttpClient client) {
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

        // WebSocket SignalR memakai skema ws/wss.
        if (uri.scheme != 'https' && uri.scheme != 'wss') {
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
}

/// Semua `HttpClient()` / `WebSocket.connect` di isolate ini memakai aturan
/// [pasangKoneksiBapenda]. Pasang lewat `HttpOverrides.global` HANYA di isolate
/// foreground service notifikasi.
class BapendaHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      // super (bukan HttpClient()) supaya tidak memanggil override ini lagi.
      pasangKoneksiBapenda(super.createHttpClient(context));
}
