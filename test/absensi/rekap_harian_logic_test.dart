import 'package:bapendacore/domain/entities/absensi/riwayat_absensi_entity.dart';
import 'package:bapendacore/presentation/features/absensi/logic/rekap_harian_logic.dart';
import 'package:flutter_test/flutter_test.dart';

RiwayatAbsensiEntity _scan(DateTime t, {bool valid = true}) =>
    RiwayatAbsensiEntity(
      tglPresensi: t,
      jenisDevice: 1,
      sumber: SumberAbsensi.online,
      isValid: valid,
    );

void main() {
  final hari = DateTime(2026, 10, 2);

  test('scan paling awal = MASUK, paling akhir = PULANG', () {
    final rekap = RekapHarianLogic.hitung([
      _scan(DateTime(2026, 10, 2, 12, 5)),
      _scan(DateTime(2026, 10, 2, 7, 33, 1)),
      _scan(DateTime(2026, 10, 2, 6, 10, 22)),
      _scan(DateTime(2026, 10, 1, 17)), // hari lain diabaikan
    ], hari);

    expect(rekap.masuk, DateTime(2026, 10, 2, 6, 10, 22));
    expect(rekap.pulang, DateTime(2026, 10, 2, 12, 5));
    expect(rekap.jumlahScan, 3);
  });

  test('satu scan: PULANG kosong', () {
    final rekap = RekapHarianLogic.hitung([
      _scan(DateTime(2026, 10, 2, 7)),
    ], hari);

    expect(rekap.masuk, DateTime(2026, 10, 2, 7));
    expect(rekap.pulang, isNull);
  });

  test('scan ditolak tidak dihitung', () {
    final rekap = RekapHarianLogic.hitung([
      _scan(DateTime(2026, 10, 2, 5), valid: false),
      _scan(DateTime(2026, 10, 2, 7)),
      _scan(DateTime(2026, 10, 2, 18), valid: false),
    ], hari);

    expect(rekap.masuk, DateTime(2026, 10, 2, 7));
    expect(rekap.pulang, isNull);
  });

  test('menit telat & pulang cepat terhadap jadwal', () {
    final rekap = RekapHarian(
      masuk: DateTime(2026, 10, 2, 7, 45),
      pulang: DateTime(2026, 10, 2, 16),
    );

    expect(rekap.menitTelat('07:30'), 15);
    expect(rekap.menitPulangCepat('16:30'), 30);
    expect(rekap.menitTelat(null), 0);
    expect(const RekapHarian().menitTelat('07:30'), 0);
  });

  test('kelompokkan per hari mempertahankan urutan', () {
    final groups = RekapHarianLogic.kelompokkanPerHari([
      _scan(DateTime(2026, 10, 2, 16)),
      _scan(DateTime(2026, 10, 2, 7)),
      _scan(DateTime(2026, 10, 1, 16)),
    ]);

    expect(groups, hasLength(2));
    expect(groups.first.tanggal, hari);
    expect(groups.first.items, hasLength(2));
    expect(groups.last.tanggal, DateTime(2026, 10, 1));
  });
}
