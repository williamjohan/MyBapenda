import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/domain/entities/auth/auth_entity.dart';
import 'package:bapendacore/domain/entities/auth/lupa_password_metode.dart';
import 'package:bapendacore/domain/entities/users/user_entity.dart';
import 'package:bapendacore/domain/repositories/auth/auth_repository.dart';
import 'package:bapendacore/domain/usecases/auth/auth_usecase.dart';
import 'package:bapendacore/presentation/features/profile/cubit/profile_cubit.dart';
import 'package:bapendacore/presentation/features/profile/cubit/profile_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

UserEntity _user({String jabatan = 'IT BAPENDA'}) => UserEntity(
  nip: '3578103004020008',
  nama: 'ROYAN HISYAM RAFLIANSYAH, S. KOM',
  alamat: 'SURABAYA',
  hp: '0895349690206',
  email: 'ryn.rafliansyah@gmail.com',
  jenisPegawai: 'Tenaga Ahli',
  aktif: 'Aktif',
  tglLahir: '2002-04-30 00:00:00',
  bidang: 'BIDANG PAJAK',
  jabatan: jabatan,
  golongan: 'NON PNS',
);

class _FakeRepository implements AuthRepository {
  UserEntity? cached;
  Either<Failure, UserEntity> remote = Right(_user(jabatan: 'JABATAN BARU'));
  int remoteCalls = 0;

  @override
  Future<UserEntity?> getCurrentUserProfile() async => cached;

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    remoteCalls++;
    return remote;
  }

  @override
  Future<AuthResponseEntity> login({
    required String nip,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();

  @override
  Future<bool> getCurrentSession() => throw UnimplementedError();

  @override
  Future<bool> getMustChangePassword() => throw UnimplementedError();

  @override
  Future<Either<Failure, bool>> lupaPassword({
    required String nip,
    required LupaPasswordMetode metode,
    required String tujuan,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, bool>> resetPassword({
    required String newPassword,
    required String confirmationPassword,
  }) => throw UnimplementedError();
}

void main() {
  late _FakeRepository repo;
  late ProfileCubit cubit;

  setUp(() {
    repo = _FakeRepository();
    cubit = ProfileCubit(AuthUseCase(repo));
  });

  tearDown(() => cubit.close());

  test('state awal loading tanpa data', () {
    expect(cubit.state.status, ProfileStatus.loading);
    expect(cubit.state.user, isNull);
  });

  test('cache tampil dulu, lalu diganti data server', () async {
    repo.cached = _user();
    final states = <ProfileState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.load();
    await sub.cancel();

    expect(states.first.status, ProfileStatus.ready);
    expect(states.first.user!.jabatan, 'IT BAPENDA'); // dari cache
    expect(cubit.state.status, ProfileStatus.ready);
    expect(cubit.state.user!.jabatan, 'JABATAN BARU'); // dari server
    expect(cubit.state.refreshing, isFalse);
    expect(cubit.state.error, isNull);
    expect(repo.remoteCalls, 1);
  });

  test('tanpa cache & server berhasil -> ready', () async {
    await cubit.load();

    expect(cubit.state.status, ProfileStatus.ready);
    expect(cubit.state.user!.jabatan, 'JABATAN BARU');
  });

  test('server gagal tapi ada cache -> tetap ready + pesan error', () async {
    repo.cached = _user();
    repo.remote = const Left(NoInternetFailure());

    await cubit.load();

    expect(cubit.state.status, ProfileStatus.ready);
    expect(cubit.state.user!.jabatan, 'IT BAPENDA');
    expect(cubit.state.error, const NoInternetFailure().message);
    expect(cubit.state.refreshing, isFalse);
  });

  test('server gagal tanpa cache -> failure', () async {
    repo.remote = const Left(ServerFailure('Pegawai tidak ditemukan'));

    await cubit.load();

    expect(cubit.state.status, ProfileStatus.failure);
    expect(cubit.state.user, isNull);
    expect(cubit.state.error, 'Pegawai tidak ditemukan');
  });

  test('refresh setelah gagal -> error hilang saat berhasil', () async {
    repo.remote = const Left(TimeoutFailure());
    await cubit.load();
    expect(cubit.state.status, ProfileStatus.failure);

    repo.remote = Right(_user());
    await cubit.refresh();

    expect(cubit.state.status, ProfileStatus.ready);
    expect(cubit.state.error, isNull);
    expect(repo.remoteCalls, 2);
  });
}
