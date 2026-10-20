/// Helper tampilan halaman pinpoint lokasi reklame.
class SurveyLokasiUiHelper {
  SurveyLokasiUiHelper._();

  /// "8 m", "350 m", "1,2 km".
  static String jarak(double meter) {
    if (meter < 1000) return '${meter.round()} m';
    final km = (meter / 1000).toStringAsFixed(1).replaceAll('.', ',');
    return '$km km';
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
