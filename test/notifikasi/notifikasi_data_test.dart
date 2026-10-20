import 'package:bapendacore/core/errors/exception.dart';
import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/core/network/api_endpoints.dart';
import 'package:bapendacore/core/services/notifikasi/notifikasi_sinyal.dart';
import 'package:bapendacore/data/datasources/notifikasi/notifikasi_remote_datasource.dart';
import 'package:bapendacore/data/models/notifikasi/notifikasi_model.dart';
import 'package:bapendacore/data/repositories/notifikasi/notifikasi_repository_impl.dart';
import 'package:bapendacore/domain/entities/notifikasi/notifikasi_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../pengiriman/helpers/pengiriman_fakes.dart';

NotifikasiRemoteDataSourceImpl _ds(FakeAdapter adapter) =>
    NotifikasiRemoteDataSourceImpl(
      Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = adapter,
    );

Map<String, dynamic> itemJson({
  int id = 1,
  String kode = KodeNotifikasi.suratDitugaskan,
  Object? reffNo = 'SKB2610000002',
  Object? dibaca = false,
}) => {
  'id': id,
  'kodeJenis': kode,
  'namaJenis': 'Berkas ditugaskan',
  'reffNo': reffNo,
  'judul': 'Berkas baru ditugaskan',
  'isi': 'SK Bongkar untuk FULAN.',
  'tglNotifikasi': '2026-10-16T08:18:50',
  'dibaca': dibaca,
  'tglBaca': null,
};

void main() {
  group('datasource sesuai kontrak', () {
    test('inbox: query & parse halaman', () async {
      final adapter = FakeAdapter(
        envelopeOk({
          'items': [itemJson(), itemJson(id: 2, dibaca: 1)],
          'page': 1,
          'pageSize': 20,
          'totalData': 25,
          'totalPage': 2,
        }),
      );

      final m = await _ds(
        adapter,
      ).getInbox(page: 1, pageSize: 20, hanyaBelumDibaca: true);

      expect(adapter.terakhir!.path, ApiEndpoints.notifikasiInbox);
      expect(adapter.terakhir!.queryParameters, {
        'page': 1,
        'pageSize': 20,
        'hanyaBelumDibaca': true,
      });
      final e = m.toEntity();
      expect(e.items.map((n) => n.id), [1, 2]);
      expect(e.items[1].dibaca, isTrue);
      expect(e.items.first.tglNotifikasi, DateTime(2026, 10, 16, 8, 18, 50));
      expect(e.adaLagi, isTrue);
    });

    test('jumlah, PATCH baca {id}, POST baca-semua', () async {
      final jumlah = FakeAdapter(envelopeOk({'jumlah': 3}));
      expect(await _ds(jumlah).getJumlahBelumDibaca(), 3);
      expect(jumlah.terakhir!.path, ApiEndpoints.notifikasiJumlahBelumDibaca);

      final baca = FakeAdapter(envelopeOk({'jumlah': 1}));
      expect(await _ds(baca).baca(7), 1);
      expect(baca.terakhir!.method, 'PATCH');
      expect(baca.terakhir!.path, ApiEndpoints.notifikasiBaca);
      expect(baca.terakhir!.data, {'id': 7});

      final semua = FakeAdapter(envelopeOk({'jumlah': 4}));
      expect(await _ds(semua).bacaSemua(), 4);
      expect(semua.terakhir!.method, 'POST');
      expect(semua.terakhir!.path, ApiEndpoints.notifikasiBacaSemua);
    });

    test('isSuccess=false → ServerException pesan server', () {
      expect(
        _ds(FakeAdapter(envelopeGagal('Notifikasi tidak ditemukan.'))).baca(9),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Notifikasi tidak ditemukan.',
          ),
        ),
      );
    });
  });

  group('repository', () {
    test(
      'badge & event dari hub (sinyal), baca tidak memicu REST lain',
      () async {
        final sinyal = NotifikasiSinyal();
        final adapter = FakeAdapter(envelopeOk({'jumlah': 1}));
        final repo = NotifikasiRepositoryImpl(_ds(adapter), sinyal);
        final jumlah = <int>[];
        var event = 0;
        repo.jumlahBelumDibaca.listen(jumlah.add);
        repo.perubahan.listen((_) => event++);

        expect(repo.jumlahTerakhir, isNull);
        sinyal.terima(jumlahBelumDibaca: 4);
        await Future<void>.delayed(Duration.zero);
        expect(jumlah, [4]);
        expect(event, 1);
        expect(repo.jumlahTerakhir, 4);

        expect(await repo.baca(1), const Right<Failure, int>(1));
        expect(adapter.terakhir!.path, ApiEndpoints.notifikasiBaca);
        await Future<void>.delayed(Duration.zero);
        // Badge menunggu snapshot server, bukan dihitung/di-polling app.
        expect(event, 1);
      },
    );

    test('gagal server → Left ServerFailure', () async {
      final repo = NotifikasiRepositoryImpl(
        _ds(FakeAdapter(envelopeGagal('x'))),
        NotifikasiSinyal(),
      );
      final r = await repo.getJumlahBelumDibaca();
      expect(r.fold((f) => f, (_) => null), isA<ServerFailure>());
    });
  });

  group('entity & model', () {
    test('noResiBerkas hanya untuk SURAT_DITUGASKAN ber-reffNo', () {
      NotifikasiEntity e(Map<String, dynamic> j) =>
          NotifikasiModel.fromJson(j).toEntity();
      expect(e(itemJson()).noResiBerkas, 'SKB2610000002');
      expect(e(itemJson(reffNo: '  ')).noResiBerkas, isNull);
      expect(e(itemJson(kode: 'LAIN')).noResiBerkas, isNull);
    });

    test('event NOTIF: field tambahan (nip) diabaikan', () {
      final ev = NotifEventModel.fromJson({
        'nip': '3506192511010005',
        'jumlahBaru': 1,
        'jumlahBelumDibaca': 4,
        'items': [itemJson()],
      });
      expect(ev.jumlahBelumDibaca, 4);
      expect(ev.items.single.reffNo, 'SKB2610000002');
    });
  });
}
