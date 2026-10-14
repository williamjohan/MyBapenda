import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../entities/cek_reklames/survey_permohonan_baru/cari_nor_entity.dart';
import '../../entities/cek_reklames/survey_permohonan_baru/detail_survey_entity.dart';
import '../../entities/cek_reklames/survey_permohonan_baru/simpan_survey_request_entity.dart';
import '../../entities/cek_reklames/survey_permohonan_baru/survey_permohonan_entity.dart';


abstract class ISurveyPermohonanRepository {
  /// Mendapatkan daftar header survey permohonan baru
  Future<Either<Failure, List<SurveyPermohonanEntity>>> getSurveyPermohonanHeader();

  /// Mendapatkan detail spesifik dari sebuah permohonan survey
  Future<Either<Failure, SurveyDetailEntity>> getSurveyDetail({required String key});

  /// Mengirim (submit) data laporan survey ke server
  Future<Either<Failure, bool>> submitSurvey(SimpanSurveyRequestEntity payload);

  /// Mencari nomor registrasi (NOR) dalam sistem
  Future<Either<Failure, List<CariNorEntity>>> cariNor({required String nor});  
}