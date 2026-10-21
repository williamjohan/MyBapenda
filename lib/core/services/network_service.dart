import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:mybapenda/core/utils/app_logger.dart'; 

@lazySingleton
class NetworkService {
  final Connectivity _connectivity = Connectivity();

  NetworkService(); // Constructor bersih tanpa logger

  /// Cek koneksi sekali jalan (untuk init)
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet)) {
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error("Network check error", e, StackTrace.current);
      return false;
    }
  }

  /// Stream untuk memantau perubahan koneksi secara real-time
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((
      List<ConnectivityResult> results,
    ) {
      return results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet);
    });
  }
}