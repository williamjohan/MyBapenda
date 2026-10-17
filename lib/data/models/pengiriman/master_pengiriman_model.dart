import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/pengiriman/berkas_entity.dart';
import '../../../domain/entities/pengiriman/master_pengiriman_entity.dart';
import '../../../domain/entities/pengiriman/pengiriman_payload_entity.dart';
import 'pengiriman_json_util.dart';

part 'master_pengiriman_model.g.dart';

@JsonSerializable()
class OpsiMasterModel {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'nama', defaultValue: '-')
  final String nama;
  @JsonKey(name: 'wajibKeterangan', fromJson: jsonAsBool)
  final bool wajibKeterangan;

  const OpsiMasterModel({
    required this.id,
    required this.nama,
    this.wajibKeterangan = false,
  });

  factory OpsiMasterModel.fromJson(Map<String, dynamic> json) =>
      _$OpsiMasterModelFromJson(json);

  Map<String, dynamic> toJson() => _$OpsiMasterModelToJson(this);
}

@JsonSerializable()
class MasterPengirimanModel {
  @JsonKey(name: 'hubunganPenerima', defaultValue: <OpsiMasterModel>[])
  final List<OpsiMasterModel> hubunganPenerima;
  @JsonKey(name: 'alasanGagal', defaultValue: <OpsiMasterModel>[])
  final List<OpsiMasterModel> alasanGagal;
  @JsonKey(name: 'caraSerah', defaultValue: <OpsiMasterModel>[])
  final List<OpsiMasterModel> caraSerah;

  const MasterPengirimanModel({
    required this.hubunganPenerima,
    required this.alasanGagal,
    required this.caraSerah,
  });

  factory MasterPengirimanModel.fromJson(Map<String, dynamic> json) =>
      _$MasterPengirimanModelFromJson(json);

  Map<String, dynamic> toJson() => _$MasterPengirimanModelToJson(this);
}

/// `HasilCheckin` dari semua POST pengiriman.
@JsonSerializable()
class HasilCheckinModel {
  @JsonKey(name: 'noResi', defaultValue: '')
  final String noResi;
  @JsonKey(name: 'statusId')
  final int? statusId;
  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'diabaikan', fromJson: jsonAsBool)
  final bool diabaikan;
  @JsonKey(name: 'duplikat', fromJson: jsonAsBool)
  final bool duplikat;
  @JsonKey(name: 'pesan')
  final String? pesan;

  const HasilCheckinModel({
    required this.noResi,
    this.statusId,
    this.status,
    this.diabaikan = false,
    this.duplikat = false,
    this.pesan,
  });

  factory HasilCheckinModel.fromJson(Map<String, dynamic> json) =>
      _$HasilCheckinModelFromJson(json);

  Map<String, dynamic> toJson() => _$HasilCheckinModelToJson(this);
}

extension OpsiMasterModelX on OpsiMasterModel {
  OpsiMasterEntity toEntity() =>
      OpsiMasterEntity(id: id, nama: nama, wajibKeterangan: wajibKeterangan);
}

extension MasterPengirimanModelX on MasterPengirimanModel {
  MasterPengirimanEntity toEntity() => MasterPengirimanEntity(
    hubunganPenerima: hubunganPenerima.map((e) => e.toEntity()).toList(),
    alasanGagal: alasanGagal.map((e) => e.toEntity()).toList(),
    caraSerah: caraSerah.map((e) => e.toEntity()).toList(),
  );
}

extension HasilCheckinModelX on HasilCheckinModel {
  HasilCheckinEntity toEntity() => HasilCheckinEntity(
    noResi: noResi,
    status: statusId == null ? null : StatusBerkas.fromId(statusId),
    statusNama: status,
    diabaikan: diabaikan,
    duplikat: duplikat,
    pesan: pesan,
  );
}
