import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:signalr_netcore/errors.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../../data/models/notifikasi/notifikasi_model.dart';
import '../../network/api_endpoints.dart';
import '../../network/bapenda_http_client.dart';
import '../../network/env_config/env_config.dart';
import '../../storage/app_secure_storage.dart';
import '../../utils/app_logger.dart';
import 'notifikasi_lokal.dart';

/// Entry point isolate foreground service (dipanggil plugin, termasuk saat
/// boot). Harus top-level + `vm:entry-point`.
@pragma('vm:entry-point')
void mulaiTaskNotifikasi() {
  FlutterForegroundTask.setTaskHandler(NotifikasiTaskHandler());
}

/// Kunci data yang dikirim ke isolate utama lewat `sendDataToMain`.
const kunciJumlahBelumDibaca = 'jumlahBelumDibaca';

/// Perintah isolate utama → task: kirim ulang nilai badge terakhir (app
/// dibuka lagi saat service sudah jalan, tanpa event baru).
const perintahMintaStatus = 'minta_status';

/// Menjaga koneksi SignalR `/hubs/notifikasi` selama service hidup (app
/// dibuka, di background, maupun ditutup), lalu menampilkan notifikasi
/// status bar untuk tiap event `NOTIF`. Kontrak: app TIDAK polling REST;
/// server mengirim snapshot saat connect/reconnect.
class NotifikasiTaskHandler extends TaskHandler {
  // Isolate terpisah: tanpa getIt, storage dibuat langsung (opsi sama
  // dengan register_module).
  final _storage = AppSecureStorage(const FlutterSecureStorage());

  HubConnection? _hub;
  bool _menyambung = false;
  int? _jumlahTerakhir;
  StreamSubscription<List<ConnectivityResult>>? _jaringan;

  Timer? _ulang;
  int _percobaanUlang = 0;

  /// Backoff sambung ulang setelah koneksi tertutup permanen (kontrak).
  static const _backoffDetik = [5, 15, 30, 60];

  /// null = negosiasi memilih (WebSocket). LongPolling dipakai bila
  /// WebSocket/SSE tersambung tapi tidak ada pesan sampai (nginx tanpa
  /// header Upgrade / buffering): `start()` gagal "Server timeout".
  HttpTransportType? _transport;
  static const _kunciLongPolling = 'notif_long_polling_sampai';
  static const _masaLongPolling = Duration(hours: 24);

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // DoH + sertifikat Bapenda juga untuk HttpClient/WebSocket SignalR.
    HttpOverrides.global = BapendaHttpOverrides();
    await NotifikasiLokal.init();

    // Ingat fallback LongPolling 24 jam supaya start berikutnya tidak
    // menunggu timeout 30 detik dulu; sesudahnya WebSocket dicoba lagi.
    final sampai = await FlutterForegroundTask.getData<int>(
      key: _kunciLongPolling,
    );
    if (sampai != null && DateTime.now().millisecondsSinceEpoch < sampai) {
      _transport = HttpTransportType.LongPolling;
    }

    _jaringan = Connectivity().onConnectivityChanged.listen((hasil) {
      final online = hasil.any((r) => r != ConnectivityResult.none);
      if (online && !_tersambung) _sambung();
    });
    await _sambung();
  }

  bool get _tersambung => _hub?.state == HubConnectionState.Connected;

  /// Tiap 60 detik: jaring pengaman bila semua percobaan lain terlewat.
  @override
  void onRepeatEvent(DateTime timestamp) {
    if (!_tersambung && _ulang == null) _sambung();
  }

  @override
  void onReceiveData(Object data) {
    if (data == perintahMintaStatus && _jumlahTerakhir != null) {
      _kirimKeMain(_jumlahTerakhir!);
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _ulang?.cancel();
    await _jaringan?.cancel();
    await _hub?.stop();
    _hub = null;
  }

  Future<void> _sambung() async {
    if (_menyambung || _tersambung) return;
    _menyambung = true;
    _ulang?.cancel();
    _ulang = null;
    HubConnection? hub;
    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.isEmpty) {
        // Sudah logout: service tidak berguna lagi.
        await FlutterForegroundTask.stopService();
        return;
      }

      await _hub?.stop();
      hub = HubConnectionBuilder()
          .withUrl(
            '${EnvConfig.baseUrl}${ApiEndpoints.notifikasiHub}',
            options: HttpConnectionOptions(
              accessTokenFactory: () async =>
                  await _storage.getAccessToken() ?? '',
              requestTimeout: 15000,
              transport: _transport,
            ),
          )
          .withAutomaticReconnect(retryDelays: [0, 2000, 10000, 30000])
          .build();
      hub.on('NOTIF', _terima);
      // Reconnect otomatis menyerah → coba start lagi dengan backoff.
      hub.onclose(({error}) => _jadwalUlang());
      await hub.start();
      _hub = hub;
      _percobaanUlang = 0;
      AppLogger.info(
        '🔔 SignalR notifikasi tersambung (${_transport?.name ?? 'auto'})',
      );
    } on HttpError catch (e) {
      AppLogger.warning('SignalR notifikasi ditolak: $e');
      // Token habis/tidak sah: berhenti; login berikutnya menyalakan lagi.
      if (e.statusCode == 401) {
        await FlutterForegroundTask.stopService();
      } else {
        _jadwalUlang();
      }
    } catch (e) {
      AppLogger.warning('SignalR notifikasi gagal tersambung: $e');
      if (_transport == null && '$e'.contains('Server timeout')) {
        _transport = HttpTransportType.LongPolling;
        await FlutterForegroundTask.saveData(
          key: _kunciLongPolling,
          value: DateTime.now().add(_masaLongPolling).millisecondsSinceEpoch,
        );
        // Koneksi gagal ditutup dulu; tanpa jeda, percobaan baru kena null
        // check dari sisa koneksi lama.
        try {
          await hub?.stop();
        } catch (_) {}
        await Future<void>.delayed(const Duration(seconds: 2));
        _menyambung = false;
        return _sambung();
      }
      // Offline / server mati: backoff (dan saat jaringan kembali).
      _jadwalUlang();
    } finally {
      _menyambung = false;
    }
  }

  void _jadwalUlang() {
    if (_ulang != null) return;
    final detik =
        _backoffDetik[_percobaanUlang.clamp(0, _backoffDetik.length - 1)];
    _percobaanUlang++;
    _ulang = Timer(Duration(seconds: detik), () {
      _ulang = null;
      _sambung();
    });
  }

  void _kirimKeMain(int jumlah) =>
      FlutterForegroundTask.sendDataToMain({kunciJumlahBelumDibaca: jumlah});

  Future<void> _terima(List<Object?>? args) async {
    final raw = args?.isNotEmpty == true ? args!.first : null;
    if (raw is! Map) return;
    try {
      final event = NotifEventModel.fromJson(Map<String, dynamic>.from(raw));
      _jumlahTerakhir = event.jumlahBelumDibaca;
      _kirimKeMain(event.jumlahBelumDibaca);

      // idTerakhirDitampilkan per NIP: cegah notifikasi dobel dari snapshot
      // berulang, tapi snapshot setelah offline memunculkan yang terlewat.
      final nip = (await _storage.getCurrentNip())?.trim() ?? '';
      final kunci = 'notif_id_terakhir_$nip';
      final idTerakhir = await FlutterForegroundTask.getData<int>(key: kunci);
      final hasil = NotifikasiTampil.proses(event, idTerakhir);
      if (hasil.idTerakhir != idTerakhir) {
        await FlutterForegroundTask.saveData(
          key: kunci,
          value: hasil.idTerakhir,
        );
      }
      for (final t in hasil.tampil) {
        await NotifikasiLokal.tampilkan(
          id: t.id,
          judul: t.judul,
          isi: t.isi,
          payload: t.payload,
        );
      }
    } catch (e, st) {
      AppLogger.error('Payload NOTIF tidak terbaca', e, st);
    }
  }
}

/// Isi notifikasi status bar dari satu event `NOTIF`.
class NotifikasiTampil {
  final int id;
  final String judul;
  final String isi;
  final String payload;

  const NotifikasiTampil(this.id, this.judul, this.isi, this.payload);

  /// Id notifikasi Android satu ruang dengan notifikasi foreground service
  /// (701) dan harus 32-bit: id inbox digeser ke >= 1000. Notifikasi
  /// "N berkas lain" memakai satu id tetap (yang baru menggantikan lama).
  static const idRingkasan = 1;
  static int idLokal(int idInbox) => 1000 + idInbox % 2000000000;

  /// Aturan:
  /// - tampilkan hanya item dengan `id > idTerakhir`, lalu idTerakhir = max;
  /// - idTerakhir belum ada (login pertama di perangkat): tidak tampil,
  ///   cukup catat max id;
  /// - SATU notifikasi status bar per berkas baru (keputusan user
  ///   2026-10-16, menggantikan ringkasan di kontrak); tap → detail berkas;
  /// - event baru dengan `jumlahBaru` > item yang dikirim (server maks 5):
  ///   tambah satu notifikasi "N berkas lain" yang membuka kotak masuk.
  static ({List<NotifikasiTampil> tampil, int idTerakhir}) proses(
    NotifEventModel event,
    int? idTerakhir,
  ) {
    final items = event.items.map((m) => m.toEntity()).toList();
    final maxId = items.fold<int>(
      idTerakhir ?? 0,
      (m, n) => n.id > m ? n.id : m,
    );
    if (idTerakhir == null) return (tampil: const [], idTerakhir: maxId);

    // Terlama dulu supaya urutan di status bar sesuai waktu masuk.
    final baru = items.where((n) => n.id > idTerakhir).toList()
      ..sort((x, y) => x.id.compareTo(y.id));
    final tampil = [
      for (final n in baru)
        NotifikasiTampil(
          idLokal(n.id),
          n.judul,
          n.isi,
          n.noResiBerkas != null
              ? PayloadBerkas.buat(n.id, n.noResiBerkas!)
              : NotifikasiLokal.payloadInbox,
        ),
    ];

    final sisa = event.snapshot ? 0 : event.jumlahBaru - baru.length;
    if (baru.isNotEmpty && sisa > 0) {
      tampil.add(
        NotifikasiTampil(
          idRingkasan,
          '$sisa berkas lain ditugaskan',
          'Buka kotak masuk untuk melihat semuanya.',
          NotifikasiLokal.payloadInbox,
        ),
      );
    }
    return (tampil: tampil, idTerakhir: maxId);
  }
}
