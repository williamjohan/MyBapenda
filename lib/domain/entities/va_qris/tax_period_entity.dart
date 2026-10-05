/// Satu masa pajak (per bulan) dari sebuah NOP.
///
/// TODO(tech-debt): DUMMY ENTITY. Nominal memakai `int` (Rupiah penuh) agar
/// sederhana; tentukan tipe final (int/Decimal) bersama kontrak API.
class TaxPeriodEntity {
  const TaxPeriodEntity({
    required this.year,
    required this.month,
    required this.principal,
    required this.dueDate,
    this.penalty = 0,
    this.lateMonths = 0,
    this.paidAt,
  });

  final int year;
  final int month;

  /// Pokok pajak.
  final int principal;

  /// Denda keterlambatan (0 jika tidak ada).
  final int penalty;

  /// Jumlah bulan keterlambatan, dipakai untuk label denda.
  final int lateMonths;

  final DateTime dueDate;

  /// Terisi jika masa pajak sudah lunas.
  final DateTime? paidAt;

  String get id => '$year-${month.toString().padLeft(2, '0')}';
  bool get isPaid => paidAt != null;
  bool get hasPenalty => penalty > 0;
  int get total => principal + penalty;
}
