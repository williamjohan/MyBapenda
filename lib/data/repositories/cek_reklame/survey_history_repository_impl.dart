import 'package:mybapenda/core/errors/failure.dart';
import 'package:mybapenda/core/network/safe_api_call.dart';
import 'package:mybapenda/data/datasources/cek_reklame/survey_history_remote_datasource.dart';
import 'package:mybapenda/data/models/survey_permohonan_baru/survey_history_model.dart';
import 'package:mybapenda/domain/entities/cek_reklames/survey_permohonan_baru/survey_history_entity.dart';
import 'package:mybapenda/domain/repositories/survey_permohonan/i_survey_history_remote_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ISurveyHistoryRepository)
class SurveyHistoryRepositoryImpl implements ISurveyHistoryRepository {
  final ISurveyHistoryRemoteDataSource _remote;

  SurveyHistoryRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<SurveyHistoryEntity>>> getHistory({
    DateTime? tglAwal,
    DateTime? tglAkhir,
  }) {
    return executeSafeApiCall<List<SurveyHistoryEntity>>(() async {
      final models = await _remote.getHistory(
        tglAwal: tglAwal,
        tglAkhir: tglAkhir,
      );
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, SurveyHistoryDetailEntity>> getHistoryDetail({
    required String key,
  }) {
    return executeSafeApiCall<SurveyHistoryDetailEntity>(() async {
      final model = await _remote.getHistoryDetail(key: key);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, String>> downloadLaporan({
    required String url,
    required String fileName,
  }) {
    return executeSafeApiCall<String>(
      () => _remote.downloadFile(url: url, fileName: fileName),
    );
  }
}
