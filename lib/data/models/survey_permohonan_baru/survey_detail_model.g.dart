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
      isDraft: json['isDraft'] as bool? ?? false,
      jarakMaksMeter: _intOrNull(json['jarakMaksMeter']),
      header: _headerFrom(json['header']),
      checkin: _checkinFrom(json['checkin']),
      sisiList: (json['sisiList'] as List<dynamic>?)
              ?.map((e) => SisiListModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$SurveyDetailModelToJson(SurveyDetailModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'noPelayanan': instance.noPelayanan,
      'npwpd': instance.npwpd,
      'katPenyelenggaraan': instance.katPenyelenggaraan,
      'kategoriPenyelenggaraanNama': instance.kategoriPenyelenggaraanNama,
      'statusPermohonan': instance.statusPermohonan,
      'isDraft': instance.isDraft,
      'jarakMaksMeter': instance.jarakMaksMeter,
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
      nor: _norFrom(json['nor']),
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
      'survey': instance.survey?.toJson(),
    };

SurveyDataModel _$SurveyDataModelFromJson(Map<String, dynamic> json) =>
    SurveyDataModel(
      seq: (json['seq'] as num).toInt(),
      idNor: _strOrNull(json['idNor']),
      idPersil: _strOrNull(json['idPersil']),
      lokasiTertentuId: _intOrNull(json['lokasiTertentuId']),
      letakReklame: _intOrNull(json['letakReklame']),
      statusTanah: _intOrNull(json['statusTanah']),
      lokPenyelenggaraan: json['lokPenyelenggaraan'] as String?,
      panjang: (json['panjang'] as num?)?.toDouble(),
      lebar: (json['lebar'] as num?)?.toDouble(),
      tinggi: (json['tinggi'] as num?)?.toDouble(),
      idJenisReklame: _intOrNull(json['idJenisReklame']),
      idJenisProduk: _intOrNull(json['idJenisProduk']),
      sudutPandang: _intOrNull(json['sudutPandang']),
      ketSisi: json['ketSisi'] as String?,
      materiReklame: json['materiReklame'] as String?,
      ketSurvey: json['ketSurvey'] as String?,
      latitude: _doubleOrNull(json['latitude']),
      longitude: _doubleOrNull(json['longitude']),
    );

Map<String, dynamic> _$SurveyDataModelToJson(SurveyDataModel instance) =>
    <String, dynamic>{
      'seq': instance.seq,
      'idNor': instance.idNor,
      'idPersil': instance.idPersil,
      'lokasiTertentuId': instance.lokasiTertentuId,
      'letakReklame': instance.letakReklame,
      'statusTanah': instance.statusTanah,
      'idJenisReklame': instance.idJenisReklame,
      'idJenisProduk': instance.idJenisProduk,
      'sudutPandang': instance.sudutPandang,
      'lokPenyelenggaraan': instance.lokPenyelenggaraan,
      'panjang': instance.panjang,
      'lebar': instance.lebar,
      'tinggi': instance.tinggi,
      'ketSisi': instance.ketSisi,
      'materiReklame': instance.materiReklame,
      'ketSurvey': instance.ketSurvey,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

SurveyDetailHeaderModel _$SurveyDetailHeaderModelFromJson(
        Map<String, dynamic> json) =>
    SurveyDetailHeaderModel(
      kecamatan: _cleanOrNull(json['kecamatan']),
      kelurahan: _cleanOrNull(json['kelurahan']),
      blok: _cleanOrNull(json['lokBlok']),
      rt: _cleanOrNull(json['lokRt']),
      rw: _cleanOrNull(json['lokRw']),
    );

SurveyDetailCheckinModel _$SurveyDetailCheckinModelFromJson(
        Map<String, dynamic> json) =>
    SurveyDetailCheckinModel(
      nipPembantu: (json['nipPembantu'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tersimpan: json['tersimpan'] as bool? ?? false,
      latitude: _doubleOrNull(json['latitude']),
      longitude: _doubleOrNull(json['longitude']),
      alamat: _cleanOrNull(json['alamat']),
      fotoUrl: _strOrNull(json['fotoUrl']),
      tglCheckin: _strOrNull(json['tglCheckin']),
    );

SisiNorModel _$SisiNorModelFromJson(Map<String, dynamic> json) => SisiNorModel(
      idNor: _strOrNull(json['idNor']),
      idPersil: _strOrNull(json['idPersil']),
      noAlamat: _cleanOrNull(json['noAlamat']),
    );
