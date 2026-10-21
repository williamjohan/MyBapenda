import 'package:mybapenda/core/errors/failure.dart';
import 'package:mybapenda/domain/entities/cek_reklames/survey_permohonan_baru/survey_history_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ISurveyHistoryRepository {
  Future<Either<Failure, List<SurveyHistoryEntity>>> getHistory({
    DateTime? tglAwal,
    DateTime? tglAkhir,
  });

  Future<Either<Failure, SurveyHistoryDetailEntity>> getHistoryDetail({
    required String key,
  });

  Future<Either<Failure, String>> downloadLaporan({
    required String url,
    required String fileName,
  });
}
