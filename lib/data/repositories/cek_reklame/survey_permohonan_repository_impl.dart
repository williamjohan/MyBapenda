import 'package:bapendacore/data/models/survey_permohonan_baru/cari_nor_model.dart';
import 'package:bapendacore/data/models/survey_permohonan_baru/simpan_survey_request_model.dart';
import 'package:bapendacore/data/models/survey_permohonan_baru/survey_detail_model.dart';
import 'package:bapendacore/data/models/survey_permohonan_baru/survey_permohonan_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/safe_api_call.dart';
import '../../../domain/entities/cek_reklames/survey_permohonan_baru/cari_nor_entity.dart';
import '../../../domain/entities/cek_reklames/survey_permohonan_baru/detail_survey_entity.dart';
import '../../../domain/entities/cek_reklames/survey_permohonan_baru/simpan_survey_request_entity.dart';
import '../../../domain/entities/cek_reklames/survey_permohonan_baru/survey_permohonan_entity.dart';
import '../../../domain/repositories/survey_permohonan/i_survey_permohonan_repository.dart';
import '../../datasources/cek_reklame/survey_remote_datasource.dart';


@LazySingleton(as: ISurveyPermohonanRepository)
class SurveyPermohonanRepositoryImpl implements ISurveyPermohonanRepository {
  final ISurveyPermohonanRemoteDataSource _remoteDataSource;

  SurveyPermohonanRepositoryImpl(this._remoteDataSource);

  // ===========================================================================
  // 1. GET LIST HEADER (Map List<Model> -> List<Entity>)
  // ===========================================================================
  @override
  Future<Either<Failure, List<SurveyPermohonanEntity>>> getSurveyPermohonanHeader() {
    return executeSafeApiCall<List<SurveyPermohonanEntity>>(() async {
      final models = await _remoteDataSource.getSurveyPermohonanHeader();
      return models.map((model) => model.toEntity()).toList();
    });
  }

  // ===========================================================================
  // 2. GET DETAIL SURVEY (Map Model -> Entity)
  // ===========================================================================
  @override
  Future<Either<Failure, SurveyDetailEntity>> getSurveyDetail({required String key}) {
    return executeSafeApiCall<SurveyDetailEntity>(() async {
      final model = await _remoteDataSource.getSurveyDetail(key: key);
      return model.toEntity();
    });
  }

  // ===========================================================================
  // 3. POST SIMPAN SURVEY (Map Entity -> Model)
  // ===========================================================================
  @override
  Future<Either<Failure, bool>> submitSurvey(SimpanSurveyRequestEntity payload) {
    return executeSafeApiCall<bool>(() async {
      final requestModel = payload.toModel();
      return await _remoteDataSource.submitSurvey(requestModel);
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
}