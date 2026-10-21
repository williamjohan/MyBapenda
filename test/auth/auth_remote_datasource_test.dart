import 'dart:convert';
import 'dart:typed_data';

import 'package:mybapenda/core/errors/exception.dart';
import 'package:mybapenda/core/network/api_endpoints.dart';
import 'package:mybapenda/data/datasources/auth/auth_remote_datasource.dart';
import 'package:mybapenda/data/models/auth/auth_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adapter palsu: simpan request terakhir, balas JSON tetap.
class _RecordingAdapter implements HttpClientAdapter {
  final int statusCode;
  final Map<String, dynamic> json;
  RequestOptions? last;

  _RecordingAdapter(this.statusCode, this.json);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromBytes(
      utf8.encode(jsonEncode(json)),
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

AuthRemoteDataSourceImpl _dataSource(HttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = adapter;
  return AuthRemoteDataSourceImpl(dio);
}

Map<String, dynamic> _berhasil(Object? data) => {
  'isSuccess': true,
  'title': 'Berhasil',
  'status': 200,
  'traceId': null,
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

void main() {
  group('lupaPassword', () {
    test(
      'POST ke /api/auth/lupapassword dengan body nip/channel/tujuan',
      () async {
        final adapter = _RecordingAdapter(200, _berhasil(null));

        final ok = await _dataSource(adapter).lupaPassword(
          const LupaPasswordRequestModel(
            nip: '3578103004020008',
            channel: 2,
            tujuan: '0895349690206',
          ),
        );

        expect(ok, isTrue);
        expect(adapter.last!.method, 'POST');
        expect(adapter.last!.path, ApiEndpoints.lupaPassword);
        expect(adapter.last!.data, {
          'nip': '3578103004020008',
          'channel': 2,
          'tujuan': '0895349690206',
        });
      },
    );

    test('isSuccess false -> ServerException berisi pesan server', () async {
      final adapter = _RecordingAdapter(
        200,
        _gagal(404, 'NIP tidak terdaftar'),
      );

      expect(
        () => _dataSource(adapter).lupaPassword(
          const LupaPasswordRequestModel(nip: '1', channel: 1, tujuan: 'a@b.c'),
        ),
        throwsA(
          isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.message, 'message', 'NIP tidak terdaftar'),
        ),
      );
    });
  });

  group('resetPassword', () {
    test(
      'POST ke /api/auth/resetpassword dengan newPassword & konfirmasi',
      () async {
        final adapter = _RecordingAdapter(200, _berhasil(null));

        final ok = await _dataSource(adapter).resetPassword(
          const ResetPasswordRequestModel(
            newPassword: 'Rahasia#123',
            confirmationPassword: 'Rahasia#123',
          ),
        );

        expect(ok, isTrue);
        expect(adapter.last!.path, ApiEndpoints.resetPassword);
        expect(adapter.last!.data, {
          'newPassword': 'Rahasia#123',
          'confirmationPassword': 'Rahasia#123',
        });
      },
    );

    test('isSuccess false -> ServerException', () async {
      final adapter = _RecordingAdapter(
        200,
        _gagal(400, 'Konfirmasi kata sandi tidak sama'),
      );

      expect(
        () => _dataSource(adapter).resetPassword(
          const ResetPasswordRequestModel(
            newPassword: 'a',
            confirmationPassword: 'b',
          ),
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Konfirmasi kata sandi tidak sama',
          ),
        ),
      );
    });
  });

  test('getProfile kirim nip sebagai query & parse data pegawai', () async {
    final adapter = _RecordingAdapter(
      200,
      _berhasil({
        'nip': '3578103004020008',
        'nama': 'ROYAN HISYAM RAFLIANSYAH, S. KOM',
        'alamat': 'SURABAYA',
        'hp': '0895349690206',
        'email': 'ryn.rafliansyah@gmail.com',
        'jenisPegawai': 'Tenaga Ahli',
        'aktif': 'Aktif',
        'tglLahir': '2002-04-30 00:00:00',
        'bidang':
            'BIDANG PAJAK HOTEL, RESTO, PPJ, PARKIR, REKLAME, HIBURAN & AIR TANAH',
        'jabatan': 'IT BAPENDA',
        'golongan': 'NON PNS',
      }),
    );

    final user = await _dataSource(adapter).getProfile(nip: '3578103004020008');

    expect(adapter.last!.path, ApiEndpoints.profile);
    expect(adapter.last!.queryParameters, {'nip': '3578103004020008'});
    expect(user.nama, 'ROYAN HISYAM RAFLIANSYAH, S. KOM');
    expect(user.jabatan, 'IT BAPENDA');
    expect(user.tglLahir, '2002-04-30 00:00:00');
  });
}
