import 'package:mybapenda/core/errors/failure.dart';
import 'package:mybapenda/domain/entities/cek_reklames/survey_permohonan_baru/survey_history_entity.dart';
import 'package:mybapenda/domain/repositories/survey_permohonan/i_survey_history_remote_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SurveyHistoryUseCase {
  final ISurveyHistoryRepository _repository;

  SurveyHistoryUseCase(this._repository);

  // 1. LIST HISTORY (filter tanggal opsional)
  Future<Either<Failure, List<SurveyHistoryEntity>>> getHistory({
    DateTime? tglAwal,
    DateTime? tglAkhir,
  }) {
    return _repository.getHistory(tglAwal: tglAwal, tglAkhir: tglAkhir);
  }

  // 2. DETAIL HISTORY
  Future<Either<Failure, SurveyHistoryDetailEntity>> getHistoryDetail({
    required String key,
  }) {
    return _repository.getHistoryDetail(key: key);
  }

  // 3. UNDUH LAPORAN PDF
  Future<Either<Failure, String>> downloadLaporan({
    required String url,
    required String fileName,
  }) {
    return _repository.downloadLaporan(url: url, fileName: fileName);
  }
}
