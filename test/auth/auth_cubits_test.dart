import 'package:mybapenda/core/errors/failure.dart';
import 'package:mybapenda/domain/entities/auth/auth_entity.dart';
import 'package:mybapenda/domain/entities/auth/lupa_password_metode.dart';
import 'package:mybapenda/domain/entities/users/user_entity.dart';
import 'package:mybapenda/domain/repositories/auth/auth_repository.dart';
import 'package:mybapenda/domain/usecases/auth/auth_usecase.dart';
import 'package:mybapenda/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:mybapenda/presentation/features/auth/cubit/auth_state.dart';
import 'package:mybapenda/presentation/features/auth/cubit/lupa_password_cubit.dart';
import 'package:mybapenda/presentation/features/auth/cubit/lupa_password_state.dart';
import 'package:mybapenda/presentation/features/auth/cubit/reset_password_cubit.dart';
import 'package:mybapenda/presentation/features/auth/cubit/reset_password_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements IAuthRepository {
  Either<Failure, bool> lupaResult = const Right(true);
  Either<Failure, bool> resetResult = const Right(true);
  bool loginIsReset = false;

  final List<({String nip, LupaPasswordMetode metode, String tujuan})>
  lupaSent = [];
  final List<(String, String)> resetSent = [];

  @override
  Future<Either<Failure, bool>> lupaPassword({
    required String nip,
    required LupaPasswordMetode metode,
    required String tujuan,
  }) async {
    lupaSent.add((nip: nip, metode: metode, tujuan: tujuan));
    return lupaResult;
  }

  @override
  Future<Either<Failure, bool>> resetPassword({
    required String newPassword,
    required String confirmationPassword,
  }) async {
    resetSent.add((newPassword, confirmationPassword));
    return resetResult;
  }

  @override
  Future<AuthResponseEntity> login({
    required String nip,
    required String password,
  }) async => AuthResponseEntity(token: 'jwt', isResetPassword: loginIsReset);

  @override
  Future<void> logout() async {}

  @override
  Future<bool> getCurrentSession() async => true;

  @override
  Future<bool> getMustChangePassword() async => loginIsReset;

  @override
  Future<UserEntity?> getCurrentUserProfile() async => null;

  @override
  Future<Either<Failure, UserEntity>> getProfile() =>
      throw UnimplementedError();
}

void main() {
  late _FakeRepository repo;
  late AuthUseCase useCase;

  setUp(() {
    repo = _FakeRepository();
    useCase = AuthUseCase(repo);
  });

  group('LupaPasswordCubit', () {
    test('berhasil: Loading -> Success berisi tujuan', () async {
      final cubit = LupaPasswordCubit(useCase);
      final states = expectLater(
        cubit.stream,
        emitsInOrder(const <LupaPasswordState>[
          LupaPasswordLoading(),
          LupaPasswordSuccess('0895349690206'),
        ]),
      );

      await cubit.submit(
        nip: '3578103004020008',
        metode: LupaPasswordMetode.whatsapp,
        tujuan: '0895349690206',
      );
      await states;

      expect(repo.lupaSent.single.metode, LupaPasswordMetode.whatsapp);
      expect(repo.lupaSent.single.nip, '3578103004020008');
    });

    test('gagal: pesan Failure diteruskan ke UI', () async {
      repo.lupaResult = const Left(ServerFailure('NIP tidak terdaftar'));
      final cubit = LupaPasswordCubit(useCase);

      await cubit.submit(
        nip: '1',
        metode: LupaPasswordMetode.email,
        tujuan: 'a@b.c',
      );

      expect(cubit.state, const LupaPasswordFailure('NIP tidak terdaftar'));
    });

    test('reset kembali ke Idle', () async {
      final cubit = LupaPasswordCubit(useCase);
      await cubit.submit(
        nip: '1',
        metode: LupaPasswordMetode.email,
        tujuan: 'a@b.c',
      );

      cubit.reset();

      expect(cubit.state, const LupaPasswordIdle());
    });
  });

  group('ResetPasswordCubit', () {
    test('berhasil: Loading -> Success, kirim dua kata sandi', () async {
      final cubit = ResetPasswordCubit(useCase);
      final states = expectLater(
        cubit.stream,
        emitsInOrder(const <ResetPasswordState>[
          ResetPasswordLoading(),
          ResetPasswordSuccess(),
        ]),
      );

      await cubit.submit(
        newPassword: 'Rahasia#123',
        confirmationPassword: 'Rahasia#123',
      );
      await states;

      expect(repo.resetSent.single, ('Rahasia#123', 'Rahasia#123'));
    });

    test('gagal: Failure dengan pesan server', () async {
      repo.resetResult = const Left(ServerFailure('Kata sandi terlalu lemah'));
      final cubit = ResetPasswordCubit(useCase);

      await cubit.submit(newPassword: 'a', confirmationPassword: 'a');

      expect(
        cubit.state,
        const ResetPasswordFailure('Kata sandi terlalu lemah'),
      );
    });

    test('submit ganda saat Loading diabaikan', () async {
      final cubit = ResetPasswordCubit(useCase);

      await Future.wait([
        cubit.submit(newPassword: 'a', confirmationPassword: 'a'),
        cubit.submit(newPassword: 'a', confirmationPassword: 'a'),
      ]);

      expect(repo.resetSent, hasLength(1));
    });
  });

  group('AuthCubit', () {
    test('login dengan reset key -> AuthNeedsPasswordReset', () async {
      repo.loginIsReset = true;
      final cubit = AuthCubit(authUseCase: useCase);

      await cubit.login('1', 'RESETKEY');

      expect(cubit.state, const AuthNeedsPasswordReset());
    });

    test('login biasa -> AuthAuthenticated', () async {
      final cubit = AuthCubit(authUseCase: useCase);

      await cubit.login('1', 'password');

      expect(cubit.state, const AuthAuthenticated());
    });

    test('buka ulang aplikasi saat belum reset -> tetap wajib reset', () async {
      repo.loginIsReset = true;
      final cubit = AuthCubit(authUseCase: useCase);

      await cubit.checkSession();

      expect(cubit.state, const AuthNeedsPasswordReset());
    });

    test('passwordResetCompleted -> AuthAuthenticated', () async {
      repo.loginIsReset = true;
      final cubit = AuthCubit(authUseCase: useCase);
      await cubit.login('1', 'RESETKEY');

      cubit.passwordResetCompleted();

      expect(cubit.state, const AuthAuthenticated());
    });
  });
}
