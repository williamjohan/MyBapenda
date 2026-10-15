// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'berkas_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FotoJejakModel _$FotoJejakModelFromJson(Map<String, dynamic> json) =>
    FotoJejakModel(
      key: json['key'] as String,
      jenisFoto: jsonAsString(json['jenisFoto']),
    );

Map<String, dynamic> _$FotoJejakModelToJson(FotoJejakModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'jenisFoto': instance.jenisFoto,
    };

JejakModel _$JejakModelFromJson(Map<String, dynamic> json) => JejakModel(
      statusId: (json['statusId'] as num?)?.toInt(),
      status: json['status'] as String?,
      sumber: jsonAsString(json['sumber']),
      nip: json['nip'] as String?,
      namaPetugas: json['namaPetugas'] as String?,
      tglCheckin: json['tglCheckin'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      akurasi: (json['akurasi'] as num?)?.toDouble(),
      jarakKeTujuan: (json['jarakKeTujuan'] as num?)?.toDouble(),
      keterangan: json['keterangan'] as String?,
      diabaikan:
          json['diabaikan'] == null ? false : jsonAsBool(json['diabaikan']),
      perluReview:
          json['perluReview'] == null ? false : jsonAsBool(json['perluReview']),
      jumlahFoto: (json['jumlahFoto'] as num?)?.toInt() ?? 0,
      foto: (json['foto'] as List<dynamic>?)
              ?.map((e) => FotoJejakModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      flagAkurasi:
          json['flagAkurasi'] == null ? false : jsonAsBool(json['flagAkurasi']),
      flagWaktu:
          json['flagWaktu'] == null ? false : jsonAsBool(json['flagWaktu']),
      percobaanKe: (json['percobaanKe'] as num?)?.toInt(),
    );

Map<String, dynamic> _$JejakModelToJson(JejakModel instance) =>
    <String, dynamic>{
      'statusId': instance.statusId,
      'status': instance.status,
      'sumber': instance.sumber,
      'nip': instance.nip,
      'namaPetugas': instance.namaPetugas,
      'tglCheckin': instance.tglCheckin,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'akurasi': instance.akurasi,
      'jarakKeTujuan': instance.jarakKeTujuan,
      'keterangan': instance.keterangan,
      'diabaikan': instance.diabaikan,
      'perluReview': instance.perluReview,
      'jumlahFoto': instance.jumlahFoto,
      'foto': instance.foto,
      'flagAkurasi': instance.flagAkurasi,
      'flagWaktu': instance.flagWaktu,
      'percobaanKe': instance.percobaanKe,
    };

BerkasModel _$BerkasModelFromJson(Map<String, dynamic> json) => BerkasModel(
      noResi: json['noResi'] as String,
      jenisKode: json['jenisKode'] as String?,
      jenisNama: json['jenisNama'] as String?,
      noSurat: json['noSurat'] as String?,
      tglSurat: json['tglSurat'] as String?,
      noReferensi: json['noReferensi'] as String?,
      npwpd: json['npwpd'] as String?,
      namaWp: json['namaWp'] as String? ?? '-',
      statusId: (json['statusId'] as num?)?.toInt(),
      status: json['status'] as String?,
      modeTempel:
          json['modeTempel'] == null ? false : jsonAsBool(json['modeTempel']),
      percobaanKe: (json['percobaanKe'] as num?)?.toInt() ?? 0,
      jumlahGagal: (json['jumlahGagal'] as num?)?.toInt() ?? 0,
      jenisTujuan: jsonAsString(json['jenisTujuan']),
      alamatTujuan: json['alamatTujuan'] as String? ?? '-',
      latTujuan: (json['latTujuan'] as num?)?.toDouble(),
      longTujuan: (json['longTujuan'] as num?)?.toDouble(),
      penanggungJawab: json['penanggungJawab'] == null
          ? false
          : jsonAsBool(json['penanggungJawab']),
      tglDitugaskan: json['tglDitugaskan'] as String?,
      tglBatasSla: json['tglBatasSla'] as String?,
      terlambat:
          json['terlambat'] == null ? false : jsonAsBool(json['terlambat']),
      perluDikembalikan: json['perluDikembalikan'] == null
          ? false
          : jsonAsBool(json['perluDikembalikan']),
      wajibFotoObjek: json['wajibFotoObjek'] == null
          ? false
          : jsonAsBool(json['wajibFotoObjek']),
      aksi:
          (json['aksi'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
    );

Map<String, dynamic> _$BerkasModelToJson(BerkasModel instance) =>
    <String, dynamic>{
      'noResi': instance.noResi,
      'jenisKode': instance.jenisKode,
      'jenisNama': instance.jenisNama,
      'noSurat': instance.noSurat,
      'tglSurat': instance.tglSurat,
      'noReferensi': instance.noReferensi,
      'npwpd': instance.npwpd,
      'namaWp': instance.namaWp,
      'statusId': instance.statusId,
      'status': instance.status,
      'modeTempel': instance.modeTempel,
      'percobaanKe': instance.percobaanKe,
      'jumlahGagal': instance.jumlahGagal,
      'jenisTujuan': instance.jenisTujuan,
      'alamatTujuan': instance.alamatTujuan,
      'latTujuan': instance.latTujuan,
      'longTujuan': instance.longTujuan,
      'penanggungJawab': instance.penanggungJawab,
      'tglDitugaskan': instance.tglDitugaskan,
      'tglBatasSla': instance.tglBatasSla,
      'terlambat': instance.terlambat,
      'perluDikembalikan': instance.perluDikembalikan,
      'wajibFotoObjek': instance.wajibFotoObjek,
      'aksi': instance.aksi,
    };

BerkasDetailModel _$BerkasDetailModelFromJson(Map<String, dynamic> json) =>
    BerkasDetailModel(
      berkas: BerkasModel.fromJson(
          jsonSelf(json, 'berkas') as Map<String, dynamic>),
      alamatWp: json['alamatWp'] as String?,
      caraSerah: jsonAsString(json['caraSerah']),
      tglTerima: json['tglTerima'] as String?,
      namaPenerima: json['namaPenerima'] as String?,
      jejak: (json['jejak'] as List<dynamic>?)
              ?.map((e) => JejakModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$BerkasDetailModelToJson(BerkasDetailModel instance) =>
    <String, dynamic>{
      'alamatWp': instance.alamatWp,
      'caraSerah': instance.caraSerah,
      'tglTerima': instance.tglTerima,
      'namaPenerima': instance.namaPenerima,
      'jejak': instance.jejak,
    };
