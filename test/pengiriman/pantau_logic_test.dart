import 'package:bapendacore/domain/entities/pengiriman/berkas_entity.dart';
import 'package:bapendacore/presentation/features/pengiriman/logic/pantau_logic.dart';
import 'package:flutter_test/flutter_test.dart';

BerkasEntity _b(
  String noResi,
  StatusBerkas status, {
  bool terlambat = false,
  bool perluDikembalikan = false,
}) => BerkasEntity(
  noResi: noResi,
  jenis: JenisSurat.himbauan,
  jenisNama: 'Himbauan',
  namaWp: 'WP $noResi',
  alamatTujuan: 'Jl. Pemuda',
  status: status,
  statusNama: status.label,
  terlambat: terlambat,
  perluDikembalikan: perluDikembalikan,
);

void main() {
  final semua = [
    _b('A1', StatusBerkas.ditugaskan),
    _b('A2', StatusBerkas.tiba, terlambat: true),
    _b('A3', StatusBerkas.dalamPerjalanan),
    _b('A4', StatusBerkas.gagalAntar, perluDikembalikan: true),
  ];

  test('jumlah per filter; terlambat juga masuk Perlu Perhatian', () {
    expect(PantauLogic.hitung(semua), {
      PantauFilter.semua: 4,
      PantauFilter.menunggu: 1,
      PantauFilter.diantar: 2,
      PantauFilter.bermasalah: 2,
    });
  });

  test('filter + cari', () {
    expect(
      PantauLogic.filter(
        semua,
        PantauFilter.diantar,
        'a3',
      ).map((b) => b.noResi),
      ['A3'],
    );
    expect(PantauLogic.filter(semua, PantauFilter.semua, 'pemuda').length, 4);
  });

  test('tahap progres; alur terputus tanpa progres', () {
    expect(PantauLogic.tahap(StatusBerkas.ditugaskan), 0);
    expect(PantauLogic.tahap(StatusBerkas.tiba), 2);
    expect(PantauLogic.tahap(StatusBerkas.diterima), 3);
    expect(PantauLogic.tahap(StatusBerkas.gagalAntar), isNull);
  });
}
