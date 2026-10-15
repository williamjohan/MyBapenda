import 'package:bapendacore/domain/entities/pengiriman/berkas_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/jejak_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/lacak_entity.dart';
import 'package:bapendacore/presentation/features/pengiriman/utils/lacak_ui_helper.dart';
import 'package:flutter_test/flutter_test.dart';

const _berkas = BerkasEntity(
  noResi: 'HMB1',
  jenis: JenisSurat.himbauan,
  jenisNama: 'Himbauan',
  namaWp: 'PT Contoh',
  alamatTujuan: 'Jl. Pemuda 1',
  status: StatusBerkas.diterima,
  statusNama: 'Diterima',
  penanggungJawab: true,
);

List<String> _label(LacakViewData d, String judul) => d.seksi
    .firstWhere((s) => s.judul == judul)
    .baris
    .map((b) => b.label)
    .toList();

void main() {
  test('detail: tidak mengulang info kartu, info ambil dari jejak', () {
    final data = LacakViewData.fromDetail(
      BerkasDetailEntity(
        berkas: _berkas,
        alamatWp: 'jl. pemuda 1', // sama dengan alamat tujuan → disembunyikan
        namaPenerima: 'Budi',
        tglTerima: DateTime(2026, 10, 14, 9, 5),
        jejak: [
          JejakEntity(
            status: StatusBerkas.diterima,
            statusNama: 'Diterima',
            tglCheckin: DateTime(2026, 10, 14, 9, 5),
          ),
          JejakEntity(
            status: StatusBerkas.diambil,
            statusNama: 'Diambil',
            namaPetugas: 'Andi',
            tglCheckin: DateTime(2026, 10, 13, 8),
          ),
        ],
      ),
    );

    expect(data.ringkasan, 'Surat diterima oleh Budi · 14 Okt 2026 09:05');
    final semua = data.seksi.expand((s) => s.baris).map((b) => b.label);
    expect(semua, isNot(contains('Jenis')));
    expect(semua, isNot(contains('Nama WP')));
    expect(semua, isNot(contains('Alamat Tujuan')));
    expect(semua, isNot(contains('Alamat WP')));
    expect(data.seksi.any((s) => s.judul == 'Info Penerbitan'), isFalse);
    expect(_label(data, 'Info Pengiriman'), [
      'Peran Anda',
      'Diambil Oleh',
      'Tgl Ambil Berkas',
    ]);
    expect(_label(data, 'Info Penerimaan'), ['Penerima', 'Tgl Diterima']);
  });

  test('lacak: monitoring diutamakan; seksi tanpa isi tidak tampil', () {
    final data = LacakViewData.fromLacak(
      const LacakResultEntity(
        noResi: 'HMB1',
        monitoring: MonitoringBerkasEntity(
          noResi: 'HMB1',
          jenis: JenisSurat.teguran,
          jenisNama: 'Teguran',
          namaWp: 'PT Contoh',
          status: StatusBerkas.gagalAntar,
          statusNama: 'Gagal Antar',
          jumlahGagal: 1,
          maksPercobaan: 3,
        ),
        tugas: BerkasDetailEntity(berkas: _berkas),
      ),
    )!;

    expect(data.status, StatusBerkas.gagalAntar);
    expect(data.ringkasan, isNull);
    expect(data.seksi.map((s) => s.judul), ['Info Pengiriman']);
    expect(data.seksi.single.baris.single.value, '1 gagal dari maks 3');
  });

  test('lacak tanpa monitoring maupun tugas: null', () {
    expect(
      LacakViewData.fromLacak(const LacakResultEntity(noResi: 'X')),
      isNull,
    );
  });
}
