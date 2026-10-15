import 'package:bapendacore/domain/entities/pengiriman/berkas_entity.dart';
import 'package:bapendacore/presentation/features/pengiriman/logic/berkas_sla_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 14, 10);

  SlaInfo? hitung({
    DateTime? sla,
    StatusBerkas status = StatusBerkas.diambil,
    bool terlambat = false,
  }) => BerkasSlaLogic.hitung(
    status: status,
    batasSla: sla,
    terlambat: terlambat,
    now: now,
  );

  test('tanpa batas SLA atau status final: tidak ada badge', () {
    expect(hitung(), isNull);
    expect(hitung(sla: now, status: StatusBerkas.diterima), isNull);
  });

  test('lewat tenggat: level lewat', () {
    final info = hitung(sla: now.subtract(const Duration(days: 2)))!;
    expect(info.level, SlaLevel.lewat);
    expect(info.label, 'Lewat SLA 2 hari');
  });

  test('flag terlambat dari server diutamakan', () {
    expect(
      hitung(sla: now.add(const Duration(days: 3)), terlambat: true)!.level,
      SlaLevel.lewat,
    );
    expect(hitung(terlambat: true)!.label, 'Lewat SLA');
  });

  test('sisa kurang dari 24 jam: level mendekati', () {
    final info = hitung(sla: now.add(const Duration(hours: 5)))!;
    expect(info.level, SlaLevel.mendekati);
    expect(info.label, 'Sisa 5 jam');
  });

  test('masih lama: level aman', () {
    expect(hitung(sla: now.add(const Duration(days: 3)))!.level, SlaLevel.aman);
  });
}
