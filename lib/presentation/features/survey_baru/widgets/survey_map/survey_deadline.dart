import 'package:flutter/material.dart';

enum DeadlineLevel { late, today, soon, safe, unknown }

typedef DeadlineStyle = ({String text, Color fg, Color bg});

class SurveyDeadline {
  SurveyDeadline._();

  static const _bulan = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'mei': 5,
    'jun': 6,
    'jul': 7,
    'agu': 8,
    'agt': 8,
    'sep': 9,
    'okt': 10,
    'nov': 11,
    'des': 12,
  };

  /// Format API: "16 Okt 2026". Return null kalau tidak terbaca.
  static DateTime? parse(String s) {
    final p = s.trim().split(RegExp(r'\s+'));
    if (p.length != 3) return null;
    final d = int.tryParse(p[0]);
    final m = _bulan[p[1].toLowerCase()];
    final y = int.tryParse(p[2]);
    if (d == null || m == null || y == null) return null;
    return DateTime(y, m, d);
  }

  static int? daysLeft(DateTime? exp) {
    if (exp == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return exp.difference(today).inDays;
  }

  static DeadlineLevel level(int? days) {
    if (days == null) return DeadlineLevel.unknown;
    if (days < 0) return DeadlineLevel.late;
    if (days == 0) return DeadlineLevel.today;
    if (days <= 3) return DeadlineLevel.soon;
    return DeadlineLevel.safe;
  }

  static DeadlineStyle styleOf(int? days) {
    const red = Color(0xFFD81A48);
    const redBg = Color(0xFFFDECEF);
    switch (level(days)) {
      case DeadlineLevel.late:
        return (text: 'Terlambat ${-days!} hari', fg: red, bg: redBg);
      case DeadlineLevel.today:
        return (text: 'Batas hari ini', fg: red, bg: redBg);
      case DeadlineLevel.soon:
        return (
          text: 'Sisa $days hari',
          fg: const Color(0xFFB8680F),
          bg: const Color(0xFFFFF4E5),
        );
      case DeadlineLevel.safe:
        return (
          text: 'Sisa $days hari',
          fg: const Color(0xFF1B7F4B),
          bg: const Color(0xFFE8F5EE),
        );
      case DeadlineLevel.unknown:
        return (
          text: 'Tenggat -',
          fg: const Color(0xFF7B8794),
          bg: const Color(0xFFF5F6F8),
        );
    }
  }
}
