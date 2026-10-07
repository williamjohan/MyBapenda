import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../storage/app_secure_storage.dart';

/// Identitas perangkat yang dikirim saat absen (device binding di server).
class DeviceIdentity {
  final String kodeDevice;
  final String namaDevice;
  final String merkModel;
  final String osVersion;
  final String appVersion;

  const DeviceIdentity({
    required this.kodeDevice,
    required this.namaDevice,
    required this.merkModel,
    required this.osVersion,
    required this.appVersion,
  });
}

abstract class DeviceIdentityService {
  Future<DeviceIdentity> getIdentity();
}

@LazySingleton(as: DeviceIdentityService)
class DeviceIdentityServiceImpl implements DeviceIdentityService {
  final AppSecureStorage _secureStorage;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  DeviceIdentityServiceImpl(this._secureStorage);

  DeviceIdentity? _cached;

  @override
  Future<DeviceIdentity> getIdentity() async {
    if (_cached != null) return _cached!;

    final kodeDevice = await _getOrCreateKodeDevice();
    final packageInfo = await PackageInfo.fromPlatform();

    String model = '';
    String merk = '';
    String os = '';

    if (Platform.isAndroid) {
      final info = await _deviceInfo.androidInfo;
      model = info.model;
      merk = info.manufacturer;
      os = 'Android ${info.version.release}';
    } else if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      model = info.utsname.machine;
      merk = 'Apple';
      os = '${info.systemName} ${info.systemVersion}';
    }

    _cached = DeviceIdentity(
      kodeDevice: kodeDevice,
      namaDevice: _limit('Ponsel $model', 100),
      merkModel: _limit('$merk $model'.trim(), 100),
      osVersion: _limit(os, 50),
      appVersion: _limit(packageInfo.version, 20),
    );
    return _cached!;
  }

  /// UUID v4 dibuat sekali saat pertama absen lalu dipakai terus.
  Future<String> _getOrCreateKodeDevice() async {
    final existing = await _secureStorage.getKodeDevice();
    if (existing != null && existing.isNotEmpty) return existing;

    final generated = const Uuid().v4();
    await _secureStorage.saveKodeDevice(generated);
    return generated;
  }

  String _limit(String value, int max) =>
      value.length <= max ? value : value.substring(0, max);
}
