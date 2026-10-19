import 'dart:async';

import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/core/services/geo_location_service.dart';
import 'package:bapendacore/domain/entities/coordinate_entity.dart';
import 'package:bapendacore/domain/repositories/geocoding/geocoding_repository.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_lokasi/survey_lokasi_cubit.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_lokasi/survey_lokasi_state.dart';
import 'package:bapendacore/presentation/features/survey_baru/utils/survey_lokasi_ui_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLokasi implements GeoLocationService {
  GeoPosition? posisi;
  GeoLocationError? error;

  @override
  Future<GeoPosition> getCurrentPosition() async {
    if (error != null) throw GeoLocationException(error!);
    return posisi!;
  }

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> openLocationSettings() async {}
}

class _FakeGeocoding implements GeocodingRepository {
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

const _posisi = GeoPosition(
  latitude: -7.3300,
  longitude: 112.7000,
  akurasiMeter: 8,
  isMocked: false,
);

void main() {
  late _FakeLokasi lokasi;
  late _FakeGeocoding geocoding;
  late SurveyLokasiCubit cubit;

  setUp(() {
    lokasi = _FakeLokasi()..posisi = _posisi;
    geocoding = _FakeGeocoding();
    cubit = SurveyLokasiCubit(lokasi, geocoding);
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

  test('fake GPS ditolak', () async {
    lokasi.posisi = const GeoPosition(
      latitude: -7.33,
      longitude: 112.7,
      akurasiMeter: 5,
      isMocked: true,
    );
    await cubit.mulai();
    expect(cubit.state.status, SurveyLokasiStatus.gagal);
    expect(cubit.state.pin, isNull);
  });

  test('GPS mati: pesan + kode error untuk tombol pengaturan', () async {
    lokasi.error = GeoLocationError.serviceDisabled;
    await cubit.mulai();
    expect(cubit.state.status, SurveyLokasiStatus.gagal);
    expect(cubit.state.kodeError, GeoLocationError.serviceDisabled);
    expect(cubit.state.pesanError, 'GPS HP mati. Nyalakan GPS.');
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
