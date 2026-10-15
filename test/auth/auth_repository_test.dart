import 'dart:convert';

import 'package:bapendacore/core/errors/exception.dart';
import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/core/storage/app_secure_storage.dart';
import 'package:bapendacore/data/datasources/auth/auth_remote_datasource.dart';
import 'package:bapendacore/data/models/auth/auth_model.dart';
import 'package:bapendacore/data/models/users/user_model.dart';
import 'package:bapendacore/data/repositories/auth/auth_repository_impl.dart';
import 'package:bapendacore/domain/entities/auth/lupa_password_metode.dart';
import 'package:bapendacore/domain/entities/users/user_entity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

const _keyNip = 'SECURE_CURRENT_NIP';
const _keyMustChange = 'SECURE_MUST_CHANGE_PASSWORD';
const _keyProfile = 'SECURE_USER_PROFILE';

const _user = UserModel(
  nip: '3578103004020008',
  nama: 'ROYAN HISYAM RAFLIANSYAH, S. KOM',
  alamat: 'SURABAYA',
  hp: '0895349690206',
  email: 'ryn.rafliansyah@gmail.com',
  jenisPegawai: 'Tenaga Ahli',
  aktif: 'Aktif',
  tglLahir: '2002-04-30 00:00:00',
  bidang: 'BIDANG PAJAK',
  jabatan: 'IT BAPENDA',
  golongan: 'NON PNS',
);

class _FakeDataSource implements AuthRemoteDataSource {
  final List<LupaPasswordRequestModel> lupaSent = [];
  final List<ResetPasswordRequestModel> resetSent = [];
  final List<String> profileNips = [];
  Object? error; // diisi = semua method melempar error ini

  @override
  Future<bool> lupaPassword(LupaPasswordRequestModel request) async {
    if (error != null) throw error!;
    lupaSent.add(request);
    return true;
  }

  @override
  Future<bool> resetPassword(ResetPasswordRequestModel request) async {
    if (error != null) throw error!;
    resetSent.add(request);
    return true;
  }

  @override
  Future<UserModel> getProfile({required String nip}) async {
    if (error != null) throw error!;
    profileNips.add(nip);
    return _user;
  }

  @override
  Future<AuthResponseModel> login(AuthRequestModel request) =>
      throw UnimplementedError();
}

(AuthRepositoryImpl, _FakeDataSource) _repo({
  Map<String, String> secure = const {},
}) {
  FlutterSecureStorage.setMockInitialValues(Map.of(secure));
  final ds = _FakeDataSource();
  return (
    AuthRepositoryImpl(ds, AppSecureStorage(const FlutterSecureStorage())),
    ds,
  );
}

Future<String?> _read(String key) =>
    const FlutterSecureStorage().read(key: key);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('lupaPassword', () {
    test('metode dipetakan ke channel EChannelKodeReset', () async {
      final (repo, ds) = _repo();

      await repo.lupaPassword(
        nip: '1',
        metode: LupaPasswordMetode.email,
        tujuan: 'a@b.c',
      );
      await repo.lupaPassword(
        nip: '1',
        metode: LupaPasswordMetode.whatsapp,
        tujuan: '08123456789',
      );

      expect(ds.lupaSent.map((r) => r.channel), [1, 2]);
      expect(ds.lupaSent.last.toJson(), {
        'nip': '1',
        'channel': 2,
        'tujuan': '08123456789',
      });
    });

    test('ServerException -> ServerFailure dengan pesan server', () async {
      final (repo, ds) = _repo();
      ds.error = const ServerException(404, 'NIP tidak terdaftar');

      final result = await repo.lupaPassword(
        nip: '1',
        metode: LupaPasswordMetode.email,
        tujuan: 'a@b.c',
      );

      expect(result.isLeft(), isTrue);
      result.fold((f) {
        expect(f, isA<ServerFailure>());
        expect(f.message, 'NIP tidak terdaftar');
      }, (_) => fail('harusnya gagal'));
    });
  });

  group('resetPassword', () {
    test('berhasil -> flag wajib ganti kata sandi dihapus', () async {
      final (repo, ds) = _repo(secure: {_keyMustChange: 'true'});

      final result = await repo.resetPassword(
        newPassword: 'Rahasia#123',
        confirmationPassword: 'Rahasia#123',
      );

      expect(result.isRight(), isTrue);
      expect(ds.resetSent.single.toJson(), {
        'newPassword': 'Rahasia#123',
        'confirmationPassword': 'Rahasia#123',
      });
      expect(await _read(_keyMustChange), isNull);
      expect(await repo.getMustChangePassword(), isFalse);
    });

    test('gagal -> flag tetap ada', () async {
      final (repo, ds) = _repo(secure: {_keyMustChange: 'true'});
      ds.error = const NoInternetException();

      final result = await repo.resetPassword(
        newPassword: 'a',
        confirmationPassword: 'a',
      );

      result.fold(
        (f) => expect(f, isA<NoInternetFailure>()),
        (_) => fail('harusnya gagal'),
      );
      expect(await repo.getMustChangePassword(), isTrue);
    });
  });

  group('getProfile', () {
    test('pakai NIP tersimpan & perbarui cache profil', () async {
      final (repo, ds) = _repo(secure: {_keyNip: '3578103004020008'});

      final result = await repo.getProfile();

      expect(ds.profileNips, ['3578103004020008']);
      result.fold(
        (_) => fail('harusnya berhasil'),
        (user) => expect(user.nama, _user.nama),
      );
      final cached = jsonDecode((await _read(_keyProfile))!);
      expect(cached['jabatan'], 'IT BAPENDA');
      expect(await repo.getCurrentUserProfile(), isA<UserEntity>());
    });

    test(
      'belum ada NIP tersimpan -> UnauthorizedFailure tanpa hit API',
      () async {
        final (repo, ds) = _repo();

        final result = await repo.getProfile();

        result.fold(
          (f) => expect(f, isA<UnauthorizedFailure>()),
          (_) => fail('harusnya gagal'),
        );
        expect(ds.profileNips, isEmpty);
      },
    );

    test('API gagal -> cache lama tidak diubah', () async {
      final (repo, ds) = _repo(
        secure: {_keyNip: '1', _keyProfile: '{"lama":true}'},
      );
      ds.error = const TimeoutException();

      final result = await repo.getProfile();

      result.fold(
        (f) => expect(f, isA<TimeoutFailure>()),
        (_) => fail('harusnya gagal'),
      );
      expect(await _read(_keyProfile), '{"lama":true}');
    });
  });
}
