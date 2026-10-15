import 'package:bapendacore/presentation/features/va_qris/utils/va_qris_ui_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VaQrisUiHelper.teks', () {
    test('kosong / null / spasi saja tampil "-"', () {
      expect(VaQrisUiHelper.teks(''), '-');
      expect(VaQrisUiHelper.teks(null), '-');
      expect(VaQrisUiHelper.teks('   '), '-');
    });

    test('spasi beruntun dirapikan & tepi di-trim', () {
      expect(
        VaQrisUiHelper.teks(' MULYOREJO     No.24 RT/RW:-/- '),
        'MULYOREJO No.24 RT/RW:-/-',
      );
    });

    test('teks normal tidak berubah', () {
      expect(
        VaQrisUiHelper.teks('CENTRAL LAUNDRY SURABAYA'),
        'CENTRAL LAUNDRY SURABAYA',
      );
    });
  });

  group('VaQrisUiHelper.nomorReferensi', () {
    test('No SKPD tampil nomornya saja', () {
      expect(
        VaQrisUiHelper.nomorReferensi('No SKPD', 'SKPD2026100001'),
        'SKPD2026100001',
      );
    });

    test('NOP tetap dengan label', () {
      expect(
        VaQrisUiHelper.nomorReferensi('NOP', '35.78.051.002.908.01977'),
        'NOP 35.78.051.002.908.01977',
      );
    });
  });
}
