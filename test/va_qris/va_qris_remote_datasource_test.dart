import 'dart:convert';
import 'dart:typed_data';

import 'package:mybapenda/core/errors/exception.dart';
import 'package:mybapenda/core/network/api_endpoints.dart';
import 'package:mybapenda/data/datasources/va_qris/va_qris_remote_datasource.dart';
import 'package:mybapenda/data/models/va_qris/payment_session_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adapter palsu: rekam request terakhir & kembalikan body JSON tetap.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.json);

  final Map<String, dynamic> json;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromBytes(
      utf8.encode(jsonEncode(json)),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

VaQrisRemoteDataSourceImpl _dataSource(HttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = adapter;
  return VaQrisRemoteDataSourceImpl(dio);
}

Map<String, dynamic> _sukses(Object? data) => {
  'isSuccess': true,
  'title': null,
  'status': 200,
  'traceId': 'x',
  'errors': null,
  'data': data,
};

Map<String, dynamic> _gagal(int status, String message) => {
  'isSuccess': false,
  'title': 'Terjadi Kesalahan',
  'status': status,
  'traceId': 'x',
  'errors': [message],
  'data': null,
};

Matcher _serverException(int status, String message) => isA<ServerException>()
    .having((e) => e.statusCode, 'statusCode', status)
    .having((e) => e.message, 'message', message);

void main() {
  group('getTaxTypes', () {
    test('GET jenis-pajak dan parsing daftar', () async {
      final adapter = _FakeAdapter(
        _sukses([
          {
            'id': 7,
            'nama': 'Pajak Reklame',
            'labelReferensi': 'No SKPD',
            'hint': 'Masukkan No SKPD',
            'hanyaAngka': false,
          },
        ]),
      );

      final types = await _dataSource(adapter).getTaxTypes();

      expect(adapter.last!.method, 'GET');
      expect(adapter.last!.path, ApiEndpoints.pembayaranJenisPajak);
      expect(types.single.id, 7);
      expect(types.single.nama, 'Pajak Reklame');
    });

    test('data null dianggap daftar kosong', () async {
      final types = await _dataSource(
        _FakeAdapter(_sukses(null)),
      ).getTaxTypes();

      expect(types, isEmpty);
    });

    test('isSuccess false → ServerException dengan pesan API', () async {
      final adapter = _FakeAdapter(_gagal(500, 'Master pajak tidak tersedia'));

      await expectLater(
        _dataSource(adapter).getTaxTypes(),
        throwsA(_serverException(500, 'Master pajak tidak tersedia')),
      );
    });
  });

  group('getBilling', () {
    test('GET tagihan dengan query jenisPajak & noReferensi', () async {
      final adapter = _FakeAdapter(
        _sukses({
          'jenisPajak': 7,
          'noReferensi': 'SKPD-0001',
          'namaWp': 'CV Iklan',
          'belumLunas': [],
          'sudahLunas': [],
        }),
      );

      final billing = await _dataSource(
        adapter,
      ).getBilling(taxTypeId: 7, referenceNumber: 'SKPD-0001');

      expect(adapter.last!.path, ApiEndpoints.pembayaranTagihan);
      expect(adapter.last!.queryParameters, {
        'jenisPajak': 7,
        'noReferensi': 'SKPD-0001',
      });
      expect(billing.namaWp, 'CV Iklan');
      expect(billing.labelReferensi, '');
    });

    test('tidak ditemukan → ServerException', () async {
      final adapter = _FakeAdapter(_gagal(404, 'No SKPD tidak ditemukan'));

      await expectLater(
        _dataSource(
          adapter,
        ).getBilling(taxTypeId: 7, referenceNumber: 'SKPD-9999'),
        throwsA(_serverException(404, 'No SKPD tidak ditemukan')),
      );
    });

    test('sukses tapi data null → ServerException', () async {
      await expectLater(
        _dataSource(
          _FakeAdapter(_sukses(null)),
        ).getBilling(taxTypeId: 7, referenceNumber: 'SKPD-0001'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('checkNominal', () {
    test('POST check-nominal dengan body nominal', () async {
      final adapter = _FakeAdapter(
        _sukses({
          'va': {'isAllow': true, 'message': ''},
          'qris': {'isAllow': false, 'message': 'Maksimal Rp10.000.000'},
        }),
      );

      final check = await _dataSource(adapter).checkNominal(12000000);

      expect(adapter.last!.method, 'POST');
      expect(adapter.last!.path, ApiEndpoints.pembayaranCheckNominal);
      expect(adapter.last!.data, {'nominal': 12000000});
      expect(check.va.isAllow, isTrue);
      expect(check.qris.isAllow, isFalse);
      expect(check.qris.message, 'Maksimal Rp10.000.000');
    });

    test('isSuccess false → ServerException', () async {
      await expectLater(
        _dataSource(
          _FakeAdapter(_gagal(400, 'Nominal tidak valid')),
        ).checkNominal(0),
        throwsA(_serverException(400, 'Nominal tidak valid')),
      );
    });
  });

  group('createPayment', () {
    const request = CreatePaymentRequestModel(
      jenisPajak: 6,
      noReferensi: '35.78.010.001.902.00001',
      tipePembayaran: 'qris',
      keyTagihan: ['enc-1', 'enc-2'],
    );

    test('POST bayar dengan body request', () async {
      final adapter = _FakeAdapter(
        _sukses({
          'tipePembayaran': 'qris',
          'noReferensi': '35.78.010.001.902.00001',
          'kodeBayar': 'QR1',
          'nominalTotal': 206000,
          'expiredDate': '2026-10-15T10:00:00',
          'sisaDetik': 900,
          'qrValue': '000201...',
          'nmid': 'ID2021112825553',
        }),
      );

      final session = await _dataSource(adapter).createPayment(request);

      expect(adapter.last!.method, 'POST');
      expect(adapter.last!.path, ApiEndpoints.pembayaranBayar);
      expect(adapter.last!.data, {
        'jenisPajak': 6,
        'noReferensi': '35.78.010.001.902.00001',
        'tipePembayaran': 'qris',
        'keyTagihan': ['enc-1', 'enc-2'],
      });
      expect(session.kodeBayar, 'QR1');
      expect(session.sisaDetik, 900);
      expect(session.qrValue, '000201...');
      expect(session.nmid, 'ID2021112825553');
    });

    test('ditolak server → ServerException', () async {
      await expectLater(
        _dataSource(
          _FakeAdapter(
            _gagal(
              400,
              'Tagihan yang dipilih tidak ditemukan atau sudah lunas',
            ),
          ),
        ).createPayment(request),
        throwsA(
          _serverException(
            400,
            'Tagihan yang dipilih tidak ditemukan atau sudah lunas',
          ),
        ),
      );
    });
  });

  group('getPaymentStatus', () {
    test('GET status dengan query tipePembayaran & kodeBayar', () async {
      final adapter = _FakeAdapter(
        _sukses({
          'isLunas': true,
          'tglBayar': '2026-10-15T09:05:00',
          'coreReference': 'CR-1',
          'jumlahBayar': 206000,
        }),
      );

      final status = await _dataSource(
        adapter,
      ).getPaymentStatus(method: 'va', paymentCode: 'VA123');

      expect(adapter.last!.path, ApiEndpoints.pembayaranStatus);
      expect(adapter.last!.queryParameters, {
        'tipePembayaran': 'va',
        'kodeBayar': 'VA123',
      });
      expect(status.isLunas, isTrue);
      expect(status.coreReference, 'CR-1');
    });

    test('isSuccess false → ServerException', () async {
      await expectLater(
        _dataSource(
          _FakeAdapter(_gagal(404, 'Kode bayar tidak ditemukan')),
        ).getPaymentStatus(method: 'qris', paymentCode: 'X'),
        throwsA(_serverException(404, 'Kode bayar tidak ditemukan')),
      );
    });
  });

  group('searchObjects', () {
    test(
      'GET cari-objek: keyword & halaman, hasil + jumlah per jenis',
      () async {
        final adapter = _FakeAdapter(
          _sukses({
            'currentPage': 2,
            'pageSize': 30,
            'totalData': 45,
            'totalPage': 2,
            'items': [
              {
                'jenisPajak': 1,
                'jenisPajakNama': 'Pajak Makanan & Minuman',
                'nop': '35.78.051.002.902.00282',
                'nama': 'ALMAZ FRIED CHICKEN MULYOREJO',
                'alamat': 'DR. IR. SOEKARNO NO.65',
              },
            ],
            'perJenisPajak': [
              {
                'jenisPajak': 1,
                'jenisPajakNama': 'Pajak Makanan & Minuman',
                'jumlah': 45,
              },
            ],
          }),
        );

        final result = await _dataSource(
          adapter,
        ).searchObjects(keyword: 'mulyorejo', page: 2, pageSize: 30);

        expect(adapter.last!.method, 'GET');
        expect(adapter.last!.path, ApiEndpoints.pembayaranCariObjek);
        // Filter jenis pajak dilakukan di HP: jenisPajak tidak dikirim
        expect(adapter.last!.queryParameters, {
          'keyword': 'mulyorejo',
          'page': 2,
          'pageSize': 30,
        });
        expect(result.page.currentPage, 2);
        expect(result.page.totalData, 45);
        expect(result.page.items.single.jenisPajak, 1);
        expect(result.page.items.single.nop, '35.78.051.002.902.00282');
        expect(result.perJenisPajak.single.jumlah, 45);
      },
    );

    test('perJenisPajak tidak ada di response: dianggap kosong', () async {
      final adapter = _FakeAdapter(
        _sukses({
          'currentPage': 1,
          'pageSize': 30,
          'totalData': 0,
          'totalPage': 0,
          'items': [],
        }),
      );

      final result = await _dataSource(
        adapter,
      ).searchObjects(keyword: 'mulyorejo', page: 1, pageSize: 30);

      expect(result.perJenisPajak, isEmpty);
    });

    test('keyword terlalu pendek ditolak server → ServerException', () async {
      await expectLater(
        _dataSource(
          _FakeAdapter(
            _gagal(400, 'Ketik minimal 3 huruf untuk mencari objek pajak.'),
          ),
        ).searchObjects(keyword: 'ab', page: 1, pageSize: 30),
        throwsA(
          _serverException(
            400,
            'Ketik minimal 3 huruf untuk mencari objek pajak.',
          ),
        ),
      );
    });
  });
}
