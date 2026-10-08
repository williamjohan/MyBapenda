// lib/presentation/shared/utils/bapenda_date.dart
import 'package:flutter/material.dart' show TimeOfDay;

class DateUtil {
  DateUtil._();

  static const _hari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const _bulan = [
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

  /// Senin
  static String hari(DateTime d) => _hari[d.weekday - 1];

  /// 5 Oktober 2026
  static String tanggal(DateTime d) =>
      '${d.day} ${_bulan[d.month - 1]} ${d.year}';

  /// 08.05
  static String jam(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}.${d.minute.toString().padLeft(2, '0')}';

  /// 08.05 dari TimeOfDay
  static String jamOf(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

  /// "08.05" atau "08:05" -> TimeOfDay (null kalau format salah)
  static TimeOfDay? parseJam(String s) {
    final p = s.trim().split(RegExp(r'[.:]'));
    if (p.length < 2) return null;
    final h = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    if (h == null || m == null || h > 23 || m > 59) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  /// 2026-10-05
  static String iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
