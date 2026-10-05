import 'dart:io';
import 'package:dio/dio.dart';

/// ----------------------------------------------------------------------
/// [PAYLOAD REQUEST MODEL]
/// Model ini khusus digunakan untuk membungkus payload request saat
/// melakukan upload gambar reklame beserta koordinatnya ke server.
/// ----------------------------------------------------------------------
class CekReklameUploadRequest {
  final File file;
  final String latitude;
  final String longitude;
  final String alamat;

  CekReklameUploadRequest({
    required this.file,
    required this.latitude,
    required this.longitude,
    required this.alamat,
  });

  /// HELPER METHOD:
  /// Mengubah objek model ini langsung menjadi FormData (Multipart).
  /// Memindahkan logika perakitan kunci ('Latitude', 'File', dll) dari 
  /// Data Source ke dalam Model agar Data Source lebih bersih.
  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'Latitude': latitude,
      'Longitude': longitude,
      'Alamat': alamat,
      'File': await MultipartFile.fromFile(
        file.path,
        filename: 'reklame_capture.jpg', 
      ),
    });
  }
}