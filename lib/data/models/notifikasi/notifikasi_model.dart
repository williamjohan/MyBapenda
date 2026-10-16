import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/notifikasi/notifikasi_entity.dart';
import '../pengiriman/pengiriman_json_util.dart';

part 'notifikasi_model.g.dart';

/// Item kotak masuk (`inbox`) dan item event SignalR `NOTIF`.
@JsonSerializable()
class NotifikasiModel {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'kodeJenis', defaultValue: '')
  final String kodeJenis;
  @JsonKey(name: 'namaJenis', defaultValue: '')
  final String namaJenis;
  @JsonKey(name: 'reffNo', fromJson: jsonAsString)
  final String? reffNo;
  @JsonKey(name: 'judul', defaultValue: '')
  final String judul;
  @JsonKey(name: 'isi', defaultValue: '')
  final String isi;
  @JsonKey(name: 'tglNotifikasi')
  final String? tglNotifikasi;
  @JsonKey(name: 'dibaca', fromJson: jsonAsBool)
  final bool dibaca;
  @JsonKey(name: 'tglBaca')
  final String? tglBaca;

  const NotifikasiModel({
    required this.id,
    required this.kodeJenis,
    required this.namaJenis,
    this.reffNo,
    required this.judul,
    required this.isi,
    this.tglNotifikasi,
    required this.dibaca,
    this.tglBaca,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) =>
      _$NotifikasiModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotifikasiModelToJson(this);
}

extension NotifikasiModelX on NotifikasiModel {
  NotifikasiEntity toEntity() => NotifikasiEntity(
    id: id,
    kodeJenis: kodeJenis,
    namaJenis: namaJenis,
    reffNo: reffNo,
    judul: judul,
    isi: isi,
    tglNotifikasi: parseTgl(tglNotifikasi),
    dibaca: dibaca,
    tglBaca: parseTgl(tglBaca),
  );
}

@JsonSerializable()
class HalamanNotifikasiModel {
  @JsonKey(name: 'items', defaultValue: [])
  final List<NotifikasiModel> items;
  @JsonKey(name: 'page', defaultValue: 1)
  final int page;
  @JsonKey(name: 'totalPage', defaultValue: 1)
  final int totalPage;
  @JsonKey(name: 'totalData', defaultValue: 0)
  final int totalData;

  const HalamanNotifikasiModel({
    required this.items,
    required this.page,
    required this.totalPage,
    required this.totalData,
  });

  factory HalamanNotifikasiModel.fromJson(Map<String, dynamic> json) =>
      _$HalamanNotifikasiModelFromJson(json);

  Map<String, dynamic> toJson() => _$HalamanNotifikasiModelToJson(this);
}

extension HalamanNotifikasiModelX on HalamanNotifikasiModel {
  HalamanNotifikasiEntity toEntity() => HalamanNotifikasiEntity(
    items: items.map((e) => e.toEntity()).toList(),
    page: page,
    totalPage: totalPage,
    totalData: totalData,
  );
}

/// Payload event SignalR `NOTIF`.
/// - `snapshot=false`: notifikasi BARU; `jumlahBaru` = banyaknya, `items` maks
///   5 terbaru dari yang baru.
/// - `snapshot=true`: keadaan inbox saat connect/reconnect/setelah baca;
///   `items` = maks 5 belum dibaca terbaru.
/// `jumlahBelumDibaca` selalu = nilai badge.
@JsonSerializable()
class NotifEventModel {
  @JsonKey(name: 'snapshot', fromJson: jsonAsBool)
  final bool snapshot;
  @JsonKey(name: 'jumlahBaru', defaultValue: 0)
  final int jumlahBaru;
  @JsonKey(name: 'jumlahBelumDibaca', defaultValue: 0)
  final int jumlahBelumDibaca;
  @JsonKey(name: 'items', defaultValue: [])
  final List<NotifikasiModel> items;

  const NotifEventModel({
    this.snapshot = false,
    required this.jumlahBaru,
    required this.jumlahBelumDibaca,
    required this.items,
  });

  factory NotifEventModel.fromJson(Map<String, dynamic> json) =>
      _$NotifEventModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotifEventModelToJson(this);
}
