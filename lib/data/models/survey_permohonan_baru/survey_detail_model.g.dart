// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurveyDetailModel _$SurveyDetailModelFromJson(Map<String, dynamic> json) =>
    SurveyDetailModel(
      key: json['key'] as String,
      noPelayanan: json['noPelayanan'] as String,
      npwpd: json['npwpd'] as String,
      katPenyelenggaraan: json['katPenyelenggaraan'] as String,
      kategoriPenyelenggaraanNama:
          json['kategoriPenyelenggaraanNama'] as String?,
      statusPermohonan: json['statusPermohonan'] as String?,
      header: json['header'] as String?,
      checkin: json['checkin'] as String?,
      sisiList: (json['sisiList'] as List<dynamic>)
          .map((e) => SisiListModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SurveyDetailModelToJson(SurveyDetailModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'noPelayanan': instance.noPelayanan,
      'npwpd': instance.npwpd,
      'katPenyelenggaraan': instance.katPenyelenggaraan,
      'kategoriPenyelenggaraanNama': instance.kategoriPenyelenggaraanNama,
      'statusPermohonan': instance.statusPermohonan,
      'header': instance.header,
      'checkin': instance.checkin,
      'sisiList': instance.sisiList.map((e) => e.toJson()).toList(),
    };

SisiListModel _$SisiListModelFromJson(Map<String, dynamic> json) =>
    SisiListModel(
      seq: (json['seq'] as num).toInt(),
      keySisi: json['keySisi'] as String,
      imageUrl: json['imageUrl'] as String?,
      jenisReklameNama: json['jenisReklameNama'] as String?,
      lokPenyelenggaraanPermohonan:
          json['lokPenyelenggaraanPermohonan'] as String?,
      materiReklamePermohonan: json['materiReklamePermohonan'] as String?,
      masaTayang: json['masaTayang'] as String?,
      nor: json['nor'] as String?,
      survey: json['survey'] == null
          ? null
          : SurveyDataModel.fromJson(json['survey'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SisiListModelToJson(SisiListModel instance) =>
    <String, dynamic>{
      'seq': instance.seq,
      'keySisi': instance.keySisi,
      'imageUrl': instance.imageUrl,
      'jenisReklameNama': instance.jenisReklameNama,
      'lokPenyelenggaraanPermohonan': instance.lokPenyelenggaraanPermohonan,
      'materiReklamePermohonan': instance.materiReklamePermohonan,
      'masaTayang': instance.masaTayang,
      'nor': instance.nor,
      'survey': instance.survey?.toJson(),
    };

SurveyDataModel _$SurveyDataModelFromJson(Map<String, dynamic> json) =>
    SurveyDataModel(
      seq: (json['seq'] as num).toInt(),
      idNor: (json['idNor'] as num?)?.toInt(),
      idPersil: (json['idPersil'] as num?)?.toInt(),
      lokasiTertentuId: (json['lokasiTertentuId'] as num?)?.toInt(),
      letakReklame: json['letakReklame'] as String?,
      statusTanah: json['statusTanah'] as String?,
      lokPenyelenggaraan: json['lokPenyelenggaraan'] as String?,
      panjang: (json['panjang'] as num?)?.toDouble(),
      lebar: (json['lebar'] as num?)?.toDouble(),
      tinggi: (json['tinggi'] as num?)?.toDouble(),
      idJenisReklame: (json['idJenisReklame'] as num?)?.toInt(),
      idJenisProduk: (json['idJenisProduk'] as num?)?.toInt(),
      sudutPandang: json['sudutPandang'] as String?,
      ketSisi: json['ketSisi'] as String?,
      materiReklame: json['materiReklame'] as String?,
      ketSurvey: json['ketSurvey'] as String?,
    );

Map<String, dynamic> _$SurveyDataModelToJson(SurveyDataModel instance) =>
    <String, dynamic>{
      'seq': instance.seq,
      'idNor': instance.idNor,
      'idPersil': instance.idPersil,
      'lokasiTertentuId': instance.lokasiTertentuId,
      'letakReklame': instance.letakReklame,
      'statusTanah': instance.statusTanah,
      'lokPenyelenggaraan': instance.lokPenyelenggaraan,
      'panjang': instance.panjang,
      'lebar': instance.lebar,
      'tinggi': instance.tinggi,
      'idJenisReklame': instance.idJenisReklame,
      'idJenisProduk': instance.idJenisProduk,
      'sudutPandang': instance.sudutPandang,
      'ketSisi': instance.ketSisi,
      'materiReklame': instance.materiReklame,
      'ketSurvey': instance.ketSurvey,
    };
