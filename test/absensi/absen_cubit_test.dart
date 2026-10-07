import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/core/services/geo_location_service.dart';
import 'package:bapendacore/domain/entities/absensi/absen_entity.dart';
import 'package:bapendacore/domain/entities/absensi/riwayat_absensi_entity.dart';
import 'package:bapendacore/domain/entities/absensi/ringkasan_absensi_entity.dart';
import 'package:bapendacore/domain/repositories/absensi/absensi_repository.dart';
import 'package:bapendacore/domain/usecases/absensi/absensi_usecase.dart';
import 'package:bapendacore/presentation/features/absensi/cubit/absen/absen_cubit.dart';
import 'package:bapendacore/presentation/features/absensi/cubit/absen/absen_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements AbsensiRepository {
  Either<Failure, AbsenResultEntity> absenResult = Right(_result);
  final List<AbsenParams> sent = [];

  @override
  Future<Either<Failure, AbsenResultEntity>> absen(AbsenParams params) async {
    sent.add(params);
    return absenResult;
  }

  @override
  Future<Either<Failure, RingkasanAbsensiEntity>> getRingkasan({
    DateTime? tanggal,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, RiwayatAbsensiPageResult>> getRiwayat({
    required int page,
    int pageSize = 20,
    int? tahun,
    int? bulan,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, String>> downloadLaporanPdf({
    required int tahun,
    required int bulan,
    void Function(double? progress)? onProgress,
  }) => throw UnimplementedError();
}

class _FakeLocation implements GeoLocationService {
  GeoPosition? position = const GeoPosition(
    latitude: -7.2593812,
    longitude: 112.7495031,
    akurasiMeter: 8.5,
    isMocked: false,
  );
  GeoLocationError? error;

  @override
  Future<GeoPosition> getCurrentPosition() async {
    if (error != null) throw GeoLocationException(error!);
    return position!;
  }

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> openLocationSettings() async {}
}

final _ringkasan = RingkasanAbsensiEntity(
  nip: '1',
  nama: 'A',
  tanggal: DateTime(2026, 10, 2),
  masuk: DateTime(2026, 10, 2, 7, 12, 41),
);

final _result = AbsenResultEntity(
  message: 'Absen masuk tercatat',
  tglPresensi: DateTime(2026, 10, 2, 7, 12, 41),
  jenis: JenisAbsen.masuk,
  ringkasan: _ringkasan,
);

void main() {
  late _FakeRepository repository;
  late _FakeLocation location;
  late AbsenCubit cubit;

  setUp(() {
    repository = _FakeRepository();
    location = _FakeLocation();
    cubit = AbsenCubit(AbsensiUseCase(repository), location);
  });

  tearDown(() => cubit.close());

  test('alur sukses: lokasi → kirim → sukses (tanpa PIN/biometrik)', () async {
    final states = expectLater(
      cubit.stream,
      emitsInOrder([
        const AbsenInProgress(AbsenStep.locating),
        const AbsenInProgress(AbsenStep.submitting),
        AbsenSuccess(_result),
      ]),
    );
    await cubit.submit();
    await states;

    expect(repository.sent.single.isMockLocation, isFalse);
    expect(repository.sent.single.metodeVerifikasi, 'HOLD_HP');
  });

  test('fake GPS tetap dikirim dengan isMockLocation=true', () async {
    location.position = const GeoPosition(
      latitude: 0,
      longitude: 0,
      akurasiMeter: 5,
      isMocked: true,
    );
    repository.absenResult = const Left(
      ServerFailure('Lokasi palsu terdeteksi. Matikan aplikasi fake GPS.'),
    );

    await cubit.submit();

    expect(repository.sent.single.isMockLocation, isTrue);
    expect(
      cubit.state,
      const AbsenFailure('Lokasi palsu terdeteksi. Matikan aplikasi fake GPS.'),
    );
  });

  test('GPS mati → AbsenLocationRequired', () async {
    location.error = GeoLocationError.serviceDisabled;

    await cubit.submit();

    expect(
      cubit.state,
      const AbsenLocationRequired(GeoLocationError.serviceDisabled),
    );
    expect(repository.sent, isEmpty);
  });

  test('submit ganda selama proses hanya mengirim satu request', () async {
    await Future.wait([cubit.submit(), cubit.submit()]);

    expect(repository.sent, hasLength(1));
  });
}
