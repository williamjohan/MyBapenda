import 'package:mybapenda/core/storage/app_secure_storage.dart';
import 'package:mybapenda/data/datasources/va_qris/va_qris_local_datasource.dart';
import 'package:mybapenda/data/models/va_qris/recent_reference_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// NIP pegawai yang sedang login bisa diganti dari test.
class _FakeSecureStorage implements AppSecureStorage {
  String? nip = '198001012005011001';

  @override
  Future<String?> getCurrentNip() async => nip;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

RecentReferenceModel _item(String nop, {int jenis = 6, int hari = 1}) =>
    RecentReferenceModel(
      jenisPajak: jenis,
      jenisPajakNama: 'Pajak Air Tanah',
      noReferensi: nop,
      nama: 'OP $nop',
      disimpan: DateTime(2026, 10, hari),
    );

void main() {
  late SharedPreferences prefs;
  late _FakeSecureStorage secure;
  late VaQrisLocalDataSourceImpl dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    secure = _FakeSecureStorage();
    dataSource = VaQrisLocalDataSourceImpl(prefs, secure);
  });

  test('awal kosong', () async {
    expect(await dataSource.getRecent(), isEmpty);
  });

  test('terbaru di atas & tersimpan (bisa dibaca ulang)', () async {
    await dataSource.saveRecent(_item('A'));
    await dataSource.saveRecent(_item('B', hari: 2));

    final reread = await VaQrisLocalDataSourceImpl(prefs, secure).getRecent();
    expect(reread.map((e) => e.noReferensi), ['B', 'A']);
    expect(reread.first.disimpan, DateTime(2026, 10, 2));
    expect(reread.first.nama, 'OP B');
  });

  test('nomor yang sama tidak dobel, naik ke atas', () async {
    await dataSource.saveRecent(_item('A'));
    await dataSource.saveRecent(_item('B'));

    final result = await dataSource.saveRecent(_item('A', hari: 3));

    expect(result.map((e) => e.noReferensi), ['A', 'B']);
    expect(result.first.disimpan, DateTime(2026, 10, 3));
  });

  test('NOP sama beda jenis pajak dianggap entri berbeda', () async {
    await dataSource.saveRecent(_item('A', jenis: 1));

    final result = await dataSource.saveRecent(_item('A', jenis: 4));

    expect(result.map((e) => e.jenisPajak), [4, 1]);
  });

  test('maksimal 10 entri, yang paling lama dibuang', () async {
    for (var i = 0; i < 12; i++) {
      await dataSource.saveRecent(_item('N$i'));
    }

    final result = await dataSource.getRecent();
    expect(result, hasLength(10));
    expect(result.first.noReferensi, 'N11');
    expect(result.last.noReferensi, 'N2');
  });

  test('terpisah per NIP pegawai', () async {
    await dataSource.saveRecent(_item('MILIK-A'));

    secure.nip = '199002022010012002';
    expect(await dataSource.getRecent(), isEmpty);
    await dataSource.saveRecent(_item('MILIK-B'));

    secure.nip = '198001012005011001';
    expect((await dataSource.getRecent()).single.noReferensi, 'MILIK-A');
  });

  test('clearRecent hanya menghapus milik pegawai yang login', () async {
    await dataSource.saveRecent(_item('MILIK-A'));
    secure.nip = '199002022010012002';
    await dataSource.saveRecent(_item('MILIK-B'));

    await dataSource.clearRecent();

    expect(await dataSource.getRecent(), isEmpty);
    secure.nip = '198001012005011001';
    expect(await dataSource.getRecent(), hasLength(1));
  });

  test('data rusak dianggap kosong', () async {
    await prefs.setString('va_qris_riwayat_198001012005011001', '{bukan list');

    expect(await dataSource.getRecent(), isEmpty);
  });
}
