import 'dart:async';

import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/domain/repositories/survey_permohonan/i_survey_permohonan_repository.dart';
import 'package:bapendacore/domain/usecases/survey_permohonan/survey_permohonan_usecase.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_radius/survey_radius_cubit.dart';
import 'package:bapendacore/presentation/features/survey_baru/screens/survey_foto_page.dart';
import 'package:bapendacore/presentation/features/survey_baru/utils/survey_lokasi_ui_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSurveyRepo implements ISurveyPermohonanRepository {
  Completer<Either<Failure, int>> radius = Completer();
  final berubah = StreamController<int>.broadcast();

  @override
  Stream<int> get radiusBerubah => berubah.stream;

  @override
  Future<Either<Failure, int>> getRadiusSurvey({bool forceRefresh = false}) =>
      radius.future;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  group('SurveyLokasiUiHelper.sisiDiLuarRadius', () {
    test('penolakan jarak: nomor sisi terbaca', () {
      expect(
        SurveyLokasiUiHelper.sisiDiLuarRadius(
          'Titik reklame sisi ke-2 lebih dari 20 m dari lokasi petugas '
          '(jarak 34 m).',
        ),
        2,
      );
    });

    test('pesan lain: null', () {
      expect(
        SurveyLokasiUiHelper.sisiDiLuarRadius('Foto sisi ke-1 wajib diisi'),
        isNull,
      );
    });
  });

  test('diLuarRadius: jarak saat pin dipasang dibanding radius sekarang', () {
    const l = (
      lat: -7.33,
      lng: 112.7,
      alamat: '-',
      jarakMeter: 18.0,
      petugasLat: -7.33,
      petugasLng: 112.7,
      akurasiMeter: 5.0,
    );
    expect(SurveyLokasiUiHelper.diLuarRadius(l, 20), isFalse);
    expect(SurveyLokasiUiHelper.diLuarRadius(l, 15), isTrue);
    expect(SurveyLokasiUiHelper.diLuarRadius(null, 15), isFalse);
  });

  test('sisiKe: seq dulu, lalu urutan', () {
    final list = [
      {'seq': 3},
      {'seq': 5},
    ];
    expect(sisiKe(list, 5), {'seq': 5});
    expect(sisiKe(list, 1), {'seq': 3});
    expect(sisiKe(list, 9), isNull);
  });

  group('SurveyRadiusCubit', () {
    late _FakeSurveyRepo repo;
    late SurveyRadiusCubit cubit;

    setUp(() {
      repo = _FakeSurveyRepo();
      cubit = SurveyRadiusCubit(SurveyPermohonanUseCase(repo));
    });

    tearDown(() => cubit.close());

    test('nilai survey-form langsung dipakai, lalu push menimpa', () async {
      await cubit.mulai(dariForm: 30);
      expect(cubit.state, 30);

      repo.berubah.add(15);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, 15);
    });

    test('setting cadangan datang setelah push: push tetap menang', () async {
      final mulai = cubit.mulai();
      repo.berubah.add(15);
      await Future<void>.delayed(Duration.zero);
      repo.radius.complete(const Right(50));
      await mulai;
      expect(cubit.state, 15);
    });
  });
}
