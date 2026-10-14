import 'package:image_picker/image_picker.dart';

import '../../../../core/services/geo_location_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../shared/utils/date_util.dart';
import '../../../shared/utils/foto_stamp_util.dart';
import '../../../shared/widgets/bt_image_compressor.dart';

/// Ambil foto kamera untuk aksi pengiriman (pola balai_rw):
/// kamera → cap waktu + koordinat → JPEG (±300 KB, server menolak > 2 MB).
class PengirimanFoto {
  PengirimanFoto._();

  static final _picker = ImagePicker();

  /// null bila dibatalkan.
  static Future<String?> ambil({
    required String judul,
    required String noResi,
    GeoPosition? lokasi,
  }) async {
    final shot = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (shot == null) return null;

    final now = DateTime.now();
    final stamped = await FotoStampUtil.stamp(
      sourcePath: shot.path,
      title: judul.toUpperCase(),
      lines: [
        noResi,
        '${DateUtil.hari(now)}, ${DateUtil.tanggal(now)} · ${DateUtil.jam(now)} WIB',
        if (lokasi != null)
          'Lat ${lokasi.latitude.toStringAsFixed(6)}, '
              'Long ${lokasi.longitude.toStringAsFixed(6)} '
              '(±${lokasi.akurasiMeter.round()} m)',
      ],
    );
    final out = await BtImageCompressor.toJpeg(stamped, maxBytes: 300 * 1024);
    AppLogger.debug('[Pengiriman] foto $judul siap: $out');
    return out;
  }
}
