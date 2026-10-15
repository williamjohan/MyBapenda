import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/presentation/shared/master_data/domain/entities/master_option_type.dart';
import 'package:bapendacore/presentation/shared/master_data/domain/entities/paged_master_entities.dart';
import 'package:bapendacore/presentation/shared/master_data/domain/repositories/i_master_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class MasterDataUseCase {
  final IMasterRepository _repository;

  MasterDataUseCase(this._repository);

  Future<Either<Failure, Map<String, String>>> getOptions(
    MasterOptionType type, {
    bool forceRefresh = false,
  }) => _repository.getOptions(type, forceRefresh: forceRefresh);

  Future<Either<Failure, Map<String, String>>> getKelurahan(
    String kecamatanId, {
    bool forceRefresh = false,
  }) => _repository.getKelurahan(kecamatanId, forceRefresh: forceRefresh);

  Future<Either<Failure, PagedResultEntity<JalanEntity>>> searchJalan({
    required String keyword,
    required int page,
    required int pageSize,
  }) =>
      _repository.searchJalan(keyword: keyword, page: page, pageSize: pageSize);

  Future<Either<Failure, PagedResultEntity<PersilEntity>>> searchPersil({
    required String keyword,
    required int page,
    required int pageSize,
  }) => _repository.searchPersil(
    keyword: keyword,
    page: page,
    pageSize: pageSize,
  );

  Future<Either<Failure, PagedResultEntity<PegawaiSurveyEntity>>>
  searchPegawaiSurvey({
    required String keyword,
    required int page,
    required int pageSize,
  }) => _repository.searchPegawaiSurvey(
    keyword: keyword,
    page: page,
    pageSize: pageSize,
  );

  Future<void> clearCache() => _repository.clearCache();
}
