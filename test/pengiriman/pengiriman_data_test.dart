import 'dart:convert';
import 'dart:io';

import 'package:bapendacore/core/network/api_endpoints.dart';
import 'package:bapendacore/core/storage/pengiriman_cache_storage.dart';
import 'package:bapendacore/data/models/pengiriman/master_pengiriman_model.dart';
import 'package:bapendacore/data/models/pengiriman/pengiriman_payload_model.dart';
import 'package:bapendacore/domain/entities/pengiriman/berkas_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/master_pengiriman_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/pengiriman_payload_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _checkin = CheckinPengirimanEntity(
  checkinUuid: 'u-1',
  tglCheckin: DateTime(2026, 10, 15, 9, 5),
  latitude: -7.25,
  longitude: 112.75,
  isMockLocation: false,
  keterangan: ' Pagar hijau ',
  fotoLokasiPath: '/foto/lokasi.jpg',
);

Map<String, List<String>> _fields(List<List<String>> f) {
  final m = <String, List<String>>{};
  for (final e in f) {
    (m[e[0]] ??= []).add(e[1]);
  }
  return m;
}

void main() {
  group('model master & hasil check-in', () {
    test('master: opsi per kategori, wajib keterangan dari angka/teks', () {
      final m = MasterPengirimanModel.fromJson({
        'hubunganPenerima': [
          {'id': 1, 'nama': 'Pemilik'},
        ],
        'alasanGagal': [
          {'id': 2, 'nama': 'Lainnya', 'wajibKeterangan': 1},
          {'id': 3, 'wajibKeterangan': 'false'},
        ],
        'caraSerah': [
          {'id': 1, 'nama': 'Langsung'},
        ],
      }).toEntity();

      expect(m.hubunganPenerima.single.nama, 'Pemilik');
      expect(m.alasanGagal[0].wajibKeterangan, isTrue);
      expect(m.alasanGagal[1].nama, '-');
      expect(m.alasanGagal[1].wajibKeterangan, isFalse);
      expect(CaraSerah.fromId(m.caraSerah.single.id), CaraSerah.langsung);
    });

    test('master kosong → daftar kosong', () {
      final m = MasterPengirimanModel.fromJson(const {}).toEntity();
      expect(m, const MasterPengirimanEntity());
    });

    test('hasil check-in: status baru, diabaikan & duplikat', () {
      final h = HasilCheckinModel.fromJson({
        'noResi': 'A',
        'statusId': 5,
        'status': 'Tiba di Tujuan',
        'diabaikan': 'true',
        'duplikat': 1,
        'pesan': 'Sudah',
      }).toEntity();

      expect(h.status, StatusBerkas.tiba);
      expect(h.statusNama, 'Tiba di Tujuan');
      expect(h.diabaikan, isTrue);
      expect(h.duplikat, isTrue);
      expect(h.pesan, 'Sudah');
      expect(HasilCheckinModel.fromJson(const {}).toEntity().status, isNull);
    });
  });

  group('payload → rekaman antrean (kontrak multipart)', () {
    test('serah langsung: penerima, hubungan, foto serah & TTD', () {
      final r = SerahPayloadEntity(
        noResi: 'A',
        caraSerah: CaraSerah.langsung,
        namaPenerima: ' Budi ',
        idHubungan: 7,
        fotoSerahPath: '/f/serah.jpg',
        fotoTtdPath: '/f/ttd.png',
        checkin: _checkin,
      ).toRecord();

      expect(r.endpoint, ApiEndpoints.pengirimanSerah);
      expect(r.jenis, 'serah');
      final f = _fields(r.fields);
      expect(f['caraSerah'], ['1']);
      expect(f['namaPenerima'], ['Budi']);
      expect(f['idHubungan'], ['7']);
      expect(f['keterangan'], ['Pagar hijau']);
      expect(r.files.keys, containsAll(['fotoSerah', 'fotoTtd', 'fotoLokasi']));
      expect(r.files.containsKey('fotoTempel'), isFalse);
    });

    test('serah ditempel: tanpa penerima', () {
      final r = SerahPayloadEntity(
        noResi: 'A',
        caraSerah: CaraSerah.ditempel,
        fotoTempelPath: '/f/tempel.jpg',
        fotoObjekPath: '/f/objek.jpg',
        checkin: _checkin,
      ).toRecord();

      final f = _fields(r.fields);
      expect(f['caraSerah'], ['3']);
      expect(f.containsKey('namaPenerima'), isFalse);
      expect(f.containsKey('idHubungan'), isFalse);
      expect(r.files.keys, containsAll(['fotoTempel', 'fotoObjek']));
    });

    test('gagal: alasan + foto bukti', () {
      final r = GagalPayloadEntity(
        noResi: 'A',
        idAlasan: 4,
        fotoGagalPath: '/f/gagal.jpg',
        checkin: _checkin,
      ).toRecord();

      expect(r.endpoint, ApiEndpoints.pengirimanGagal);
      expect(_fields(r.fields)['idAlasan'], ['4']);
      expect(r.files['fotoGagal'], '/f/gagal.jpg');
    });

    test('kembalikan: banyak no resi, field berulang', () {
      final r = KembalikanPayloadEntity(
        noResiList: const ['A', 'B'],
        checkin: _checkin,
      ).toRecord();

      expect(r.endpoint, ApiEndpoints.pengirimanKembalikan);
      expect(r.noResi, ['A', 'B']);
      expect(_fields(r.fields)['noResiList'], ['A', 'B']);
    });

    test('perjalanan: endpoint perjalanan', () {
      final r = CheckinPayloadEntity(
        jenis: JenisCheckin.perjalanan,
        noResi: 'A',
        checkin: _checkin,
      ).toRecord();
      expect(r.endpoint, ApiEndpoints.pengirimanPerjalanan);
      expect(r.jenis, 'perjalanan');
    });

    test('ambil & antrean → FormData: file png/jpeg, tim berulang', () async {
      final dir = Directory.systemTemp.createTempSync('payload_uji');
      addTearDown(() => dir.deleteSync(recursive: true));
      final jpg = File('${dir.path}/ambil.jpg')..writeAsBytesSync([1, 2, 3]);
      final png = File('${dir.path}/ttd.png')..writeAsBytesSync([4, 5]);

      final form = await AmbilPayloadEntity(
        noResiList: const ['A', 'B'],
        nipTim: const ['199001'],
        fotoAmbilPath: jpg.path,
        checkin: CheckinPengirimanEntity(
          checkinUuid: 'u-2',
          tglCheckin: DateTime(2026, 10, 15),
          latitude: 1,
          longitude: 2,
          isMockLocation: false,
        ),
      ).toFormData();

      expect(
        form.fields.where((e) => e.key == 'noResiList').map((e) => e.value),
        ['A', 'B'],
      );
      expect(form.fields.any((e) => e.key == 'nipTim'), isTrue);
      expect(form.files.single.key, 'fotoAmbil');
      expect(form.files.single.value.contentType.toString(), 'image/jpeg');
      expect(form.files.single.value.filename, 'ambil.jpg');

      final rekaman = SerahPayloadEntity(
        noResi: 'A',
        caraSerah: CaraSerah.langsung,
        namaPenerima: 'Budi',
        idHubungan: 1,
        fotoTtdPath: png.path,
        checkin: CheckinPengirimanEntity(
          checkinUuid: 'u-3',
          tglCheckin: DateTime(2026, 10, 15),
          latitude: 1,
          longitude: 2,
          isMockLocation: false,
        ),
      ).toRecord();
      final formAntrean = await rekaman.toFormData();
      expect(
        formAntrean.files.single.value.contentType.toString(),
        'image/png',
      );
      expect(rekaman.toEntity().noResi, ['A']);
    });
  });

  group('cache offline', () {
    late PengirimanCacheStorage cache;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      cache = PengirimanCacheStorage(prefs);
    });

    test('daftar & detail per NIP', () async {
      await cache.simpanDaftar('n1', [
        {'noResi': 'A'},
      ]);
      await cache.simpanDetail('n1', 'A', {'noResi': 'A'});

      expect(cache.bacaDaftar('n1')!.data.single['noResi'], 'A');
      expect(cache.bacaDetail('n1', 'A')!.data['noResi'], 'A');
      expect(cache.bacaDaftar('n2'), isNull);
      expect(cache.bacaDetail('n1', 'B'), isNull);
    });

    test('detail dibatasi 100 berkas: yang terlama dibuang', () async {
      for (var i = 0; i < 101; i++) {
        await cache.simpanDetail('n1', 'R$i', {'noResi': 'R$i'});
      }
      expect(cache.bacaDetail('n1', 'R0'), isNull);
      expect(cache.bacaDetail('n1', 'R100'), isNotNull);

      // Disimpan ulang → pindah ke paling baru, tidak ikut terbuang.
      await cache.simpanDetail('n1', 'R1', {'noResi': 'R1'});
      await cache.simpanDetail('n1', 'R101', {'noResi': 'R101'});
      expect(cache.bacaDetail('n1', 'R1'), isNotNull);
      expect(cache.bacaDetail('n1', 'R2'), isNull);
    });

    test('data rusak dianggap tidak ada', () async {
      await prefs.setString('pengiriman_cache_daftar_n1', '{rusak');
      await prefs.setString('pengiriman_cache_detail_n1', jsonEncode([1]));

      expect(cache.bacaDaftar('n1'), isNull);
      expect(cache.bacaDetail('n1', 'A'), isNull);
    });
  });
}
