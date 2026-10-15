import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../domain/entities/cek_reklames/survey_permohonan_baru/simpan_survey_request_entity.dart';

class SimpanSurveyRequestModel {
  final SimpanSurveyRequestEntity entity;

  const SimpanSurveyRequestModel(this.entity);


  // TODO: konfirmasi cara BE menerima file foto sisi (lihat catatan).
  static String _fotoKey(int sisiIndex, int fotoIndex) =>
      'SisiList[$sisiIndex].Fotos[$fotoIndex].FileDataFormFile';

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'Key': entity.key,
      'TglSurvey': entity.tglSurvey,
      'Kecamatan': entity.kecamatan,
      'Kelurahan': entity.kelurahan,
      'LokBlok': entity.lokBlok,
      'LokRt': entity.lokRt,
      'LokRw': entity.lokRw,
      'Latitude': entity.latitude,
      'Longitude': entity.longitude,
      'SisiList': jsonEncode(entity.sisiList.map(_sisiJson).toList()),
      'Checkin.Latitude': entity.checkin.latitude,
      'Checkin.Longitude': entity.checkin.longitude,
      'Checkin.Alamat': entity.checkin.alamat,
      'Checkin.FileDataFormFile': await MultipartFile.fromFile(
        entity.checkin.fileDataFormFile.path,
        filename: 'checkin_foto.jpg',
      ),
    };

    // Format array ASP.NET: Checkin.NipPembantu[0], [1], ...
    for (var i = 0; i < entity.checkin.nipPembantu.length; i++) {
      map['Checkin.NipPembantu[$i]'] = entity.checkin.nipPembantu[i];
    }

    // File foto per sisi.
    for (var i = 0; i < entity.sisiList.length; i++) {
      final fotos = entity.sisiList[i].fotos;
      for (var j = 0; j < fotos.length; j++) {
        map[_fotoKey(i, j)] = await MultipartFile.fromFile(
          fotos[j].file.path,
          filename: 'sisi_${entity.sisiList[i].seq}_foto_${j + 1}.jpg',
        );
      }
    }

    return FormData.fromMap(map);
  }

  Map<String, dynamic> _sisiJson(SisiRequestEntity s) {
    final nb = s.norBaru;
    return {
      'seq': s.seq,
      'idNor': s.idNor,
      'idPersil': s.idPersil,
      'lokasiTertentuId': s.lokasiTertentuId,
      'letakReklame': s.letakReklame,
      'statusTanah': s.statusTanah,
      'lokPenyelenggaraan': s.lokPenyelenggaraan,
      'panjang': s.panjang,
      'lebar': s.lebar,
      'tinggi': s.tinggi,
      'idJenisReklame': s.idJenisReklame,
      'idJenisProduk': s.idJenisProduk,
      'sudutPandang': s.sudutPandang,
      'ketSisi': s.ketSisi,
      'materiReklame': s.materiReklame,
      'ketSurvey': s.ketSurvey,
      'norBaru': nb == null
          ? null
          : {
              'idPersil': nb.idPersil,
              'jenisBangunanId': nb.jenisBangunanId,
              'jalanId': nb.jalanId,
              'noAlamat': nb.noAlamat,
            },
      // File dikirim sebagai part terpisah; di JSON hanya keterangan.
      'fotos': [
        for (final f in s.fotos) {'keterangan': f.keterangan},
      ],
    }..removeWhere((_, v) => v == null);
  }
}

extension SimpanSurveyRequestEntityX on SimpanSurveyRequestEntity {
  SimpanSurveyRequestModel toModel() => SimpanSurveyRequestModel(this);
}
