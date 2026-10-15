import 'package:bapendacore/domain/entities/pengiriman/berkas_entity.dart';
import 'package:bapendacore/presentation/features/pengiriman/utils/berkas_sla_ui_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 14, 10);

  SlaBerkas? hitung({
    DateTime? sla,
    StatusBerkas status = StatusBerkas.diambil,
    bool terlambat = false,
  }) => SlaBerkas.hitung(
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

  test('label aman & lewat tanpa batas', () {
    expect(hitung(sla: now.add(const Duration(days: 3)))!.label, 'SLA 3 hari');
    expect(
      hitung(sla: now.subtract(const Duration(minutes: 30)))!.label,
      'Lewat SLA 30 menit',
    );
  });

  test('entity: sla(now), perluPerhatian, masihTugas', () {
    final b = BerkasEntity(
      noResi: 'A',
      jenis: JenisSurat.himbauan,
      jenisNama: 'Himbauan',
      namaWp: 'WP',
      alamatTujuan: '-',
      status: StatusBerkas.diambil,
      statusNama: 'Diambil',
      tglBatasSla: now.add(const Duration(hours: 5)),
    );
    expect(b.sla(now)!.level, SlaLevel.mendekati);
    expect(b.perluPerhatian, isFalse);
    expect(b.copyWith(status: StatusBerkas.gagalAntar).perluPerhatian, isTrue);
    expect(b.masihTugas, isTrue);

    final diterima = b.copyWith(status: StatusBerkas.diterima);
    expect(diterima.masihTugas, isFalse);
    expect(diterima.copyWith(antreanTertunda: 1).masihTugas, isTrue);
    expect(diterima.copyWith(perluDikembalikan: true).masihTugas, isTrue);
  });
}
