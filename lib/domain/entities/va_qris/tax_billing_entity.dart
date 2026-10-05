import 'tax_period_entity.dart';

/// Tagihan pajak milik satu NOP (satu NOP = satu jenis pajak).
///
/// TODO(tech-debt): DUMMY ENTITY. Final-kan field setelah kontrak API siap.
class TaxBillingEntity {
  const TaxBillingEntity({
    required this.nop,
    required this.taxpayerName,
    required this.objectName,
    required this.address,
    required this.taxType,
    required this.periods,
  });

  final String nop;
  final String taxpayerName;
  final String objectName;
  final String address;
  final String taxType;
  final List<TaxPeriodEntity> periods;

  /// Belum dibayar, urut dari masa pajak TERLAMA. Urutan ini menjadi dasar
  /// aturan "bayar berurutan".
  List<TaxPeriodEntity> get unpaidPeriods {
    final list = periods.where((p) => !p.isPaid).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  /// Sudah dibayar pada tahun berjalan, terbaru di atas.
  List<TaxPeriodEntity> get paidPeriodsThisYear {
    final year = DateTime.now().year;
    final list = periods.where((p) => p.isPaid && p.year == year).toList()
      ..sort((a, b) => b.id.compareTo(a.id));
    return list;
  }
}
