import 'package:bapendacore/domain/entities/va_qris/payment_method.dart';
import 'package:bapendacore/domain/entities/va_qris/payment_session_entity.dart';
import 'package:bapendacore/domain/entities/va_qris/tax_billing_entity.dart';
import 'package:bapendacore/domain/entities/va_qris/tax_period_entity.dart';

import '../../../../core/utils/va_qris_constants.dart';

/// TODO(tech-debt): SELURUH FILE INI DUMMY. Hapus setelah repository,
/// usecase, dan Cubit tersedia.
///
/// Skenario simulasi lewat awalan NOP:
/// - `00...`  : NOP tidak ditemukan
/// - `99...`  : wajib pajak patuh (hanya bulan ini yang belum dibayar)
/// - `88...`  : semua sudah lunas (tab "Belum Dibayar" kosong)
/// - lainnya  : ada tunggakan beberapa bulan dengan denda
abstract final class VaQrisMockData {
  static const int _monthlyPrincipal = 1250000;
  static const double _penaltyRatePerMonth = 0.02;

  static Future<TaxBillingEntity?> fetchBilling(String nop) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (nop.startsWith('00')) return null;

    final now = DateTime.now();
    final int firstUnpaidMonth;
    if (nop.startsWith('99')) {
      firstUnpaidMonth = now.month;
    } else if (nop.startsWith('88')) {
      firstUnpaidMonth = now.month + 1; // tidak ada yang belum dibayar
    } else {
      firstUnpaidMonth = now.month > 4 ? now.month - 3 : 1;
    }

    final periods = <TaxPeriodEntity>[
      for (var m = 1; m <= now.month; m++)
        _buildPeriod(now, m, firstUnpaidMonth),
    ];

    return TaxBillingEntity(
      nop: nop,
      taxpayerName: 'PT Sinar Reklame Nusantara',
      objectName: 'Reklame billboard 4 x 8 m',
      address: 'Jl. Raya Darmo No. 100, Wonokromo, Surabaya',
      taxType: 'Pajak Reklame',
      periods: periods,
    );
  }

  static TaxPeriodEntity _buildPeriod(
    DateTime now,
    int month,
    int firstUnpaid,
  ) {
    final dueDate = DateTime(now.year, month + 1, 0, 23, 59);
    if (month < firstUnpaid) {
      return TaxPeriodEntity(
        year: now.year,
        month: month,
        principal: _monthlyPrincipal,
        dueDate: dueDate,
        paidAt: DateTime(now.year, month, 10, 9, 30),
      );
    }

    var lateMonths = 0;
    if (now.isAfter(dueDate)) {
      lateMonths = (now.year - dueDate.year) * 12 + (now.month - dueDate.month);
      if (lateMonths < 1) lateMonths = 1;
      if (lateMonths > 24) lateMonths = 24;
    }

    return TaxPeriodEntity(
      year: now.year,
      month: month,
      principal: _monthlyPrincipal,
      penalty: (_monthlyPrincipal * _penaltyRatePerMonth * lateMonths).round(),
      lateMonths: lateMonths,
      dueDate: dueDate,
    );
  }

  static PaymentSessionEntity createSession({
    required TaxBillingEntity billing,
    required List<TaxPeriodEntity> selectedPeriods,
    required PaymentMethod method,
  }) {
    return _build(
      method: method,
      nop: billing.nop,
      taxpayerName: billing.taxpayerName,
      periods: selectedPeriods,
    );
  }

  /// Dipakai tombol "Buat ulang" saat waktu pembayaran habis.
  static PaymentSessionEntity regenerateSession(PaymentSessionEntity old) {
    return _build(
      method: old.method,
      nop: old.nop,
      taxpayerName: old.taxpayerName,
      periods: old.periods,
    );
  }

  static PaymentSessionEntity _build({
    required PaymentMethod method,
    required String nop,
    required String taxpayerName,
    required List<TaxPeriodEntity> periods,
  }) {
    final reference = 'TRX${DateTime.now().millisecondsSinceEpoch}';
    final total = periods.fold<int>(0, (sum, p) => sum + p.total);
    final isVa = method == PaymentMethod.vaBankJatim;

    return PaymentSessionEntity(
      reference: reference,
      method: method,
      nop: nop,
      taxpayerName: taxpayerName,
      periods: periods,
      createdAt: DateTime.now(),
      validFor: kDummyPaymentValidity,
      // DUMMY: nomor VA & payload QR bukan nilai valid. Aplikasi bank asli
      // tidak akan bisa membacanya sampai diganti data dari backend.
      vaNumber: isVa ? '7001${nop.substring(nop.length - 12)}' : null,
      qrisPayload: isVa ? null : 'DUMMY-QRIS|$reference|$total',
    );
  }
}
