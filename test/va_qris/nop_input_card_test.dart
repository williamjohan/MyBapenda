import 'package:bapendacore/core/constants/design_system/tokens/app_theme.dart';
import 'package:bapendacore/domain/entities/va_qris/tax_type_entity.dart';
import 'package:bapendacore/presentation/features/va_qris/widgets/nop/nop_input_card.dart';
import 'package:bapendacore/presentation/features/va_qris/widgets/nop/upper_case_text_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _reklame = TaxTypeEntity(
  id: 7,
  name: 'Pajak Reklame',
  referenceLabel: 'No SKPD',
  hint: 'Contoh: SKPD2026100001',
  digitsOnly: false,
);

const _airTanah = TaxTypeEntity(
  id: 6,
  name: 'Pajak Air Tanah',
  referenceLabel: 'NOP',
  hint: '18 digit NOP Air Tanah',
  digitsOnly: true,
  referenceLength: 18,
  mask: '##.##.###.###.###.#####',
);

/// Host dengan jenis pajak yang bisa diganti dari test.
class _Host extends StatefulWidget {
  const _Host({required this.controller, required this.initial});

  final TextEditingController controller;
  final TaxTypeEntity initial;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late TaxTypeEntity selected = widget.initial;

  void select(TaxTypeEntity type) => setState(() => selected = type);

  @override
  Widget build(BuildContext context) {
    return NopInputCard(
      controller: widget.controller,
      onSubmitted: () {},
      taxTypes: const [_airTanah, _reklame],
      selectedTaxType: selected,
      onTaxTypeChanged: select,
    );
  }
}

Future<TextEditingController> _pump(
  WidgetTester tester,
  TaxTypeEntity initial,
) async {
  final controller = TextEditingController();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.app,
      home: Scaffold(
        body: SingleChildScrollView(
          child: _Host(controller: controller, initial: initial),
        ),
      ),
    ),
  );
  return controller;
}

TextField _field(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField));

void main() {
  group('UpperCaseTextFormatter', () {
    TextEditingValue format(String text, {int? cursor}) =>
        UpperCaseTextFormatter().formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: cursor ?? text.length),
          ),
        );

    test('huruf kecil jadi kapital, kursor tetap', () {
      final result = format('skpd2026', cursor: 4);

      expect(result.text, 'SKPD2026');
      expect(result.selection, const TextSelection.collapsed(offset: 4));
    });

    test('teks yang sudah kapital / angka tidak diubah', () {
      expect(format('SKPD-2026/01').text, 'SKPD-2026/01');
    });
  });

  group('NopInputCard', () {
    testWidgets('No SKPD: keyboard teks, kapital, tanpa saran kata', (
      tester,
    ) async {
      final controller = await _pump(tester, _reklame);

      final field = _field(tester);
      expect(field.keyboardType, TextInputType.text);
      expect(field.textCapitalization, TextCapitalization.characters);
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);

      await tester.enterText(find.byType(TextField), 'skpd 2026a');
      expect(controller.text, 'SKPD2026A');
    });

    testWidgets('NOP: keyboard angka & titik otomatis', (tester) async {
      final controller = await _pump(tester, _airTanah);

      expect(_field(tester).keyboardType, TextInputType.number);

      await tester.enterText(find.byType(TextField), '357801000190200001');
      expect(controller.text, '35.78.010.001.902.00001');
    });

    testWidgets('ganti jenis pajak: field dibuat ulang dengan keyboard baru', (
      tester,
    ) async {
      await _pump(tester, _airTanah);
      final before = tester.state(find.byType(EditableText));
      expect(_field(tester).keyboardType, TextInputType.number);

      tester.state<_HostState>(find.byType(_Host)).select(_reklame);
      await tester.pump();

      expect(_field(tester).keyboardType, TextInputType.text);
      expect(tester.state(find.byType(EditableText)), isNot(same(before)));
    });
  });
}
