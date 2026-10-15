import 'package:bapendacore/core/errors/exception.dart';
import 'package:bapendacore/core/network/api_endpoints.dart';
import 'package:bapendacore/data/datasources/pengiriman/pengiriman_remote_datasource.dart';
import 'package:bapendacore/data/models/pengiriman/berkas_model.dart';
import 'package:bapendacore/data/models/pengiriman/lacak_model.dart';
import 'package:bapendacore/domain/entities/pengiriman/berkas_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pengiriman_fakes.dart';

PengirimanRemoteDataSourceImpl _ds(FakeAdapter adapter) =>
    PengirimanRemoteDataSourceImpl(
      Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = adapter,
    );

void main() {
  group('GET', () {
    test('daftar: list BerkasItem dari envelope', () async {
      final adapter = FakeAdapter(
        envelopeOk([
          berkasJson(noResi: 'A'),
          berkasJson(noResi: 'B', statusId: 5, aksi: ['SERAH', 'GAGAL']),
        ]),
      );

      final hasil = await _ds(adapter).getDaftar();

      expect(adapter.terakhir!.path, ApiEndpoints.pengirimanDaftar);
      expect(hasil.map((m) => m.toEntity().noResi), ['A', 'B']);
      expect(hasil[1].toEntity().status, StatusBerkas.tiba);
      expect(hasil[1].toEntity().aksi, [AksiBerkas.serah, AksiBerkas.gagal]);
    });

    test('daftar kosong dari server → list kosong', () async {
      final hasil = await _ds(FakeAdapter(envelopeOk([]))).getDaftar();
      expect(hasil, isEmpty);
    });

    test('detail & lacak mengirim query sesuai kontrak', () async {
      final detail = FakeAdapter(
        envelopeOk({...berkasJson(noResi: 'A'), 'jejak': []}),
      );
      await _ds(detail).getDetail('A');
      expect(detail.terakhir!.path, ApiEndpoints.pengirimanDetail);
      expect(detail.terakhir!.queryParameters, {'noResi': 'A'});

      final lacak = FakeAdapter(envelopeOk({'noResi': 'A', 'tugasSaya': 1}));
      final r = await _ds(lacak).getLacak('https://x/lacak/A');
      expect(lacak.terakhir!.path, ApiEndpoints.pengirimanLacak);
      expect(lacak.terakhir!.queryParameters, {'kode': 'https://x/lacak/A'});
      expect(r.toEntity().tugasSaya, isTrue);
    });

    test('gagal bisnis (HTTP 200, isSuccess=false) → ServerException', () {
      final ds = _ds(FakeAdapter(envelopeGagal('Berkas bukan tugas Anda.')));
      expect(
        ds.getDetail('X'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Berkas bukan tugas Anda.',
          ),
        ),
      );
    });
  });

  group('POST aksi', () {
    test('satu objek hasil dinormalkan jadi list', () async {
      final adapter = FakeAdapter(
        envelopeOk({'noResi': 'A', 'statusId': 5, 'diabaikan': false}),
      );
      final hasil = await _ds(
        adapter,
      ).postForm(ApiEndpoints.pengirimanTiba, FormData());

      expect(adapter.terakhir!.method, 'POST');
      expect(adapter.terakhir!.path, ApiEndpoints.pengirimanTiba);
      expect(hasil.single.noResi, 'A');
    });

    test('data kosong → list kosong; list → apa adanya', () async {
      expect(
        await _ds(FakeAdapter(envelopeOk(null))).postForm('/x', FormData()),
        isEmpty,
      );
      final list = await _ds(
        FakeAdapter(
          envelopeOk([
            {'noResi': 'A'},
            {'noResi': 'B', 'diabaikan': 1, 'pesan': 'Sudah diterima'},
          ]),
        ),
      ).postAmbil(FormData());
      expect(list.map((h) => h.noResi), ['A', 'B']);
      expect(list[1].diabaikan, isTrue);
    });

    test('ditolak server → ServerException dengan pesan errors[0]', () {
      final ds = _ds(FakeAdapter(envelopeGagal('Foto wajib diisi.')));
      expect(
        ds.postForm('/x', FormData()),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Foto wajib diisi.',
          ),
        ),
      );
    });
  });
}
