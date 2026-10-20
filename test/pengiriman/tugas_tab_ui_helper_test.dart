import 'package:bapendacore/domain/entities/pengiriman/berkas_entity.dart';
import 'package:bapendacore/presentation/features/pengiriman/utils/tugas_tab_ui_helper.dart';
import 'package:flutter_test/flutter_test.dart';

BerkasEntity _b(
  String noResi,
  StatusBerkas status, {
  bool perluDikembalikan = false,
  String namaWp = 'WP',
}) => BerkasEntity(
  noResi: noResi,
  jenis: JenisSurat.himbauan,
  jenisNama: 'Himbauan',
  namaWp: namaWp,
  alamatTujuan: '-',
  status: status,
  statusNama: status.label,
  perluDikembalikan: perluDikembalikan,
);

void main() {
  final semua = [
    _b('HMB1', StatusBerkas.ditugaskan, namaWp: 'Toko Maju'),
    _b('HMB2', StatusBerkas.tiba),
    _b('TGR3', StatusBerkas.gagalAntar),
    _b('TGR4', StatusBerkas.dibatalkan, perluDikembalikan: true),
    _b('SKB5', StatusBerkas.diterima),
    _b('SKB6', StatusBerkas.diambil, perluDikembalikan: true),
  ];

  test('pembagian tab per status, perluDikembalikan selalu ke Gagal', () {
    expect(TugasTabUiHelper.hitung(semua), {
      TabTugas.ambil: 1,
      // SKB5 sudah diterima di server: bukan tugas lagi (hanya di Pantau).
      TabTugas.diantar: 1,
      TabTugas.gagal: 3,
    });
  });

  test('final di server disembunyikan; yang masih di antrean HP tampil', () {
    final diterima = _b('A', StatusBerkas.diterima);
    final kembali = _b('B', StatusBerkas.dikembalikan);
    expect(TabTugas.dari(diterima), isNull);
    expect(TabTugas.dari(kembali), isNull);
    expect(
      TabTugas.dari(diterima.copyWith(antreanTertunda: 1)),
      TabTugas.diantar,
    );
    expect(TabTugas.dari(kembali.copyWith(antreanTertunda: 1)), TabTugas.gagal);
    expect(TugasTabUiHelper.filter([diterima], TabTugas.diantar, ''), isEmpty);
  });

  test('cari no resi / nama WP tanpa peka huruf, tetap dalam tab', () {
    expect(
      TugasTabUiHelper.filter(
        semua,
        TabTugas.ambil,
        'maju',
      ).map((b) => b.noResi),
      ['HMB1'],
    );
    expect(TugasTabUiHelper.filter(semua, TabTugas.gagal, 'tgr').length, 2);
    expect(TugasTabUiHelper.filter(semua, TabTugas.diantar, 'HMB1'), isEmpty);
  });
}
