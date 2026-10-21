import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mybapenda/core/errors/exception.dart';
import 'package:mybapenda/core/network/api_endpoints.dart';
import 'package:mybapenda/data/datasources/profile/profile_remote_datasource.dart';
import 'package:mybapenda/data/models/profile/profile_model.dart';
import 'package:mybapenda/data/models/users/user_model.dart';
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

ProfileRemoteDataSourceImpl _dataSource(HttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = adapter;
  return ProfileRemoteDataSourceImpl(dio);
}

Map<String, dynamic> _berhasil(Object? data) => {
  'isSuccess': true,
  'title': 'Berhasil',
  'status': 200,
  'traceId': null,
  'errors': null,
  'data': data,
};

const _fotoJson = {
  'fotoUrl': 'https://example.test/api/profile/foto?key=abc',
  'namaFile': 'foto_pegawai.jpg',
  'ukuranFile': '48.73 KB',
  'tipeFile': 'Image',
  'contentType': 'image/jpeg',
};

void main() {
  group('UserModel', () {
    test('baca foto & status verifikasi dari /api/profile', () {
      final user = UserModel.fromJson({
        'nip': '3578103004020008',
        'nama': 'ROYAN',
        'alamat': 'SURABAYA',
        'hp': '0895349690206',
        'email': 'ryn@mail.com',
        'isValidEmail': true,
        'isValidWa': false,
        'jenisPegawai': 'Tenaga Ahli',
        'aktif': 'Aktif',
        'tglLahir': '2002-04-30 00:00:00',
        'bidang': 'BIDANG',
        'jabatan': 'IT BAPENDA',
        'golongan': 'NON PNS',
        'foto': _fotoJson,
      }).toEntity();

      expect(user.isValidEmail, isTrue);
      expect(user.isValidWa, isFalse);
      expect(user.foto!.fotoUrl, _fotoJson['fotoUrl']);
    });

    test('cache lama tanpa foto/verifikasi & email null tetap terbaca', () {
      final user = UserModel.fromJson({
        'nip': '1',
        'nama': 'A',
        'alamat': '',
        'hp': '',
        'email': null,
        'jenisPegawai': '',
        'aktif': '',
        'tglLahir': '',
        'bidang': '',
        'jabatan': '',
        'golongan': '',
      });

      expect(user.email, '');
      expect(user.isValidEmail, isFalse);
      expect(user.foto, isNull);
    });

    test('toJson menyimpan foto sebagai map (cache bisa dibaca ulang)', () {
      final model = UserModel.fromJson({
        'nip': '1',
        'nama': 'A',
        'alamat': '',
        'hp': '',
        'email': '',
        'jenisPegawai': '',
        'aktif': '',
        'tglLahir': '',
        'bidang': '',
        'jabatan': '',
        'golongan': '',
        'foto': _fotoJson,
      });

      final ulang = UserModel.fromJson(
        jsonDecode(jsonEncode(model.toJson())) as Map<String, dynamic>,
      );
      expect(ulang.foto!.namaFile, 'foto_pegawai.jpg');
    });
  });

  test(
    'gantiFoto: multipart FileDataFormFile ke /api/profile/ganti-foto',
    () async {
      final dir = await Directory.systemTemp.createTemp('foto_test');
      final file = File('${dir.path}/foto.jpg')..writeAsBytesSync([1, 2, 3]);
      final adapter = _RecordingAdapter(200, _berhasil(_fotoJson));

      final foto = await _dataSource(
        adapter,
      ).gantiFoto(GantiFotoPayloadModel(fotoPath: file.path));

      expect(adapter.last!.path, ApiEndpoints.profileGantiFoto);
      expect(adapter.last!.method, 'POST');
      final form = adapter.last!.data as FormData;
      expect(form.files.single.key, 'FileDataFormFile');
      expect(form.files.single.value.filename, 'foto.jpg');
      expect(foto.fotoUrl, _fotoJson['fotoUrl']);

      // Windows: stream multipart belum ditutup, file masih terkunci.
      await dir.delete(recursive: true).catchError((_) => dir);
    },
  );

  test('kirimOtpKontak: body kontak/tujuan, baca sisa detik', () async {
    final adapter = _RecordingAdapter(
      200,
      _berhasil({'sisaBerlakuDetik': 300, 'sisaJedaKirimDetik': 60}),
    );

    final res = await _dataSource(adapter).kirimOtpKontak(
      const KirimOtpKontakRequestModel(kontak: 2, tujuan: '0895349690206'),
    );

    expect(adapter.last!.path, ApiEndpoints.profileKirimOtpKontak);
    expect(adapter.last!.data, {'kontak': 2, 'tujuan': '0895349690206'});
    expect(res.sisaBerlakuDetik, 300);
    expect(res.sisaJedaKirimDetik, 60);
  });

  test(
    'verifikasiOtpKontak: body kontak/tujuan/kode, baca kontak baru',
    () async {
      final adapter = _RecordingAdapter(
        200,
        _berhasil({
          'hp': '0895349690206',
          'email': 'baru@mail.com',
          'isValidEmail': true,
          'isValidWa': true,
        }),
      );

      final res = await _dataSource(adapter).verifikasiOtpKontak(
        const VerifikasiOtpKontakRequestModel(
          kontak: 1,
          tujuan: 'baru@mail.com',
          kode: '123456',
        ),
      );

      expect(adapter.last!.path, ApiEndpoints.profileVerifikasiOtpKontak);
      expect(adapter.last!.data, {
        'kontak': 1,
        'tujuan': 'baru@mail.com',
        'kode': '123456',
      });
      expect(res.email, 'baru@mail.com');
      expect(res.isValidEmail, isTrue);
    },
  );

  test('isSuccess false -> ServerException', () async {
    final adapter = _RecordingAdapter(200, {
      'isSuccess': false,
      'title': 'Terjadi Kesalahan',
      'status': 400,
      'traceId': 'x',
      'errors': ['Kode OTP salah'],
      'data': null,
    });

    expect(
      () => _dataSource(adapter).verifikasiOtpKontak(
        const VerifikasiOtpKontakRequestModel(
          kontak: 1,
          tujuan: '',
          kode: '000000',
        ),
      ),
      throwsA(isA<ServerException>()),
    );
  });
}
