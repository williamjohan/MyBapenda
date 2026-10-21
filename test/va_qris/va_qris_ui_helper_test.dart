import 'package:mybapenda/domain/entities/va_qris/payment_method.dart';
import 'package:mybapenda/domain/entities/va_qris/payment_session_entity.dart';
import 'package:mybapenda/domain/entities/va_qris/tax_period_entity.dart';
import 'package:mybapenda/presentation/features/va_qris/utils/va_qris_ui_helper.dart';
import 'package:flutter_test/flutter_test.dart';

TaxPeriodEntity _masa(int month, {int year = 2026}) => TaxPeriodEntity(
  key: 'k$year$month',
  year: year,
  month: month,
  label: 'Bulan $month $year',
  principal: 100000,
  total: 100000,
);

PaymentSessionEntity _sesi(
  PaymentMethod method, {
  List<TaxPeriodEntity>? periods,
}) => PaymentSessionEntity(
  reference: 'KODE1',
  method: method,
  taxTypeId: 6,
  referenceLabel: 'NOP',
  referenceNumber: '35.78.010.001.902.00001',
  taxpayerName: 'PT  Sumber   Air',
  periods: periods ?? [_masa(7), _masa(8)],
  createdAt: DateTime(2026, 10, 16, 9, 50),
  validFor: const Duration(minutes: 15),
  total: 2525000,
  vaNumber: method == PaymentMethod.vaBankJatim ? '7001123456789012' : null,
  qrisPayload: method == PaymentMethod.qris ? '000201...' : null,
  nmid: method == PaymentMethod.qris ? 'ID2021112825553' : null,
);

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

  group('VaQrisUiHelper.nmid', () {
    test('kosong / null jadi null (baris NMID disembunyikan)', () {
      expect(VaQrisUiHelper.nmid(null), isNull);
      expect(VaQrisUiHelper.nmid('  '), isNull);
      expect(VaQrisUiHelper.nmid(' ID2021112825553 '), 'ID2021112825553');
    });
  });

  test('batasWaktu: tanggal & jam Indonesia', () {
    expect(
      VaQrisUiHelper.batasWaktu(DateTime(2026, 10, 16, 10, 5)),
      '16 Okt 2026 pukul 10:05',
    );
  });

  group('VaQrisUiHelper.daftarMasa', () {
    test('sampai 3 masa ditulis semua', () {
      expect(
        VaQrisUiHelper.daftarMasa(_sesi(PaymentMethod.qris)),
        'Bulan 7 2026, Bulan 8 2026',
      );
    });

    test('lebih dari 3 masa diringkas', () {
      final periods = [for (var m = 1; m <= 12; m++) _masa(m)];
      expect(
        VaQrisUiHelper.daftarMasa(_sesi(PaymentMethod.qris, periods: periods)),
        '12 masa (Bulan 1 2026 s.d. Bulan 12 2026)',
      );
    });
  });

  group('VaQrisUiHelper.teksBagikan', () {
    test('VA: berisi nomor VA, total, NOP & batas waktu', () {
      expect(
        VaQrisUiHelper.teksBagikan(_sesi(PaymentMethod.vaBankJatim)),
        'Pembayaran Pajak Daerah Kota Surabaya\n'
        '\n'
        'Wajib pajak: PT Sumber Air\n'
        'NOP: 35.78.010.001.902.00001\n'
        'Masa pajak: Bulan 7 2026, Bulan 8 2026\n'
        'Total bayar: Rp2.525.000\n'
        '\n'
        'Virtual Account Bank Jatim: 7001123456789012\n'
        'Bayar lewat m-banking, ATM, atau teller sebelum '
        '16 Okt 2026 pukul 10:05.',
      );
    });

    test('QRIS: pendamping gambar, tanpa nomor VA', () {
      final text = VaQrisUiHelper.teksBagikan(_sesi(PaymentMethod.qris));

      expect(text, contains('Total bayar: Rp2.525.000'));
      expect(
        text,
        endsWith(
          'Scan gambar QRIS dengan m-banking atau e-wallet sebelum '
          '16 Okt 2026 pukul 10:05.',
        ),
      );
      expect(text, isNot(contains('Virtual Account')));
    });
  });
}
