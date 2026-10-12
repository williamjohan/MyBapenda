import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../domain/entities/cek_reklames/survey_permohonan_baru/simpan_survey_request_entity.dart';

/// MODEL REQUEST KHUSUS MULTIPART
class SimpanSurveyRequestModel {
  final SimpanSurveyRequestEntity entity;

  const SimpanSurveyRequestModel(this.entity);

  ///   Mengubah seluruh Entity kompleks menjadi FormData
  Future<FormData> toFormData() async {
    final Map<String, dynamic> formMap = {
      'Key': entity.key,
      'TglSurvey': entity.tglSurvey,
      'Tim': entity.tim,
      'Kecamatan': entity.kecamatan,
      'Kelurahan': entity.kelurahan,
      'NoImb': entity.noImb,
      'LokNo': entity.lokNo,
      'LokBlok': entity.lokBlok,
      'LokRt': entity.lokRt,
      'LokRw': entity.lokRw,
      'Latitude': entity.latitude,
      'Longitude': entity.longitude,
      
      // Data Checkin (Teks)
      'Checkin.Latitude': entity.checkin.latitude,
      'Checkin.Longitude': entity.checkin.longitude,
      'Checkin.Alamat': entity.checkin.alamat,
    };

    // 1.  File Checkin: Convert File ke MultipartFile
    formMap['Checkin.FileDataFormFile'] = await MultipartFile.fromFile(
      entity.checkin.fileDataFormFile.path,
      filename: 'checkin_foto.jpg',
    );

    // 2.  Array Handling: Format ASP.NET (Checkin.NipPembantu[0], [1], dst)
    for (int i = 0; i < entity.checkin.nipPembantu.length; i++) {
      formMap['Checkin.NipPembantu[$i]'] = entity.checkin.nipPembantu[i];
    }

    // 3.  SisiList Handling: Berdasarkan cURL, BE mengharapkan JSON String
    final sisiListMap = {
      'seq': entity.sisiList.seq,
      'idNor': entity.sisiList.idNor,
      'lokPenyelenggaraan': entity.sisiList.lokPenyelenggaraan,
      // ... mapping field sisiList lainnya
    };
    formMap['SisiList'] = jsonEncode(sisiListMap);

    return FormData.fromMap(formMap);
  }
}

// ====================================================================
// EXTENSION (MAPPER DARI ENTITY KE MODEL)
// ====================================================================
extension SimpanSurveyRequestEntityX on SimpanSurveyRequestEntity {
  SimpanSurveyRequestModel toModel() => SimpanSurveyRequestModel(this);
}