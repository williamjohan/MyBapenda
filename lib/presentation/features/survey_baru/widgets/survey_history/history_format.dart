import 'package:bapendacore/presentation/shared/widgets/status_chip.dart';
import 'package:flutter/material.dart';

class HistoryFmt {
  HistoryFmt._();

  static const _short = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  static const _long = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String _p(int n) => n.toString().padLeft(2, '0');

  /// 14 Okt 2026
  static String tanggal(DateTime? d) =>
      d == null ? '-' : '${d.day} ${_short[d.month - 1]} ${d.year}';

  /// 14 Okt 2026, 14:35
  static String tanggalJam(DateTime? d) =>
      d == null ? '-' : '${tanggal(d)}, ${_p(d.hour)}:${_p(d.minute)}';

  /// Oktober 2026
  static String bulanTahun(DateTime d) => '${_long[d.month - 1]} ${d.year}';

  /// 1 Okt – 14 Okt 2026 (tahun hanya ditulis sekali kalau sama).
  static String range(DateTimeRange r) {
    if (r.start.year == r.end.year) {
      return '${r.start.day} ${_short[r.start.month - 1]} – ${tanggal(r.end)}';
    }
    return '${tanggal(r.start)} – ${tanggal(r.end)}';
  }

  /// 3.0 -> "3", 2.5 -> "2,5"
  static String angka(double v) => v == v.roundToDouble()
      ? v.toInt().toString()
      : v.toString().replaceAll('.', ',');

  static String? ukuran(double? p, double? l, double? t) {
    if (p == null || l == null || t == null) return null;
    return '${angka(p)} × ${angka(l)} × ${angka(t)} m';
  }

  static BapendaStatusTone toneOf(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'disetujui':
        return BapendaStatusTone.success;
      case 'ditolak':
        return BapendaStatusTone.danger;
      case 'penilaian':
        return BapendaStatusTone.info;
      case 'survey':
      case 'diproses':
        return BapendaStatusTone.warning;
      default:
        return BapendaStatusTone.neutral;
    }
  }
}
