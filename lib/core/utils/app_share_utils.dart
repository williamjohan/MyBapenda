import 'package:share_plus/share_plus.dart';
import 'app_logger.dart'; // Sesuaikan

class AppShareUtils {
  AppShareUtils._();

  /// Membuka menu "Share" bawaan OS untuk membagikan file ke WA, Email, dll.
  static Future<void> shareFile(String filePath, {String? text}) async {
    try {
      // ignore: deprecated_member_use
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        text:
            text ??
            'Berikut adalah template dokumen yang diunduh dari aplikasi.',
      );

      // Mengecek status share
      if (result.status == ShareResultStatus.success) {
        AppLogger.info('✅ File berhasil dibagikan');
      } else if (result.status == ShareResultStatus.dismissed) {
        AppLogger.info('ℹ️ Batal membagikan file');
      }
    } catch (e) {
      AppLogger.error('❌ Gagal membagikan file: $filePath', e);
    }
  }

  /// Membuka menu "Share" bawaan OS untuk membagikan teks saja.
  static Future<void> shareText(String text, {String? subject}) async {
    try {
      // ignore: deprecated_member_use
      final result = await Share.share(text, subject: subject);

      if (result.status == ShareResultStatus.success) {
        AppLogger.info('✅ Teks berhasil dibagikan');
      } else if (result.status == ShareResultStatus.dismissed) {
        AppLogger.info('ℹ️ Batal membagikan teks');
      }
    } catch (e) {
      AppLogger.error('❌ Gagal membagikan teks', e);
    }
  }
}
