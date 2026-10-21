import 'dart:convert';
import 'package:mybapenda/core/services/update_version_service.dart';
import 'package:mybapenda/core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

// Model Data Update
class UpdateInfo {
  final String version;
  final String changelog;
  final String downloadUrl;

  UpdateInfo({
    required this.version,
    required this.changelog,
    required this.downloadUrl,
  });
}

@lazySingleton
class UpdateService {
  final Dio _dio;
  final UpdateVersionService versionService;

  UpdateService(this._dio, this.versionService);

  Future<UpdateInfo?> getAvailableUpdate() async {
    try {
      final jsonUrl = dotenv.env['UPDATE_JSON_URL'] ?? '';

      AppLogger.info("Checking update status");
      AppLogger.debug("Update JSON URL: $jsonUrl");

      final response = await _dio.get(jsonUrl);

      AppLogger.debug("Raw response: ${response.data}");

      Map<String, dynamic> data;
      if (response.data is String) {
        data = jsonDecode(response.data);
      } else {
        data = Map<String, dynamic>.from(response.data);
      }

      final serverBuildNumber =
          int.tryParse(data['buildNumber'].toString()) ?? 0;

      AppLogger.debug("Server build number: $serverBuildNumber");

      final hasUpdate = await versionService.isUpdateAvailable(
        serverBuildNumber,
      );

      if (hasUpdate) {
        AppLogger.warning("New version found: ${data['versionName']}");

        return UpdateInfo(
          version: data['versionName'] ?? 'Unknown',
          changelog: data['changelog'] ?? '-',
          downloadUrl: data['url'] ?? '',
        );
      } else {
        AppLogger.info("App is up to date");
      }
    } catch (e, s) {
      AppLogger.error("Failed to get update info", e, s);
    }

    return null;
  }
}