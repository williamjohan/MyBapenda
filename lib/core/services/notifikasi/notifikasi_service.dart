import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/notifikasi/notifikasi_usecase.dart';
import '../../../routes/app_router.dart';
import '../../../routes/app_routes.dart';
import '../../utils/app_logger.dart';
import 'notifikasi_lokal.dart';
import 'notifikasi_sinyal.dart';
import 'notifikasi_task_handler.dart';

/// Sisi isolate utama notifikasi petugas:
/// - menyalakan / mematikan foreground service ([NotifikasiTaskHandler])
///   yang memegang koneksi SignalR, mengikuti status login;
/// - meneruskan nilai badge dari event hub ke [NotifikasiSinyal] (kontrak:
///   TIDAK polling REST, termasuk saat resume);
/// - membuka halaman sesuai notifikasi yang di-tap.
@lazySingleton
class NotifikasiService {
  final NotifikasiSinyal _sinyal;
  final NotifikasiUseCase _useCase;

  NotifikasiService(this._sinyal, this._useCase);

  static const _kunciTanyaBaterai = 'notif_tanya_baterai';

  bool _siap = false;
  bool _pembukaDiproses = false;
  bool _mulaiJalan = false;

  /// Dipanggil sekali di `main()` sebelum `runApp`.
  Future<void> siapkan() async {
    if (_siap || !Platform.isAndroid) return;
    _siap = true;

    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_dariTask);
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notifikasi_koneksi',
        channelName: 'Koneksi Notifikasi',
        channelDescription: 'Menjaga MyBapenda tetap menerima notifikasi tugas',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(60000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
    await NotifikasiLokal.init(onTap: buka);
  }

  /// Setelah login: minta izin, nyalakan service, buka notifikasi yang
  /// membuka app dari kondisi tertutup.
  Future<void> mulai() async {
    if (!_siap || _mulaiJalan) return;
    _mulaiJalan = true;
    try {
      // Bisa dipanggil sebelum runApp: tunggu frame pertama supaya dialog
      // izin & navigasi tap notifikasi punya Activity/router.
      await WidgetsBinding.instance.endOfFrame;
      AppLogger.info('🔔 Menyalakan service notifikasi');
      final izin = await FlutterForegroundTask.checkNotificationPermission();
      if (izin != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
      // Tanpa ini Doze memutus koneksi saat layar mati lama. Ditanya sekali
      // per instalasi supaya tidak mengganggu tiap app dibuka.
      final sudahTanya =
          await FlutterForegroundTask.getData<bool>(key: _kunciTanyaBaterai) ??
          false;
      if (!sudahTanya &&
          !await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.saveData(
          key: _kunciTanyaBaterai,
          value: true,
        );
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      // Sudah jalan (app dibuka ulang): koneksi dibiarkan; minta nilai badge
      // terakhir karena snapshot connect sudah lewat.
      if (await FlutterForegroundTask.isRunningService) {
        FlutterForegroundTask.sendDataToTask(perintahMintaStatus);
      } else {
        final hasil = await FlutterForegroundTask.startService(
          serviceId: 701,
          serviceTypes: [ForegroundServiceTypes.remoteMessaging],
          notificationTitle: 'MyBapenda aktif',
          notificationText: 'Siap menerima notifikasi tugas',
          callback: mulaiTaskNotifikasi,
        );
        // Gagal start tidak melempar exception, hanya hasil Failure.
        if (hasil is ServiceRequestFailure) {
          AppLogger.error('Service notifikasi gagal start', hasil.error);
        }
      }

      // Detail peluncuran tetap sama selama proses hidup: proses sekali.
      if (!_pembukaDiproses) {
        _pembukaDiproses = true;
        final payload = await NotifikasiLokal.payloadPembuka();
        if (payload != null) buka(payload);
      }
    } catch (e, st) {
      AppLogger.error('Gagal menyalakan service notifikasi', e, st);
    } finally {
      _mulaiJalan = false;
    }
  }

  /// Saat logout: putus koneksi supaya akun lama tidak menerima notifikasi.
  Future<void> berhenti() async {
    if (!_siap) return;
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }

  /// Payload tap notifikasi (lihat [NotifikasiLokal.prefixBerkas]).
  void buka(String? payload) {
    if (payload == null) return;
    final berkas = PayloadBerkas.parse(payload);
    if (berkas != null) {
      AppRouter.router.push(AppRoutes.pengirimanDetail, extra: berkas.noResi);
      // Kontrak: buka detail berkas, lalu tandai dibaca.
      _useCase.baca(berkas.id);
    } else {
      AppRouter.router.push(AppRoutes.notifikasi);
    }
  }

  void _dariTask(Object data) {
    if (data is! Map) return;
    final jumlah = data[kunciJumlahBelumDibaca];
    if (jumlah is int) _sinyal.terima(jumlahBelumDibaca: jumlah);
  }
}
