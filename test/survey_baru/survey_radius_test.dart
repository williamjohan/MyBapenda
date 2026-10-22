import 'dart:convert';

import 'package:mybapenda/core/errors/exception.dart';
import 'package:mybapenda/core/storage/survey_radius_storage.dart';
import 'package:mybapenda/data/datasources/cek_reklame/survey_remote_datasource.dart';
import 'package:mybapenda/data/models/survey_permohonan_baru/survey_detail_model.dart';
import 'package:mybapenda/data/repositories/cek_reklame/survey_permohonan_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hanya survey-form & pengaturan radius yang dipakai test ini.
class _FakeRemote implements ISurveyPermohonanRemoteDataSource {
  int? radius = 25;
  int? radiusForm;
  bool gagal = false;
  int panggil = 0;

  @override
  Future<int?> getRadiusSurvey() async {
    panggil++;
    if (gagal) throw const ServerException(500, 'gagal');
    return radius;
  }

  @override
  Future<SurveyDetailModel> getSurveyDetail({required String key}) async =>
      SurveyDetailModel.fromJson({
        'key': key,
        'noPelayanan': 'P1',
        'npwpd': 'N1',
        'katPenyelenggaraan': '1',
        'jarakMaksMeter': radiusForm,
        'sisiList': <Map<String, dynamic>>[],
      });

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

const _key = 'survey_radius_maks_meter_v1';

String _cache(int meter, DateTime tgl) =>
    jsonEncode({'tgl': tgl.toIso8601String(), 'meter': meter});

void main() {
  late _FakeRemote remote;

  Future<SurveyPermohonanRepositoryImpl> repo([
    Map<String, Object> awal = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(awal);
    final prefs = await SharedPreferences.getInstance();
    return SurveyPermohonanRepositoryImpl(remote, SurveyRadiusStorage(prefs));
  }

  setUp(() => remote = _FakeRemote());

  test('API dipanggil sekali, berikutnya dari memori', () async {
    final r = await repo();

    expect((await r.getRadiusSurvey()).getOrElse(() => 0), 25);
    expect((await r.getRadiusSurvey()).getOrElse(() => 0), 25);
    expect(remote.panggil, 1);
  });

  test('cache disk masih baru: API tidak dipanggil', () async {
    final r = await repo({_key: _cache(40, DateTime.now())});

    expect((await r.getRadiusSurvey()).getOrElse(() => 0), 40);
    expect(remote.panggil, 0);
  });

  test('cache kedaluwarsa: ambil ulang dari API', () async {
    final lama = DateTime.now().subtract(const Duration(hours: 25));
    final r = await repo({_key: _cache(40, lama)});

    expect((await r.getRadiusSurvey()).getOrElse(() => 0), 25);
    expect(remote.panggil, 1);
  });

  test('API gagal: pakai cache lama walau kedaluwarsa', () async {
    remote.gagal = true;
    final lama = DateTime.now().subtract(const Duration(days: 3));
    final r = await repo({_key: _cache(40, lama)});

    expect((await r.getRadiusSurvey()).getOrElse(() => 0), 40);
  });

  test('API gagal tanpa cache: Left', () async {
    remote.gagal = true;
    final r = await repo();

    expect((await r.getRadiusSurvey()).isLeft(), isTrue);
  });

  test('push radius: cache diperbarui & stream hanya bila berubah', () async {
    final r = await repo({_key: _cache(20, DateTime.now())});
    expect((await r.getRadiusSurvey()).getOrElse(() => 0), 20);

    final kabar = <int>[];
    final sub = r.radiusBerubah.listen(kabar.add);
    await r.perbaruiRadius(45);
    await r.perbaruiRadius(45);
    await r.perbaruiRadius(0); // tidak valid: diabaikan
    await Future<void>.delayed(Duration.zero);

    expect(kabar, [45]);
    expect((await r.getRadiusSurvey()).getOrElse(() => 0), 45);
    expect(remote.panggil, 0);
    await sub.cancel();
  });

  test('radius dari survey-form memperbarui cache', () async {
    remote.radiusForm = 35;
    final r = await repo();

    final d = (await r.getSurveyDetail(
      key: 'k',
    )).getOrElse(() => throw StateError('gagal'));
    expect(d.jarakMaksMeter, 35);
    expect((await r.getRadiusSurvey()).getOrElse(() => 0), 35);
    expect(remote.panggil, 0);
  });
}
