import 'package:equatable/equatable.dart';

/// Satu masa pajak dari sebuah tagihan (Air Tanah: per bulan; Reklame: satu
/// SKPD). Nominal dalam Rupiah penuh.
class TaxPeriodEntity extends Equatable {
  const TaxPeriodEntity({
    required this.year,
    required this.month,
    required this.label,
    required this.principal,
    required this.total,
    this.key,
    this.dueDate,
    this.lateMonths = 0,
    this.penalty = 0,
    this.other = 0,
    this.otherLabel,
    this.discount = 0,
    this.isPaid = false,
    this.paidAt,
  });

  /// Dikirim ke API saat membuat kode bayar. null untuk masa yang sudah lunas.
  final String? key;

  final int year;

  /// Air Tanah: bulan masa pajak. Reklame: 0.
  final int month;

  /// Label masa pajak dari API, mis. "Oktober 2026".
  final String label;

  final DateTime? dueDate;

  /// Jumlah bulan lewat jatuh tempo, dipakai untuk label denda.
  final int lateMonths;

  /// Pokok pajak.
  final int principal;

  /// Denda keterlambatan (0 jika tidak ada).
  final int penalty;

  /// Komponen tambahan, mis. jaminan bongkar (Reklame).
  final int other;
  final String? otherLabel;

  /// Potongan (intensifikasi).
  final int discount;

  /// Total dari API: pokok + denda + lainnya - potongan.
  final int total;

  final bool isPaid;

  /// Terisi jika masa pajak sudah lunas.
  final DateTime? paidAt;

  bool get hasPenalty => penalty > 0;

  @override
  List<Object?> get props => [
    key,
    year,
    month,
    label,
    dueDate,
    lateMonths,
    principal,
    penalty,
    other,
    otherLabel,
    discount,
    total,
    isPaid,
    paidAt,
  ];
}
