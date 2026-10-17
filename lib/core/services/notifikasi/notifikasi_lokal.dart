import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notifikasi status bar (flutter_local_notifications). Tanpa DI karena juga
/// dipakai di isolate foreground service.
abstract final class NotifikasiLokal {
  static const _channelId = 'notifikasi_tugas';
  static const _channelNama = 'Tugas Petugas';
  static const _channelKet = 'Berkas pengiriman surat yang ditugaskan';

  /// Payload tap: `berkas:<id>:<noResi>` menandai dibaca lalu membuka detail
  /// berkas, `inbox` membuka kotak masuk.
  static const prefixBerkas = 'berkas:';
  static const payloadInbox = 'inbox';

  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init({void Function(String? payload)? onTap}) async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: onTap == null
          ? null
          : (respon) => onTap(respon.payload),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelNama,
            description: _channelKet,
            importance: Importance.high,
          ),
        );
  }

  /// Payload notifikasi yang membuka app dari kondisi tertutup (sekali).
  static Future<String?> payloadPembuka() async {
    final detail = await _plugin.getNotificationAppLaunchDetails();
    if (detail?.didNotificationLaunchApp != true) return null;
    return detail?.notificationResponse?.payload;
  }

  static Future<void> tampilkan({
    required int id,
    required String judul,
    required String isi,
    String? payload,
  }) => _plugin.show(
    id: id,
    title: judul,
    body: isi,
    payload: payload,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelNama,
        channelDescription: _channelKet,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(isi),
      ),
    ),
  );
}

/// Isi payload `berkas:<id>:<noResi>`.
class PayloadBerkas {
  final int id;
  final String noResi;

  const PayloadBerkas(this.id, this.noResi);

  static String buat(int id, String noResi) =>
      '${NotifikasiLokal.prefixBerkas}$id:$noResi';

  /// null bila bukan payload berkas atau rusak.
  static PayloadBerkas? parse(String payload) {
    if (!payload.startsWith(NotifikasiLokal.prefixBerkas)) return null;
    final isi = payload.substring(NotifikasiLokal.prefixBerkas.length);
    final pisah = isi.indexOf(':');
    if (pisah <= 0) return null;
    final id = int.tryParse(isi.substring(0, pisah));
    final noResi = isi.substring(pisah + 1).trim();
    if (id == null || noResi.isEmpty) return null;
    return PayloadBerkas(id, noResi);
  }
}
