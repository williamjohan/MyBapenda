import 'package:mybapenda/data/models/pengiriman/berkas_model.dart';
import 'package:mybapenda/data/models/pengiriman/lacak_model.dart';
import 'package:mybapenda/data/models/pengiriman/master_pengiriman_model.dart';
import 'package:mybapenda/data/models/pengiriman/pengiriman_json_util.dart';
import 'package:mybapenda/domain/entities/pengiriman/berkas_entity.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _berkasJson() => {
  'noResi': 'HMB2610000123',
  'jenisKode': 'HMB',
  'jenisNama': 'Himbauan',
  'noSurat': '973/123',
  'tglSurat': '2026-10-10T00:00:00',
  'noReferensi': 'SKPD-1',
  'npwpd': 'P1234',
  'namaWp': 'PT Contoh',
  'statusId': 4,
  'status': 'Dalam Perjalanan',
  'modeTempel': true,
  'percobaanKe': 2,
  'jumlahGagal': 1,
  'alamatTujuan': 'Jl. Pemuda 1',
  'latTujuan': -7.25,
  'longTujuan': 112,
  'tglBatasSla': '2026-10-20T16:00:00',
  'terlambat': false,
  'perluDikembalikan': false,
  'wajibFotoObjek': true,
  'penanggungJawab': true,
  'aksi': ['TIBA', 'GAGAL', 'TIDAK_DIKENAL'],
};

void main() {
  test('BerkasItem: enum, koordinat, aksi tak dikenal dibuang', () {
    final e = BerkasModel.fromJson(_berkasJson()).toEntity();

    expect(e.jenis, JenisSurat.himbauan);
    expect(e.status, StatusBerkas.dalamPerjalanan);
    expect(e.longTujuan, 112.0);
    expect(e.punyaKoordinat, isTrue);
    expect(e.tglBatasSla, DateTime(2026, 10, 20, 16));
    expect(e.aksi, [AksiBerkas.tiba, AksiBerkas.gagal]);
    expect(e.boleh(AksiBerkas.serah), isFalse);
    expect(e.penanggungJawab, isTrue);
  });

  test('BerkasItem: field opsional kosong tidak membuat parsing gagal', () {
    final e = BerkasModel.fromJson({'noResi': 'X'}).toEntity();

    expect(e.namaWp, '-');
    expect(e.jenis, JenisSurat.lainnya);
    expect(e.status, StatusBerkas.ditugaskan);
    expect(e.statusNama, 'Ditugaskan');
    expect(e.aksi, isEmpty);
    expect(e.punyaKoordinat, isFalse);
  });

  test('detail: field berkas rata + jejak terbaru di atas', () {
    final d = BerkasDetailModel.fromJson({
      ..._berkasJson(),
      'alamatWp': 'Jl. WP',
      'caraSerah': 1,
      'jejak': [
        {'statusId': 3, 'tglCheckin': '2026-10-14T08:00:00'},
        {
          'statusId': 4,
          'status': 'Dalam Perjalanan',
          'tglCheckin': '2026-10-14T09:00:00',
          'jumlahFoto': 2,
          'diabaikan': true,
        },
        {'statusId': 2},
      ],
    }).toEntity();

    expect(d.berkas.noResi, 'HMB2610000123');
    expect(d.alamatWp, 'Jl. WP');
    expect(d.caraSerah, '1');
    expect(d.jejak.map((j) => j.status), [
      StatusBerkas.dalamPerjalanan,
      StatusBerkas.diambil,
      StatusBerkas.ditugaskan,
    ]);
    expect(d.jejak.first.jumlahFoto, 2);
    expect(d.jejak.first.diabaikan, isTrue);
    expect(d.jejak.first.foto, isEmpty);
  });

  test('lacak: monitoring dengan foto jejak', () {
    final r = LacakResultModel.fromJson({
      'noResi': 'HMB2610000123',
      'aksesMonitoring': true,
      'tugasSaya': false,
      'monitoring': {
        'berkas': {
          'noResi': 'HMB2610000123',
          'jenisKode': 'TGR',
          'statusId': 6,
          'namaWp': 'PT Contoh',
          'jumlahGagal': 0,
        },
        'maksPercobaan': 3,
        'jejak': [
          {
            'statusId': 6,
            'tglCheckin': '2026-10-14T10:00:00',
            'foto': [
              {'key': 'abc', 'jenisFoto': 'Serah'},
              {'key': 'def'},
            ],
            'flagAkurasi': 1,
          },
        ],
      },
    }).toEntity();

    final m = r.monitoring!;
    expect(r.tugas, isNull);
    expect(m.jenis, JenisSurat.teguran);
    expect(m.status, StatusBerkas.diterima);
    expect(m.jejak.single.foto.map((f) => f.key), ['abc', 'def']);
    expect(m.jejak.single.jumlahFoto, 2);
    expect(m.jejak.single.flagAkurasi, isTrue);
  });

  test('HasilCheckin: duplikat & status', () {
    final h = HasilCheckinModel.fromJson({
      'noResi': 'X',
      'statusId': 3,
      'duplikat': true,
    }).toEntity();
    expect(h.duplikat, isTrue);
    expect(h.status, StatusBerkas.diambil);
  });

  group('nama jenis surat', () {
    test('kode dikenal memakai label tetap', () {
      final e = BerkasModel.fromJson({
        'noResi': 'X',
        'jenisKode': 'SKB',
        'jenisNama': 'SKReklameBongkar',
      }).toEntity();
      expect(e.jenisNama, 'SK Reklame Bongkar');
    });

    test('kode tak dikenal: nama server dirapikan', () {
      expect(
        namaJenisSurat('Surat', false, 'SKReklameBongkar'),
        'SK Reklame Bongkar',
      );
      expect(
        namaJenisSurat('Surat', false, 'TeguranBongkar'),
        'Teguran Bongkar',
      );
      expect(namaJenisSurat('Surat', false, 'Himbauan'), 'Himbauan');
      expect(namaJenisSurat('Surat', false, null), 'Surat');
    });
  });
}
