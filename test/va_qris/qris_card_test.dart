import 'package:mybapenda/core/constants/design_system/tokens/app_theme.dart';
import 'package:mybapenda/domain/entities/va_qris/payment_method.dart';
import 'package:mybapenda/domain/entities/va_qris/payment_session_entity.dart';
import 'package:mybapenda/domain/entities/va_qris/tax_period_entity.dart';
import 'package:mybapenda/presentation/features/va_qris/widgets/payment/qris_code_card.dart';
import 'package:mybapenda/presentation/features/va_qris/widgets/payment/qris_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PaymentSessionEntity _sesi({String? nmid}) => PaymentSessionEntity(
  reference: 'QR1',
  method: PaymentMethod.qris,
  taxTypeId: 6,
  referenceLabel: 'NOP',
  referenceNumber: '35.78.010.001.902.00001',
  taxpayerName: 'PT Sumber Air',
  periods: const [
    TaxPeriodEntity(
      key: 'k1',
      year: 2026,
      month: 9,
      label: 'September 2026',
      principal: 100000,
      total: 100000,
    ),
  ],
  createdAt: DateTime(2026, 10, 16, 9, 50),
  validFor: const Duration(minutes: 15),
  total: 100000,
  qrisPayload: '00020101021226670016ID.CO.QRIS.WWW',
  nmid: nmid,
);

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.app,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  group('QrisCodeCard', () {
    testWidgets('NMID dari API tampil, tidak ada "dummy"', (tester) async {
      await _pump(
        tester,
        QrisCodeCard(
          session: _sesi(nmid: 'ID2021112825553'),
          isExpired: false,
          onRegenerate: () {},
        ),
      );

      expect(find.text('NMID: ID2021112825553'), findsOneWidget);
      expect(find.textContaining('dummy'), findsNothing);
    });

    testWidgets('NMID kosong: barisnya disembunyikan', (tester) async {
      await _pump(
        tester,
        QrisCodeCard(session: _sesi(), isExpired: false, onRegenerate: () {}),
      );

      expect(find.textContaining('NMID'), findsNothing);
    });
  });

  testWidgets('QrisShareCard: QR, NMID, data WP, total & batas waktu', (
    tester,
  ) async {
    await _pump(tester, QrisShareCard(session: _sesi(nmid: 'ID2021112825553')));

    expect(find.text('Bapenda Kota Surabaya'), findsOneWidget);
    expect(find.text('NMID: ID2021112825553'), findsOneWidget);
    expect(find.text('PT Sumber Air'), findsOneWidget);
    expect(find.text('35.78.010.001.902.00001'), findsOneWidget);
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('Rp100.000'), findsOneWidget);
    expect(find.text('Berlaku sampai 16 Okt 2026 pukul 10:05'), findsOneWidget);
  });
}
