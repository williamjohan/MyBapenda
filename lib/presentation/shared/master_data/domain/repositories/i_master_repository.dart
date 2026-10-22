import 'package:mybapenda/core/errors/failure.dart';
import 'package:mybapenda/presentation/shared/master_data/domain/entities/master_option_type.dart';
import 'package:mybapenda/presentation/shared/master_data/domain/entities/paged_master_entities.dart';
import 'package:dartz/dartz.dart';

abstract class IMasterRepository {
  Future<Either<Failure, Map<String, String>>> getOptions(
    MasterOptionType type, {
    bool forceRefresh = false,
  });

  Future<Either<Failure, Map<String, String>>> getKelurahan(
    String kecamatanId, {
    bool forceRefresh = false,
  });

  Future<Either<Failure, PagedResultEntity<JalanEntity>>> searchJalan({
    required String keyword,
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, PagedResultEntity<PersilEntity>>> searchPersil({
    required String keyword,
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, PagedResultEntity<PegawaiSurveyEntity>>>
  searchPegawaiSurvey({
    required String keyword,
    required int page,
    required int pageSize,
  });

  Future<void> clearCache();
}
