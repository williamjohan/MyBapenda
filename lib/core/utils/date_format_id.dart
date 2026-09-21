const List<String> _bulanId = [
  '',
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

String formatTanggalId(DateTime date) {
  return '${date.day} ${_bulanId[date.month]} ${date.year}';
}

String formatJamId(DateTime date) {
  final h = date.hour.toString().padLeft(2, '0');
  final m = date.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String formatTanggalRelatifId(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = today.difference(target).inDays;

  final jam = formatJamId(date);
  if (diff == 0) return 'Hari ini / $jam';
  if (diff == 1) return 'Kemarin / $jam';
  return '${formatTanggalId(date)} / $jam';
}
