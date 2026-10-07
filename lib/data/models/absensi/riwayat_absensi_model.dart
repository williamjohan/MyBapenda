import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/absensi/riwayat_absensi_entity.dart';

part 'riwayat_absensi_model.g.dart';

@JsonSerializable()
class RiwayatAbsensiModel {
  final String tglPresensi;
  @JsonKey(defaultValue: 1)
  final int jenisDevice;
  final String? namaDevice;
  @JsonKey(defaultValue: 'ONLINE')
  final String sumber;
  @JsonKey(defaultValue: true)
  final bool isValid;
  final String? keterangan;
  final String? namaLokasi;

  const RiwayatAbsensiModel({
    required this.tglPresensi,
    required this.jenisDevice,
    this.namaDevice,
    required this.sumber,
    required this.isValid,
    this.keterangan,
    this.namaLokasi,
  });

  factory RiwayatAbsensiModel.fromJson(Map<String, dynamic> json) =>
      _$RiwayatAbsensiModelFromJson(json);

  Map<String, dynamic> toJson() => _$RiwayatAbsensiModelToJson(this);
}

@JsonSerializable()
class RiwayatAbsensiPageModel {
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(defaultValue: 20)
  final int pageSize;
  @JsonKey(defaultValue: 0)
  final int total;
  @JsonKey(defaultValue: <RiwayatAbsensiModel>[])
  final List<RiwayatAbsensiModel> items;

  const RiwayatAbsensiPageModel({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.items,
  });

  factory RiwayatAbsensiPageModel.fromJson(Map<String, dynamic> json) =>
      _$RiwayatAbsensiPageModelFromJson(json);

  Map<String, dynamic> toJson() => _$RiwayatAbsensiPageModelToJson(this);
}

extension RiwayatAbsensiModelX on RiwayatAbsensiModel {
  RiwayatAbsensiEntity toEntity() => RiwayatAbsensiEntity(
    tglPresensi: DateTime.parse(tglPresensi),
    jenisDevice: jenisDevice,
    namaDevice: namaDevice,
    sumber: SumberAbsensi.fromCode(sumber),
    isValid: isValid,
    keterangan: keterangan,
    namaLokasi: namaLokasi,
  );
}

extension RiwayatAbsensiPageModelX on RiwayatAbsensiPageModel {
  RiwayatAbsensiPageResult toEntity() => RiwayatAbsensiPageResult(
    items: items.map((e) => e.toEntity()).toList(),
    page: page,
    pageSize: pageSize,
    total: total,
  );
}
