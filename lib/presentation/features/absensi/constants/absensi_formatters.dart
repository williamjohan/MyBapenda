import 'package:intl/intl.dart';

/// Format tampilan absensi. Butuh `initializeDateFormatting('id_ID')`
/// (dipanggil di main.dart).
class AbsensiFormatters {
  const AbsensiFormatters._();

  static const String jamKosong = '--:--:--';

  /// `Jumat, 2 Oktober 2026`
  static String tanggal(DateTime date) =>
      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);

  /// `07:33:01`, atau `--:--:--` bila null.
  static String jam(DateTime? date) =>
      date == null ? jamKosong : DateFormat('HH:mm:ss').format(date);

  /// `24 m` / `1,2 km`
  static String jarak(double meter) => meter < 1000
      ? '${meter.round()} m'
      : '${NumberFormat('#,##0.0', 'id_ID').format(meter / 1000)} km';
}
