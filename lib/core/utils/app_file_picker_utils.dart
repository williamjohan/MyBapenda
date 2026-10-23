import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'app_image_compress_utils.dart';
import 'app_file_validator_utils.dart';
import 'app_logger.dart';

/* 
=============================================================================
  [APP FILE PICKER UTILS] (SINGLE SOURCE OF TRUTH)
=============================================================================
  Fungsi Utama : Satu-satunya gerbang untuk mengambil File (Gambar & Dokumen).
                 Otomatis menangani kompresi, konversi HEIC, dan validasi ukuran.
  Peruntukan   : Global (Semua form).
  Aturan Ketat : Selalu gunakan utils ini, jangan panggil image_picker/file_picker 
                 secara langsung di komponen UI!

  Author       : Tim Bapenda (Diperbarui: 2026)
  WARNING      : File `app_image_picker_utils.dart` sudah DIMUSNAHKAN.
=============================================================================
*/

class AppFilePickerUtils {
  static final ImagePicker _imagePicker = ImagePicker();

  /// ============================================================
  /// 1. PICK IMAGE (Kamera/Galeri) - Mendukung JPG, PNG, HEIC
  /// ============================================================
  static Future<File?> pickImage({
    required bool fromCamera,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    double? maxMbSize, // Opsional jika ingin divalidasi langsung
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        preferredCameraDevice: preferredCameraDevice,
      );

      if (pickedFile == null) return null; // User batal

      File file = File(pickedFile.path);
      final extension = path.extension(file.path).toLowerCase();

      // Validasi Ekstensi Gambar
      if (!['.jpg', '.jpeg', '.png', '.heic'].contains(extension)) {
        throw Exception(
          'Format tidak didukung. Harap gunakan JPG, PNG, atau HEIC.',
        );
      }

      // Lakukan Kompresi & Konversi (HEIC -> JPG)
      File? processedFile = await AppImageCompressUtils.compressAndConvert(
        file,
      );
      processedFile ??= file; // Fallback

      // Validasi Ukuran (Jika diberikan batasan)
      if (maxMbSize != null) {
        final isValid = AppFileValidatorUtils.isFileValid(
          processedFile,
          maxMbSize,
          'MB',
        );
        if (!isValid) {
          throw Exception(
            'Ukuran foto melebihi batas maksimal ($maxMbSize MB) setelah dikompresi.',
          );
        }
      }

      return processedFile;
    } catch (e) {
      AppLogger.error('❌ Gagal mengambil gambar', e);
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// ============================================================
  /// 2. PICK PDF ONLY (Strictly PDF untuk Dokumen Reklame dll)
  /// ============================================================
  static Future<File?> pickPdfOnly({double? maxMbSize}) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // MUTLAK HANYA PDF
        allowMultiple: false,
      );

      // Jika user membatalkan (cancel), result biasanya null atau files kosong
      if (result == null || result.files.isEmpty) return null;

      final pathString = result.files.single.path;

      File file = File(pathString!);

      final extension = path.extension(file.path).toLowerCase();
      if (extension != '.pdf') {
        throw Exception('File yang dipilih mutlak harus berformat PDF.');
      }

      // Validasi Ukuran
      if (maxMbSize != null) {
        final isValid = AppFileValidatorUtils.isFileValid(
          file,
          maxMbSize,
          'MB',
        );
        if (!isValid) {
          throw Exception(
            'Ukuran PDF melebihi batas maksimal ($maxMbSize MB).',
          );
        }
      }

      return file;
    } catch (e) {
      AppLogger.error('❌ Gagal memilih PDF', e);
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// ============================================================
  /// 3. PICK GENERAL DOCUMENT (Fleksibel untuk berbagai format)
  /// ============================================================
  static Future<File?> pickGeneralDocument({
    double? maxMbSize,
    // Parameter dinamis, default-nya mengizinkan dokumen perkantoran standar
    List<String> allowedExtensions = const [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
    ],
  }) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final pathString = result.files.single.path;
      File file = File(pathString!);

      // Hilangkan titik dari ekstensi (misal '.pdf' jadi 'pdf') untuk dicocokkan dengan list
      final extension = path
          .extension(file.path)
          .toLowerCase()
          .replaceAll('.', '');

      // Validasi Ekstensi Fleksibel
      if (!allowedExtensions.contains(extension)) {
        final allowedString = allowedExtensions.join(', ').toUpperCase();
        throw Exception(
          'Format tidak didukung. Harap gunakan format: $allowedString.',
        );
      }

      // Validasi Ukuran
      if (maxMbSize != null) {
        final isValid = AppFileValidatorUtils.isFileValid(
          file,
          maxMbSize,
          'MB',
        );
        if (!isValid) {
          throw Exception(
            'Ukuran dokumen melebihi batas maksimal ($maxMbSize MB).',
          );
        }
      }

      return file;
    } catch (e) {
      AppLogger.error('❌ Gagal memilih Dokumen Umum', e);
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
