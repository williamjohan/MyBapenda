import 'package:mybapenda/data/models/survey_permohonan_baru/cari_nor_model.dart';
import 'package:mybapenda/data/models/survey_permohonan_baru/simpan_survey_hasil_model.dart';
import 'package:mybapenda/data/models/survey_permohonan_baru/simpan_survey_request_model.dart';
import 'package:mybapenda/domain/entities/cek_reklames/survey_permohonan_baru/simpan_survey_hasil_entity.dart';
import 'package:mybapenda/data/models/survey_permohonan_baru/survey_detail_model.dart';
import 'package:mybapenda/data/models/survey_permohonan_baru/survey_permohonan_model.dart';
import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failure.dart';
import '../../../core/errors/exception.dart';
import '../../../core/storage/survey_radius_storage.dart';
import '../../../../core/network/safe_api_call.dart';
import '../../../domain/entities/cek_reklames/survey_permohonan_baru/cari_nor_entity.dart';
import '../../../domain/entities/cek_reklames/survey_permohonan_baru/detail_survey_entity.dart';
import '../../../domain/entities/cek_reklames/survey_permohonan_baru/simpan_survey_request_entity.dart';
import '../../../domain/entities/cek_reklames/survey_permohonan_baru/survey_permohonan_entity.dart';
import '../../../domain/repositories/survey_permohonan/i_survey_permohonan_repository.dart';
import '../../datasources/cek_reklame/survey_remote_datasource.dart';

@LazySingleton(as: ISurveyPermohonanRepository)
class SurveyPermohonanRepositoryImpl implements ISurveyPermohonanRepository {
  static const Duration _ttlRadius = Duration(hours: 24);

  final ISurveyPermohonanRemoteDataSource _remoteDataSource;
  final SurveyRadiusStorage _radiusStorage;

  SurveyPermohonanRepositoryImpl(this._remoteDataSource, this._radiusStorage);

  // Cache memori radius (sesi app); disk lewat [SurveyRadiusStorage].
  int? _radius;
  Future<Either<Failure, int>>? _radiusInFlight;
  final _radiusBerubah = StreamController<int>.broadcast();

  // ===========================================================================
  // 1. GET LIST HEADER (Map List<Model> -> List<Entity>)
  // ===========================================================================
  @override
  Future<Either<Failure, List<SurveyPermohonanEntity>>>
  getSurveyPermohonanHeader() {
    return executeSafeApiCall<List<SurveyPermohonanEntity>>(() async {
      final models = await _remoteDataSource.getSurveyPermohonanHeader();
      return models.map((model) => model.toEntity()).toList();
    });
  }

  // ===========================================================================
  // 2. GET DETAIL SURVEY (Map Model -> Entity)
  // ===========================================================================
  @override
  Future<Either<Failure, SurveyDetailEntity>> getSurveyDetail({
    required String key,
  }) {
    return executeSafeApiCall<SurveyDetailEntity>(() async {
      final model = await _remoteDataSource.getSurveyDetail(key: key);
      // Radius dari survey-form = nilai terbaru, ikut memperbarui cache.
      final radius = model.jarakMaksMeter;
      if (radius != null && radius > 0) await _simpanRadius(radius);
      return model.toEntity();
    });
  }

  // ===========================================================================
  // 3. POST SIMPAN SURVEY (Map Entity -> Model)
  // ===========================================================================
  @override
  Future<Either<Failure, SimpanSurveyHasilEntity>> submitSurvey(
    SimpanSurveyRequestEntity payload,
  ) {
    return executeSafeApiCall<SimpanSurveyHasilEntity>(() async {
      final model = await _remoteDataSource.submitSurvey(payload.toModel());
      return model.toEntity();
    });
  }

  // ===========================================================================
  // 4. CARI NOR
  // ===========================================================================
  @override
  Future<Either<Failure, List<CariNorEntity>>> cariNor({required String nor}) {
    return executeSafeApiCall<List<CariNorEntity>>(() async {
      final models = await _remoteDataSource.cariNor(nor: nor);
      return models.map((model) => model.toEntity()).toList();
    });
  }

  // ===========================================================================
  // 5. GET SUMMARY
  // ===========================================================================
  @override
  Future<Either<Failure, SurveySummaryEntity>> getSurveySummary() {
    return executeSafeApiCall<SurveySummaryEntity>(() async {
      final model = await _remoteDataSource.getSurveySummary();
      return model.toEntity();
    });
  }

  // 6. PENGATURAN RADIUS SURVEY (cache memori + disk, TTL)
  // ===========================================================================
  @override
  Future<Either<Failure, int>> getRadiusSurvey({bool forceRefresh = false}) {
    final memori = _radius;
    if (!forceRefresh && memori != null) return Future.value(Right(memori));

    return _radiusInFlight ??= _muatRadius(forceRefresh).whenComplete(() {
      _radiusInFlight = null;
    });
  }

  Future<Either<Failure, int>> _muatRadius(bool force) {
    return executeSafeApiCall<int>(() async {
      final cached = _radiusStorage.baca();
      final baru =
          cached != null && DateTime.now().difference(cached.tgl) < _ttlRadius;
      if (!force && baru) return _radius = cached.meter;

      try {
        final meter = await _remoteDataSource.getRadiusSurvey();
        if (meter != null && meter > 0) {
          await _simpanRadius(meter);
          return meter;
        }
        if (cached != null) return _radius = cached.meter;
        throw const ServerException(
          404,
          'Pengaturan radius survey belum tersedia.',
        );
      } catch (_) {
        // API gagal: pakai salinan lama walau sudah kedaluwarsa.
        if (cached != null) return _radius = cached.meter;
        rethrow;
      }
    });
  }

  @override
  Stream<int> get radiusBerubah => _radiusBerubah.stream;

  @override
  Future<void> perbaruiRadius(int meter) async {
    if (meter > 0) await _simpanRadius(meter);
  }

  Future<void> _simpanRadius(int meter) async {
    final berubah = _radius != meter;
    _radius = meter;
    if (berubah) _radiusBerubah.add(meter);
    await _radiusStorage.simpan(meter);
  }
}
