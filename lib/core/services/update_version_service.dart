import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mybapenda/core/utils/app_logger.dart';

@lazySingleton
class UpdateVersionService {
  UpdateVersionService();

  Future<bool> isUpdateAvailable(int remoteBuildNumber) async {
    if (!Platform.isAndroid) return false;

    final packageInfo = await PackageInfo.fromPlatform();
    final localBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

    AppLogger.debug("Version check: local($localBuild) vs remote($remoteBuildNumber)");

    return remoteBuildNumber > localBuild;
  }
}