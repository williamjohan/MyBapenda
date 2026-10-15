// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lacak_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonitoringRowModel _$MonitoringRowModelFromJson(Map<String, dynamic> json) =>
    MonitoringRowModel(
      noResi: json['noResi'] as String,
      jenisKode: json['jenisKode'] as String?,
      jenisNama: json['jenisNama'] as String?,
      noSurat: json['noSurat'] as String?,
      tglSurat: json['tglSurat'] as String?,
      noReferensi: json['noReferensi'] as String?,
      npwpd: json['npwpd'] as String?,
      namaWp: json['namaWp'] as String? ?? '-',
      uptb: jsonAsString(json['uptb']),
      statusId: (json['statusId'] as num?)?.toInt(),
      status: json['status'] as String?,
      nipPetugas: json['nipPetugas'] as String?,
      namaPetugas: json['namaPetugas'] as String?,
      jumlahGagal: (json['jumlahGagal'] as num?)?.toInt() ?? 0,
      modeTempel:
          json['modeTempel'] == null ? false : jsonAsBool(json['modeTempel']),
      tglBatasSla: json['tglBatasSla'] as String?,
      tglTerima: json['tglTerima'] as String?,
      caraSerah: jsonAsString(json['caraSerah']),
      terlambat:
          json['terlambat'] == null ? false : jsonAsBool(json['terlambat']),
      perluReview:
          json['perluReview'] == null ? false : jsonAsBool(json['perluReview']),
      fisikBelumKembali: json['fisikBelumKembali'] == null
          ? false
          : jsonAsBool(json['fisikBelumKembali']),
      tindakan: jsonAsString(json['tindakan']),
      tglUpdate: json['tglUpdate'] as String?,
    );

Map<String, dynamic> _$MonitoringRowModelToJson(MonitoringRowModel instance) =>
    <String, dynamic>{
      'noResi': instance.noResi,
      'jenisKode': instance.jenisKode,
      'jenisNama': instance.jenisNama,
      'noSurat': instance.noSurat,
      'tglSurat': instance.tglSurat,
      'noReferensi': instance.noReferensi,
      'npwpd': instance.npwpd,
      'namaWp': instance.namaWp,
      'uptb': instance.uptb,
      'statusId': instance.statusId,
      'status': instance.status,
      'nipPetugas': instance.nipPetugas,
      'namaPetugas': instance.namaPetugas,
      'jumlahGagal': instance.jumlahGagal,
      'modeTempel': instance.modeTempel,
      'tglBatasSla': instance.tglBatasSla,
      'tglTerima': instance.tglTerima,
      'caraSerah': instance.caraSerah,
      'terlambat': instance.terlambat,
      'perluReview': instance.perluReview,
      'fisikBelumKembali': instance.fisikBelumKembali,
      'tindakan': instance.tindakan,
      'tglUpdate': instance.tglUpdate,
    };

MonitoringBerkasModel _$MonitoringBerkasModelFromJson(
        Map<String, dynamic> json) =>
    MonitoringBerkasModel(
      berkas:
          MonitoringRowModel.fromJson(json['berkas'] as Map<String, dynamic>),
      alamatWp: json['alamatWp'] as String?,
      tglDitugaskan: json['tglDitugaskan'] as String?,
      tglJatuhTempo: json['tglJatuhTempo'] as String?,
      noResiPos: json['noResiPos'] as String?,
      tglKirimPos: json['tglKirimPos'] as String?,
      maksPercobaan: (json['maksPercobaan'] as num?)?.toInt(),
      jejak: (json['jejak'] as List<dynamic>?)
              ?.map((e) => JejakModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$MonitoringBerkasModelToJson(
        MonitoringBerkasModel instance) =>
    <String, dynamic>{
      'berkas': instance.berkas,
      'alamatWp': instance.alamatWp,
      'tglDitugaskan': instance.tglDitugaskan,
      'tglJatuhTempo': instance.tglJatuhTempo,
      'noResiPos': instance.noResiPos,
      'tglKirimPos': instance.tglKirimPos,
      'maksPercobaan': instance.maksPercobaan,
      'jejak': instance.jejak,
    };

LacakResultModel _$LacakResultModelFromJson(Map<String, dynamic> json) =>
    LacakResultModel(
      noResi: json['noResi'] as String,
      aksesMonitoring: json['aksesMonitoring'] == null
          ? false
          : jsonAsBool(json['aksesMonitoring']),
      tugasSaya:
          json['tugasSaya'] == null ? false : jsonAsBool(json['tugasSaya']),
      monitoring: json['monitoring'] == null
          ? null
          : MonitoringBerkasModel.fromJson(
              json['monitoring'] as Map<String, dynamic>),
      tugas: json['tugas'] == null
          ? null
          : BerkasDetailModel.fromJson(json['tugas'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LacakResultModelToJson(LacakResultModel instance) =>
    <String, dynamic>{
      'noResi': instance.noResi,
      'aksesMonitoring': instance.aksesMonitoring,
      'tugasSaya': instance.tugasSaya,
      'monitoring': instance.monitoring,
      'tugas': instance.tugas,
    };
