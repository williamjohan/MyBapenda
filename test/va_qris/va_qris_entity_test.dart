import 'package:bapendacore/domain/entities/va_qris/payment_nominal_check_entity.dart';
import 'package:bapendacore/domain/entities/va_qris/payment_status_entity.dart';
import 'package:bapendacore/domain/entities/va_qris/tax_billing_entity.dart';
import 'package:bapendacore/domain/entities/va_qris/tax_period_entity.dart';
import 'package:bapendacore/domain/entities/va_qris/tax_type_entity.dart';
import 'package:bapendacore/presentation/features/va_qris/logic/period_selection_logic.dart';
import 'package:flutter_test/flutter_test.dart';

// Entity dibuat lewat fungsi (bukan const) agar instance berbeda dan
// perbandingan benar-benar memakai props Equatable, bukan identical.
TaxPeriodEntity _masa({int total = 100000}) => TaxPeriodEntity(
  key: 'k1',
  year: 2026,
  month: 9,
  label: 'September 2026',
  dueDate: DateTime(2026, 10, 31),
  lateMonths: 1,
  principal: 100000,
  total: total,
);

TaxBillingEntity _tagihan({String nama = 'PT Sumber Air'}) => TaxBillingEntity(
  taxTypeId: 6,
  taxType: 'Pajak Air Tanah',
  referenceLabel: 'NOP',
  referenceNumber: '35.78.010.001.902.00001',
  npwpd: 'P100',
  taxpayerName: nama,
  taxpayerAddress: 'Jl. Pemuda 1',
  objectName: 'Sumur Bor',
  address: 'Jl. Pemuda 1',
  unpaidPeriods: [_masa()],
  paidPeriods: const [],
);

TaxTypeEntity _jenis({String? mask}) => TaxTypeEntity(
  id: 6,
  name: 'Pajak Air Tanah',
  referenceLabel: 'NOP',
  hint: 'Contoh',
  digitsOnly: true,
  mask: mask,
);

void main() {
  group('kesetaraan entity (dipakai Cubit untuk deteksi perubahan state)', () {
    test('TaxPeriodEntity', () {
      expect(_masa(), _masa());
      expect(_masa(), isNot(_masa(total: 1)));
    });

    test('TaxBillingEntity', () {
      expect(_tagihan(), _tagihan());
      expect(_tagihan(), isNot(_tagihan(nama: 'CV Lain')));
    });

    test('TaxTypeEntity', () {
      expect(_jenis(mask: '##.##'), _jenis(mask: '##.##'));
      expect(_jenis(mask: '##.##'), isNot(_jenis()));
    });

    test('PaymentStatusEntity', () {
      expect(
        PaymentStatusEntity(isPaid: true, paidAt: DateTime(2026, 10, 15)),
        PaymentStatusEntity(isPaid: true, paidAt: DateTime(2026, 10, 15)),
      );
      expect(
        PaymentStatusEntity(isPaid: true, paidAt: DateTime(2026, 10, 15)),
        isNot(PaymentStatusEntity(isPaid: false, paidAt: DateTime(2026))),
      );
    });

    test('PaymentNominalCheckEntity', () {
      PaymentNominalCheckEntity check(bool qris) => PaymentNominalCheckEntity(
        vaAllowed: true,
        vaMessage: '',
        qrisAllowed: qris,
        qrisMessage: '',
      );

      expect(check(true), check(true));
      expect(check(true), isNot(check(false)));
    });
  });

  group('PeriodSelectionLogic', () {
    test('isSelected: masa ke-index sudah tercentang', () {
      expect(PeriodSelectionLogic.isSelected(0, 2), isTrue);
      expect(PeriodSelectionLogic.isSelected(2, 2), isFalse);
    });

    test('isEnabled: hanya masa terpilih + satu berikutnya bisa disentuh', () {
      expect(PeriodSelectionLogic.isEnabled(2, 2), isTrue);
      expect(PeriodSelectionLogic.isEnabled(3, 2), isFalse);
    });
  });
}
