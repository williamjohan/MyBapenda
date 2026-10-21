import 'package:mybapenda/core/constants/design_system/tokens/app_theme.dart';
import 'package:mybapenda/domain/entities/va_qris/tax_period_entity.dart';
import 'package:mybapenda/presentation/features/va_qris/widgets/billing/unpaid_period_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

TaxPeriodEntity _masa(int month) => TaxPeriodEntity(
  key: 'k$month',
  year: 2026,
  month: month,
  label: 'Bulan $month 2026',
  dueDate: DateTime(2026, month + 1, 10),
  lateMonths: 0,
  principal: 100000,
  total: 100000,
);

final _periods = [_masa(1), _masa(2), _masa(3)];

/// Daftar dengan pilihan disimpan di state lokal (meniru Cubit).
Future<Set<String>> _pump(WidgetTester tester, Set<String> initial) async {
  final keys = {...initial};
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.app,
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => UnpaidPeriodList(
            periods: _periods,
            selectedKeys: keys,
            onToggle: (p) => setState(() {
              if (!keys.remove(p.key)) keys.add(p.key!);
            }),
            onToggleAll: () => setState(() {
              final all = _periods.every((p) => keys.contains(p.key));
              keys
                ..clear()
                ..addAll(all ? const <String>{} : _periods.map((p) => p.key!));
            }),
          ),
        ),
      ),
    ),
  );
  return keys;
}

void main() {
  testWidgets('masa mana saja bisa dicentang, tanpa aturan berurutan', (
    tester,
  ) async {
    final keys = await _pump(tester, {'k1'});

    expect(find.textContaining('berurutan'), findsNothing);
    expect(find.text('Lunasi masa pajak sebelumnya dulu'), findsNothing);
    expect(find.text('1 dari 3 masa dipilih'), findsOneWidget);

    // Masa ke-3 langsung bisa dicentang (melompati ke-2)
    await tester.tap(find.text('Bulan 3 2026'));
    await tester.pump();
    expect(keys, {'k1', 'k3'});

    // Batal masa terlama: masa ke-3 tetap tercentang
    await tester.tap(find.text('Bulan 1 2026'));
    await tester.pump();
    expect(keys, {'k3'});
    expect(find.text('1 dari 3 masa dipilih'), findsOneWidget);
  });

  testWidgets('Pilih semua lalu Batal semua', (tester) async {
    final keys = await _pump(tester, {'k2'});

    expect(find.text('Pilih semua'), findsOneWidget);
    await tester.tap(find.text('Pilih semua'));
    await tester.pump();

    expect(keys, {'k1', 'k2', 'k3'});
    expect(find.text('3 dari 3 masa dipilih'), findsOneWidget);
    expect(find.text('Batal semua'), findsOneWidget);

    await tester.tap(find.text('Batal semua'));
    await tester.pump();

    expect(keys, isEmpty);
    expect(find.text('Pilih semua'), findsOneWidget);
  });
}
