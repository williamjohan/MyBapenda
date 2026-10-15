import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/pengiriman/berkas_entity.dart';
import '../../../domain/entities/pengiriman/lacak_entity.dart';
import 'berkas_model.dart';
import 'pengiriman_json_util.dart';

part 'lacak_model.g.dart';

/// `MonitoringRow` (dipakai di `lacak` dan daftar monitoring).
@JsonSerializable()
class MonitoringRowModel {
  @JsonKey(name: 'noResi')
  final String noResi;
  @JsonKey(name: 'jenisKode')
  final String? jenisKode;
  @JsonKey(name: 'jenisNama')
  final String? jenisNama;
  @JsonKey(name: 'noSurat')
  final String? noSurat;
  @JsonKey(name: 'tglSurat')
  final String? tglSurat;
  @JsonKey(name: 'noReferensi')
  final String? noReferensi;
  @JsonKey(name: 'npwpd')
  final String? npwpd;
  @JsonKey(name: 'namaWp', defaultValue: '-')
  final String namaWp;
  @JsonKey(name: 'uptb', fromJson: jsonAsString)
  final String? uptb;
  @JsonKey(name: 'statusId')
  final int? statusId;
  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'nipPetugas')
  final String? nipPetugas;
  @JsonKey(name: 'namaPetugas')
  final String? namaPetugas;
  @JsonKey(name: 'jumlahGagal', defaultValue: 0)
  final int jumlahGagal;
  @JsonKey(name: 'modeTempel', fromJson: jsonAsBool)
  final bool modeTempel;
  @JsonKey(name: 'tglBatasSla')
  final String? tglBatasSla;
  @JsonKey(name: 'tglTerima')
  final String? tglTerima;
  @JsonKey(name: 'caraSerah', fromJson: jsonAsString)
  final String? caraSerah;
  @JsonKey(name: 'terlambat', fromJson: jsonAsBool)
  final bool terlambat;
  @JsonKey(name: 'perluReview', fromJson: jsonAsBool)
  final bool perluReview;
  @JsonKey(name: 'fisikBelumKembali', fromJson: jsonAsBool)
  final bool fisikBelumKembali;
  @JsonKey(name: 'tindakan', fromJson: jsonAsString)
  final String? tindakan;
  @JsonKey(name: 'tglUpdate')
  final String? tglUpdate;

  const MonitoringRowModel({
    required this.noResi,
    this.jenisKode,
    this.jenisNama,
    this.noSurat,
    this.tglSurat,
    this.noReferensi,
    this.npwpd,
    required this.namaWp,
    this.uptb,
    this.statusId,
    this.status,
    this.nipPetugas,
    this.namaPetugas,
    required this.jumlahGagal,
    this.modeTempel = false,
    this.tglBatasSla,
    this.tglTerima,
    this.caraSerah,
    this.terlambat = false,
    this.perluReview = false,
    this.fisikBelumKembali = false,
    this.tindakan,
    this.tglUpdate,
  });

  factory MonitoringRowModel.fromJson(Map<String, dynamic> json) =>
      _$MonitoringRowModelFromJson(json);

  Map<String, dynamic> toJson() => _$MonitoringRowModelToJson(this);
}

/// Bagian `monitoring` dari `lacak`. `percobaan[]`, `tujuanOpsi[]`, dan
/// flag `bisa*` tidak dipetakan karena keputusan supervisor tetap di Web.
@JsonSerializable()
class MonitoringBerkasModel {
  @JsonKey(name: 'berkas')
  final MonitoringRowModel berkas;
  @JsonKey(name: 'alamatWp')
  final String? alamatWp;
  @JsonKey(name: 'tglDitugaskan')
  final String? tglDitugaskan;
  @JsonKey(name: 'tglJatuhTempo')
  final String? tglJatuhTempo;
  @JsonKey(name: 'noResiPos')
  final String? noResiPos;
  @JsonKey(name: 'tglKirimPos')
  final String? tglKirimPos;
  @JsonKey(name: 'maksPercobaan')
  final int? maksPercobaan;
  @JsonKey(name: 'jejak', defaultValue: <JejakModel>[])
  final List<JejakModel> jejak;

  const MonitoringBerkasModel({
    required this.berkas,
    this.alamatWp,
    this.tglDitugaskan,
    this.tglJatuhTempo,
    this.noResiPos,
    this.tglKirimPos,
    this.maksPercobaan,
    required this.jejak,
  });

  factory MonitoringBerkasModel.fromJson(Map<String, dynamic> json) =>
      _$MonitoringBerkasModelFromJson(json);

  Map<String, dynamic> toJson() => _$MonitoringBerkasModelToJson(this);
}

@JsonSerializable()
class LacakResultModel {
  @JsonKey(name: 'noResi')
  final String noResi;
  @JsonKey(name: 'aksesMonitoring', fromJson: jsonAsBool)
  final bool aksesMonitoring;
  @JsonKey(name: 'tugasSaya', fromJson: jsonAsBool)
  final bool tugasSaya;
  @JsonKey(name: 'monitoring')
  final MonitoringBerkasModel? monitoring;
  @JsonKey(name: 'tugas')
  final BerkasDetailModel? tugas;

  const LacakResultModel({
    required this.noResi,
    this.aksesMonitoring = false,
    this.tugasSaya = false,
    this.monitoring,
    this.tugas,
  });

  factory LacakResultModel.fromJson(Map<String, dynamic> json) =>
      _$LacakResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$LacakResultModelToJson(this);
}

extension MonitoringRowModelX on MonitoringRowModel {
  /// Field detail (alamat, jejak, dst.) hanya terisi dari `lacak`.
  MonitoringBerkasEntity toEntity({
    String? alamatWp,
    int? maksPercobaan,
    String? tglDitugaskan,
    String? tglJatuhTempo,
    String? noResiPos,
    String? tglKirimPos,
    List<JejakModel> jejak = const [],
  }) {
    final r = this;
    final s = StatusBerkas.fromId(r.statusId);
    final j = JenisSurat.fromKode(r.jenisKode);
    return MonitoringBerkasEntity(
      noResi: r.noResi,
      jenis: j,
      jenisNama: namaJenisSurat(j.label, j != JenisSurat.lainnya, r.jenisNama),
      noSurat: r.noSurat,
      tglSurat: parseTgl(r.tglSurat),
      noReferensi: r.noReferensi,
      npwpd: r.npwpd,
      namaWp: r.namaWp,
      alamatWp: alamatWp,
      uptb: r.uptb,
      status: s,
      statusNama: (r.status?.trim().isNotEmpty ?? false) ? r.status! : s.label,
      nipPetugas: r.nipPetugas,
      namaPetugas: r.namaPetugas,
      jumlahGagal: r.jumlahGagal,
      maksPercobaan: maksPercobaan,
      modeTempel: r.modeTempel,
      tglDitugaskan: parseTgl(tglDitugaskan),
      tglBatasSla: parseTgl(r.tglBatasSla),
      tglJatuhTempo: parseTgl(tglJatuhTempo),
      tglTerima: parseTgl(r.tglTerima),
      caraSerah: r.caraSerah,
      terlambat: r.terlambat,
      perluReview: r.perluReview,
      fisikBelumKembali: r.fisikBelumKembali,
      tindakan: r.tindakan,
      noResiPos: noResiPos,
      tglKirimPos: parseTgl(tglKirimPos),
      tglUpdate: parseTgl(r.tglUpdate),
      jejak: jejakTerurut(jejak),
    );
  }
}

extension MonitoringBerkasModelX on MonitoringBerkasModel {
  MonitoringBerkasEntity toEntity() => berkas.toEntity(
    alamatWp: alamatWp,
    maksPercobaan: maksPercobaan,
    tglDitugaskan: tglDitugaskan,
    tglJatuhTempo: tglJatuhTempo,
    noResiPos: noResiPos,
    tglKirimPos: tglKirimPos,
    jejak: jejak,
  );
}

extension LacakResultModelX on LacakResultModel {
  LacakResultEntity toEntity() => LacakResultEntity(
    noResi: noResi,
    aksesMonitoring: aksesMonitoring,
    tugasSaya: tugasSaya,
    monitoring: monitoring?.toEntity(),
    tugas: tugas?.toEntity(),
  );
}
