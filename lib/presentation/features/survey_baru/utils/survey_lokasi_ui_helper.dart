import '../cubit/survey_lokasi/survey_lokasi_state.dart';

/// Helper tampilan halaman pinpoint lokasi reklame.
class SurveyLokasiUiHelper {
  SurveyLokasiUiHelper._();

  /// "8 m", "350 m", "1,2 km".
  static String jarak(double meter) {
    if (meter < 1000) return '${meter.round()} m';
    final km = (meter / 1000).toStringAsFixed(1).replaceAll('.', ',');
    return '$km km';
  }

  /// Pin sisi yang sudah dipasang jadi di luar radius (radius mengecil
  /// setelah dipasang). Jarak dihitung saat pin dipasang.
  static bool diLuarRadius(SurveyLokasiHasil? lokasi, int radiusMeter) =>
      lokasi != null && lokasi.jarakMeter > radiusMeter;

  static final _polaJarak = RegExp(r'lebih dari\s+\d+\s*m dari lokasi petugas');
  static final _polaSisi = RegExp(r'sisi ke-(\d+)');

  /// Nomor sisi dari penolakan jarak `simpan-survey`, contoh "Titik reklame
  /// sisi ke-1 lebih dari 20 m dari lokasi petugas (jarak 34 m).". Null bila
  /// pesan lain.
  static int? sisiDiLuarRadius(String pesan) {
    if (!_polaJarak.hasMatch(pesan)) return null;
    final m = _polaSisi.firstMatch(pesan);
    return m == null ? null : int.tryParse(m.group(1)!);
  }

  /// Baris tebal di kartu alamat: bagian pertama alamat (nama jalan).
  static ({String judul, String detail}) alamat(String? alamat) {
    final a = (alamat ?? '').trim();
    if (a.isEmpty || a == '-') {
      return (
        judul: 'Alamat tidak ditemukan',
        detail: 'Koordinat tetap tersimpan.',
      );
    }
    final i = a.indexOf(', ');
    return (judul: i < 0 ? a : a.substring(0, i), detail: a);
  }
}
