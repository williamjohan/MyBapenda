import 'dart:async';

import 'package:mybapenda/core/enums/app_permission_enum.dart';
import 'package:mybapenda/core/errors/failure.dart';
import 'package:mybapenda/core/services/geo_location/i_geo_location_service.dart';
import 'package:mybapenda/core/services/permission/i_permission_service.dart';
import 'package:mybapenda/domain/entities/coordinate_entity.dart';
import 'package:mybapenda/domain/repositories/geocoding/geocoding_repository.dart';
import 'package:mybapenda/domain/repositories/survey_permohonan/i_survey_permohonan_repository.dart';
import 'package:mybapenda/domain/usecases/survey_permohonan/survey_permohonan_usecase.dart';
import 'package:mybapenda/presentation/features/survey_baru/cubit/survey_lokasi/survey_lokasi_cubit.dart';
import 'package:mybapenda/presentation/features/survey_baru/cubit/survey_lokasi/survey_lokasi_state.dart';
import 'package:mybapenda/presentation/features/survey_baru/utils/survey_lokasi_ui_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLokasi implements IGeoLocationService {
  GeoPosition? posisi;
  Failure? gagal;

  @override
  Future<Either<Failure, GeoPosition>> getCurrentPosition({
    double maxAccuracy = 50,
  }) async {
    final g = gagal;
    return g != null ? Left(g) : Right(posisi!);
  }
}

class _FakeIzin implements IPermissionService {
  int bukaPengaturan = 0;

  @override
  Future<void> openSettings() async => bukaPengaturan++;

  @override
  Future<void> openLocationSettings() async {}

  @override
  Future<void> openBluetoothSettings() async {}

  @override
  Future<AppPermissionStatus> requestPermission(AppPermissionType type) async =>
      AppPermissionStatus.granted;
}

class _FakeGeocoding implements IGeocodingRepository {
  final permintaan = <CoordinateEntity>[];
  Completer<Either<Failure, String>>? tahan;
  Either<Failure, String> hasil = const Right('Jl. Kemlaten X No.20, Kebraon');

  @override
  Future<Either<Failure, String>> getAddressFromCoordinate(CoordinateEntity c) {
    permintaan.add(c);
    return tahan?.future ?? Future.value(hasil);
  }

  @override
  Future<Either<Failure, CoordinateEntity>> getCoordinateFromAddress(
    String query,
  ) => throw UnimplementedError();
}

/// Hanya radius yang dipakai cubit lokasi.
class _FakeSurveyRepo implements ISurveyPermohonanRepository {
  Either<Failure, int> radius = const Left(ServerFailure('gagal'));
  int panggil = 0;
  final berubah = StreamController<int>.broadcast();

  @override
  Stream<int> get radiusBerubah => berubah.stream;

  @override
  Future<Either<Failure, int>> getRadiusSurvey({
    bool forceRefresh = false,
  }) async {
    panggil++;
    return radius;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final _posisi = (
  latitude: -7.3300,
  longitude: 112.7000,
  akurasiMeter: 8.0,
  time: DateTime(2026, 10, 21),
);

void main() {
  late _FakeLokasi lokasi;
  late _FakeIzin izin;
  late _FakeGeocoding geocoding;
  late _FakeSurveyRepo surveyRepo;
  late SurveyLokasiCubit cubit;

  setUp(() {
    lokasi = _FakeLokasi()..posisi = _posisi;
    izin = _FakeIzin();
    geocoding = _FakeGeocoding();
    surveyRepo = _FakeSurveyRepo();
    cubit = SurveyLokasiCubit(
      lokasi,
      izin,
      geocoding,
      SurveyPermohonanUseCase(surveyRepo),
    );
  });

  tearDown(() => cubit.close());

  test('mulai: pin awal = posisi petugas, alamat dimuat, jarak 0', () async {
    await cubit.mulai();

    final s = cubit.state;
    expect(s.status, SurveyLokasiStatus.siap);
    expect(s.pin, (lat: -7.33, lng: 112.7));
    expect(s.alamat, 'Jl. Kemlaten X No.20, Kebraon');
    expect(s.memuatAlamat, isFalse);
    expect(s.jarakMeter, 0);
    expect(s.lokasiSiap, isTrue);
  });

  test('mulai dengan pin draft: pin = titik draft, alamat dimuat', () async {
    await cubit.mulai(pinDraft: (lat: -7.3301, lng: 112.7001));

    final s = cubit.state;
    expect(s.pin, (lat: -7.3301, lng: 112.7001));
    expect(geocoding.permintaan.single.latitude, -7.3301);
    expect(s.alamat, 'Jl. Kemlaten X No.20, Kebraon');
    expect(s.jarakMeter, greaterThan(0));
  });

  test('geser pin: jarak berubah, alamat dimuat ulang saat berhenti', () async {
    await cubit.mulai();
    // ±0.001 derajat lintang ≈ 111 m.
    cubit.geserPin(-7.3310, 112.7000);
    expect(cubit.state.memuatAlamat, isTrue);
    expect(cubit.state.jarakMeter, closeTo(110.6, 1));

    await cubit.pinBerhenti();
    expect(cubit.state.memuatAlamat, isFalse);
    expect(geocoding.permintaan.last.latitude, -7.3310);
  });

  test('idle tanpa geser tidak memuat ulang alamat', () async {
    await cubit.mulai();
    final jumlah = geocoding.permintaan.length;
    await cubit.pinBerhenti();
    expect(geocoding.permintaan.length, jumlah);
  });

  test('alamat lama dibuang bila pin sudah digeser lagi', () async {
    await cubit.mulai();
    geocoding.tahan = Completer();
    cubit.geserPin(-7.3310, 112.7);
    final lama = cubit.pinBerhenti();
    cubit.geserPin(-7.3320, 112.7);
    geocoding.tahan!.complete(const Right('Alamat lama'));
    await lama;
    expect(cubit.state.alamat, isNot('Alamat lama'));
    expect(cubit.state.memuatAlamat, isTrue);
  });

  test('alamat gagal: lokasi tetap siap dengan alamat "-"', () async {
    geocoding.hasil = const Left(GeocodingFailure());
    await cubit.mulai();

    final h = cubit.state.hasil!;
    expect(h.alamat, '-');
    expect(h.akurasiMeter, 8);
  });

  test(
    'GPS ditolak layanan lokasi (fake GPS / akurasi): gagal tanpa pin',
    () async {
      lokasi.gagal = const LocationHardwareFailure('Fake GPS terdeteksi.');
      await cubit.mulai();
      expect(cubit.state.status, SurveyLokasiStatus.gagal);
      expect(cubit.state.pin, isNull);
      expect(cubit.state.pesanError, 'Fake GPS terdeteksi.');
      expect(cubit.state.requiresLocationSettings, isFalse);
    },
  );

  test('GPS mati / izin ditolak: pesan + tombol pengaturan', () async {
    lokasi.gagal = const PermissionFailure('Sensor GPS mati.');
    await cubit.mulai();
    expect(cubit.state.status, SurveyLokasiStatus.gagal);
    expect(cubit.state.requiresLocationSettings, isTrue);
    expect(cubit.state.pesanError, 'Sensor GPS mati.');

    await cubit.bukaPengaturanLokasi();
    expect(izin.bukaPengaturan, 1);
  });

  test('buka ulang dengan hasil sebelumnya: pin & alamat dipulihkan', () async {
    await cubit.mulai(
      awal: (
        lat: -7.3301,
        lng: 112.7,
        alamat: 'Jl. A, Surabaya',
        jarakMeter: 11,
        petugasLat: 0,
        petugasLng: 0,
        akurasiMeter: 0,
      ),
    );
    expect(cubit.state.pin, (lat: -7.3301, lng: 112.7));
    expect(cubit.state.alamat, 'Jl. A, Surabaya');
    expect(geocoding.permintaan, isEmpty);
    expect(cubit.state.lokasiSiap, isTrue);
  });

  test('pin lebih dari 20 m dari petugas: tidak bisa lanjut', () async {
    await cubit.mulai();

    // ±0.00015 derajat lintang ≈ 17 m: masih boleh.
    cubit.geserPin(-7.33015, 112.7);
    await cubit.pinBerhenti();
    expect(cubit.state.terlaluJauh, isFalse);
    expect(cubit.state.lokasiSiap, isTrue);

    // ±0.0002 derajat ≈ 22 m: ditolak.
    cubit.geserPin(-7.3302, 112.7);
    await cubit.pinBerhenti();
    expect(cubit.state.terlaluJauh, isTrue);
    expect(cubit.state.lokasiSiap, isFalse);
    expect(cubit.state.hasil, isNull);
  });

  test('radius dari survey-form dipakai, setting tidak dipanggil', () async {
    await cubit.mulai(jarakMaksMeter: 30);

    expect(cubit.state.jarakMaksMeter, 30);
    expect(surveyRepo.panggil, 0);
    // ±0.0002 derajat ≈ 22 m: masih di dalam 30 m.
    cubit.geserPin(-7.3302, 112.7);
    await cubit.pinBerhenti();
    expect(cubit.state.terlaluJauh, isFalse);
  });

  test('survey-form kosong: radius dari pengaturan-radius-survey', () async {
    surveyRepo.radius = const Right(50);
    await cubit.mulai();

    expect(cubit.state.jarakMaksMeter, 50);
    expect(surveyRepo.panggil, 1);
  });

  test('push radius baru saat halaman terbuka: langsung dipakai', () async {
    await cubit.mulai(jarakMaksMeter: 20);
    surveyRepo.berubah.add(40);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.jarakMaksMeter, 40);
  });

  test('setting gagal & belum ada cache: radius bawaan 20 m', () async {
    await cubit.mulai();
    expect(cubit.state.jarakMaksMeter, 20);
  });

  group('SurveyLokasiUiHelper', () {
    test('jarak', () {
      expect(SurveyLokasiUiHelper.jarak(8.4), '8 m');
      expect(SurveyLokasiUiHelper.jarak(999), '999 m');
      expect(SurveyLokasiUiHelper.jarak(1250), '1,3 km');
    });

    test('alamat: judul = bagian pertama', () {
      final a = SurveyLokasiUiHelper.alamat('Jl. Kemlaten X No.20, Kebraon');
      expect(a.judul, 'Jl. Kemlaten X No.20');
      expect(SurveyLokasiUiHelper.alamat('-').judul, 'Alamat tidak ditemukan');
    });
  });
}
