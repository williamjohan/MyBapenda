import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/domain/entities/profile/foto_profil_entity.dart';
import 'package:bapendacore/domain/entities/profile/jenis_kontak.dart';
import 'package:bapendacore/domain/entities/profile/kontak_profil_entity.dart';
import 'package:bapendacore/domain/repositories/profile/i_profile_repository.dart';
import 'package:bapendacore/domain/usecases/profile/profile_usecase.dart';
import 'package:bapendacore/presentation/features/profile/cubit/ubah_kontak_cubit.dart';
import 'package:bapendacore/presentation/features/profile/cubit/ubah_kontak_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

const _kontakBaru = KontakProfilEntity(
  hp: '0895349690206',
  email: 'baru@mail.com',
  isValidEmail: true,
  isValidWa: true,
);

class _FakeProfileRepository implements IProfileRepository {
  Either<Failure, KirimOtpEntity> kirim = const Right(
    KirimOtpEntity(sisaBerlakuDetik: 300, sisaJedaKirimDetik: 0),
  );
  Either<Failure, KontakProfilEntity> verifikasi = const Right(_kontakBaru);

  final kirimTujuan = <String>[];
  JenisKontak? kirimKontak;
  ({String tujuan, String kode})? verifikasiArgs;

  @override
  Future<Either<Failure, KirimOtpEntity>> kirimOtpKontak({
    required JenisKontak kontak,
    required String tujuan,
  }) async {
    kirimKontak = kontak;
    kirimTujuan.add(tujuan);
    return kirim;
  }

  @override
  Future<Either<Failure, KontakProfilEntity>> verifikasiOtpKontak({
    required JenisKontak kontak,
    required String tujuan,
    required String kode,
  }) async {
    verifikasiArgs = (tujuan: tujuan, kode: kode);
    return verifikasi;
  }

  @override
  Future<Either<Failure, FotoProfilEntity>> gantiFoto(String fotoPath) =>
      throw UnimplementedError();
}

void main() {
  late _FakeProfileRepository repo;
  late UbahKontakCubit cubit;

  setUp(() {
    repo = _FakeProfileRepository();
    cubit = UbahKontakCubit(ProfileUseCase(repo))
      ..mulai(kontak: JenisKontak.email, nilaiSekarang: 'lama@mail.com');
  });

  tearDown(() => cubit.close());

  group('kirimOtp', () {
    test(
      'email baru -> tujuan dikirim apa adanya, pindah ke langkah OTP',
      () async {
        await cubit.kirimOtp('  baru@mail.com ');

        expect(repo.kirimKontak, JenisKontak.email);
        expect(repo.kirimTujuan, ['baru@mail.com']);
        expect(cubit.state.step, UbahKontakStep.otp);
        expect(cubit.state.tujuanTampil, 'baru@mail.com');
        expect(cubit.state.info, 'Kode OTP telah dikirim ke baru@mail.com');
      },
    );

    test('sama dengan kontak sekarang -> tujuan kosong (verifikasi)', () async {
      await cubit.kirimOtp('LAMA@mail.com');

      expect(repo.kirimTujuan, ['']);
      expect(cubit.state.tujuanTampil, 'LAMA@mail.com');
    });

    test('format email salah -> error, API tidak dipanggil', () async {
      await cubit.kirimOtp('bukan-email');

      expect(cubit.state.error, 'Format email tidak valid.');
      expect(cubit.state.step, UbahKontakStep.input);
      expect(repo.kirimTujuan, isEmpty);
    });

    test('kosong -> wajib diisi', () async {
      await cubit.kirimOtp('   ');

      expect(cubit.state.error, 'Email wajib diisi.');
      expect(repo.kirimTujuan, isEmpty);
    });

    test('no WA harus diawali 08', () async {
      cubit.mulai(kontak: JenisKontak.whatsapp, nilaiSekarang: '');

      await cubit.kirimOtp('62895349690206');

      expect(cubit.state.error, contains('diawali 08'));
      expect(repo.kirimTujuan, isEmpty);

      await cubit.kirimOtp('0895349690206');
      expect(repo.kirimKontak, JenisKontak.whatsapp);
      expect(repo.kirimTujuan, ['0895349690206']);
    });

    test('API gagal -> tetap di langkah input dengan pesan server', () async {
      repo.kirim = const Left(
        ServerFailure('Email sudah dipakai pegawai lain'),
      );

      await cubit.kirimOtp('baru@mail.com');

      expect(cubit.state.step, UbahKontakStep.input);
      expect(cubit.state.mengirim, isFalse);
      expect(cubit.state.error, 'Email sudah dipakai pegawai lain');
    });

    test('jeda kirim ulang dihitung mundur', () async {
      repo.kirim = const Right(
        KirimOtpEntity(sisaBerlakuDetik: 300, sisaJedaKirimDetik: 60),
      );

      await cubit.kirimOtp('baru@mail.com');

      expect(cubit.state.sisaJedaDetik, 60);
      expect(cubit.state.bolehKirimUlang, isFalse);

      await cubit.kirimUlang(); // diabaikan selama jeda
      expect(repo.kirimTujuan, ['baru@mail.com']);
    });

    test('kirim ulang memakai tujuan yang sama', () async {
      await cubit.kirimOtp('baru@mail.com');
      await cubit.kirimUlang();

      expect(repo.kirimTujuan, ['baru@mail.com', 'baru@mail.com']);
    });
  });

  group('verifikasi', () {
    setUp(() => cubit.kirimOtp('baru@mail.com'));

    test('kode valid -> selesai dengan kontak terbaru', () async {
      await cubit.verifikasi('123456');

      expect(repo.verifikasiArgs, (tujuan: 'baru@mail.com', kode: '123456'));
      expect(cubit.state.step, UbahKontakStep.selesai);
      expect(cubit.state.hasil, _kontakBaru);
    });

    test('kode bukan 6 digit -> error, API tidak dipanggil', () async {
      await cubit.verifikasi('12a4');

      expect(cubit.state.error, 'Kode OTP harus 6 digit angka.');
      expect(repo.verifikasiArgs, isNull);
    });

    test('kode salah dari server -> tetap di langkah OTP', () async {
      repo.verifikasi = const Left(ServerFailure('Kode OTP salah'));

      await cubit.verifikasi('000000');

      expect(cubit.state.step, UbahKontakStep.otp);
      expect(cubit.state.memverifikasi, isFalse);
      expect(cubit.state.error, 'Kode OTP salah');
    });
  });

  test('ubahTujuan -> kembali ke langkah input', () async {
    await cubit.kirimOtp('baru@mail.com');

    cubit.ubahTujuan();

    expect(cubit.state.step, UbahKontakStep.input);
    expect(cubit.state.sisaJedaDetik, 0);
  });
}
