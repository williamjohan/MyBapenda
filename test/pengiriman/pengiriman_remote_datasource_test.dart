import 'package:bapendacore/core/errors/exception.dart';
import 'package:bapendacore/core/network/api_endpoints.dart';
import 'package:bapendacore/data/datasources/pengiriman/pengiriman_remote_datasource.dart';
import 'package:bapendacore/data/datasources/pengiriman/rute_remote_datasource.dart';
import 'package:bapendacore/data/models/pengiriman/rute_model.dart';
import 'package:bapendacore/domain/entities/pengiriman/lacak_entity.dart';
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

  group('Routes API (rute peta)', () {
    const titik = [
      TitikRute(-7.25, 112.73),
      TitikRute(-7.27, 112.74),
      TitikRute(-7.29, 112.75),
    ];

    RuteRemoteDataSourceImpl rute(FakeAdapter a) =>
        RuteRemoteDataSourceImpl.uji(Dio()..httpClientAdapter = a, 'KUNCI');

    test('motor, singgah di titik tengah, key di header', () async {
      final adapter = FakeAdapter({
        'routes': [
          {
            'polyline': {'encodedPolyline': '_p~iF~ps|U'},
          },
        ],
      });

      final m = await rute(adapter).hitungRute(titik);

      final req = adapter.terakhir!;
      expect(req.uri.toString(), ApiEndpoints.googleRoutes);
      expect(req.headers['X-Goog-Api-Key'], 'KUNCI');
      expect(
        req.headers['X-Goog-FieldMask'],
        'routes.polyline.encodedPolyline',
      );
      // Token login tidak ikut ke Google.
      expect(req.headers.containsKey('Authorization'), isFalse);
      final body = req.data as Map<String, dynamic>;
      expect(body['travelMode'], 'TWO_WHEELER');
      expect(body['origin']['location']['latLng']['latitude'], -7.25);
      expect(body['destination']['location']['latLng']['longitude'], 112.75);
      expect((body['intermediates'] as List), hasLength(1));
      expect(m.toEntity(), const [TitikRute(38.5, -120.2)]);
    });

    test('dua titik: tanpa singgah', () {
      expect(
        RuteModel.permintaan(titik.sublist(1)).containsKey('intermediates'),
        isFalse,
      );
    });

    test('tanpa rute → ServerException', () {
      expect(
        rute(FakeAdapter(const {'routes': []})).hitungRute(titik),
        throwsA(isA<ServerException>()),
      );
      expect(RuteModel.fromJson(const {}).toEntity(), isEmpty);
    });
  });
}
