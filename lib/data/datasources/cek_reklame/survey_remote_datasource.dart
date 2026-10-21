import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/exception.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/base_api/base_api_response_model.dart';
import '../../models/survey_permohonan_baru/cari_nor_model.dart';
import '../../models/survey_permohonan_baru/simpan_survey_hasil_model.dart';
import '../../models/survey_permohonan_baru/simpan_survey_request_model.dart';
import '../../models/survey_permohonan_baru/survey_permohonan_model.dart';
import '../../models/survey_permohonan_baru/survey_detail_model.dart'; 


abstract class ISurveyPermohonanRemoteDataSource {
  // Get List Header
  Future<List<SurveyPermohonanModel>> getSurveyPermohonanHeader();
  
  //  Get Detail Header - Survey Permohonan Baru
  Future<SurveyDetailModel> getSurveyDetail({required String key});

  // Post Simpan Survey: draft, lalu langsung submit bila isian lengkap
  Future<SimpanSurveyHasilModel> submitSurvey(
    SimpanSurveyRequestModel requestModel,
  );

  // Cari Nor 
  Future<List<CariNorModel>> cariNor({required String nor});

  // Radius maksimal pin reklame dari posisi petugas (meter); null = kosong
  Future<int?> getRadiusSurvey();
}

@LazySingleton(as: ISurveyPermohonanRemoteDataSource)
class SurveyPermohonanRemoteDataSourceImpl
    implements ISurveyPermohonanRemoteDataSource {
  final Dio _dio;

  SurveyPermohonanRemoteDataSourceImpl(this._dio);

  // ===========================================================================
  // 1. GET LIST HEADER
  // ===========================================================================
  @override
  Future<List<SurveyPermohonanModel>> getSurveyPermohonanHeader() async {
    final response = await _dio.get(
      ApiEndpoints.surveyPermohonanHeader,
    );

    final apiResponse = BaseApiResponseModel<List<SurveyPermohonanModel>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((e) => SurveyPermohonanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    if (!apiResponse.isSuccess) {
      throw ServerException(apiResponse.status, apiResponse.errorMessage);
    }

    return apiResponse.data ?? [];
  }

  // ===========================================================================
  // 2. GET DETAIL SURVEY
  // ===========================================================================
  @override
  Future<SurveyDetailModel> getSurveyDetail({required String key}) async {
    final response = await _dio.get(
      ApiEndpoints.surveyPermohonanDetail, 
      queryParameters: {
        'key': key,
      },
    );

    
    final apiResponse = BaseApiResponseModel<SurveyDetailModel>.fromJson(
      response.data,
      (json) => SurveyDetailModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess) {
      throw ServerException(apiResponse.status, apiResponse.errorMessage);
    }


    if (apiResponse.data == null) {
      throw const ServerException(404, 'Detail permohonan survey tidak ditemukan.');
    }

    return apiResponse.data!;
  }

  // ===========================================================================
  // 3. POST SIMPAN SURVEY
  // ===========================================================================
  @override
  Future<SimpanSurveyHasilModel> submitSurvey(
    SimpanSurveyRequestModel requestModel,
  ) async {
    final formData = await requestModel.toFormData();

    final response = await _dio.post(
      ApiEndpoints.surveySimpan, 
      data: formData,
    );

    final apiResponse = BaseApiResponseModel<SimpanSurveyHasilModel>.fromJson(
      response.data,
      (json) => json is Map
          ? SimpanSurveyHasilModel.fromJson(Map<String, dynamic>.from(json))
          : throw const ServerException(
              500,
              'Respons simpan survey tidak dikenali.',
            ),
    );

    if (!apiResponse.isSuccess) {
      throw ServerException(apiResponse.status, apiResponse.errorMessage);
    }

    final data = apiResponse.data;
    if (data == null) {
      throw const ServerException(500, 'Respons simpan survey kosong.');
    }
    return data;
  }

  
  // ===========================================================================
  // 4. GET CARI NOR
  // ===========================================================================
  @override
  Future<List<CariNorModel>> cariNor({required String nor}) async {final response = await _dio.get(
      ApiEndpoints.surveyCariNor,
      queryParameters: {
        'nor': nor,
      },
    );

    final apiResponse = BaseApiResponseModel<List<CariNorModel>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((e) => CariNorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    if (!apiResponse.isSuccess) {
      throw ServerException(apiResponse.status, apiResponse.errorMessage);
    }

    return apiResponse.data ?? [];
  }

  // ===========================================================================
  // 5. GET PENGATURAN RADIUS SURVEY
  // ===========================================================================
  @override
  Future<int?> getRadiusSurvey() async {
    final response = await _dio.get(ApiEndpoints.surveyPengaturanRadius);

    final apiResponse = BaseApiResponseModel<int?>.fromJson(
      response.data,
      (json) {
        final v = json is Map ? json['jarakMaksMeter'] : null;
        if (v is num) return v.toInt();
        return int.tryParse('${v ?? ''}'.trim());
      },
    );

    if (!apiResponse.isSuccess) {
      throw ServerException(apiResponse.status, apiResponse.errorMessage);
    }

    return apiResponse.data;
  }
}