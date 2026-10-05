import 'package:bapendacore/domain/entities/va_qris/tax_period_entity.dart';

const List<String> _bulanPanjang = [
  '',
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

/// Label masa pajak berbahasa Indonesia, mis. "Oktober 2026".
/// (date_format_id.dart hanya punya nama bulan singkat.)
extension TaxPeriodLabel on TaxPeriodEntity {
  String get label => '${_bulanPanjang[month]} $year';
}
