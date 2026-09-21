import 'package:json_annotation/json_annotation.dart';

import 'package:bapendacore/domain/entities/history/history_entity.dart';

part 'history_model.g.dart';

@JsonSerializable()
class HistoryPhotoModel {
  final String? imageUrl;
  final String? namaFile;
  final String? ukuranFile;
  final String? tipeFile;
  final String? contentType;

  const HistoryPhotoModel({
    this.imageUrl,
    this.namaFile,
    this.ukuranFile,
    this.tipeFile,
    this.contentType,
  });

  factory HistoryPhotoModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryPhotoModelFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryPhotoModelToJson(this);
}

@JsonSerializable()
class HistoryModel {
  final String key;
  final String longitude;
  final String latitude;
  final String alamat;

  final double? panjang;
  final double? lebar;
  final double? tinggi;

  final String insDate;
  final String insBy;

  final HistoryPhotoModel? foto;

  const HistoryModel({
    required this.key,
    required this.longitude,
    required this.latitude,
    required this.alamat,
    this.panjang,
    this.lebar,
    this.tinggi,
    required this.insDate,
    required this.insBy,
    this.foto,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryModelToJson(this);
}

extension HistoryModelX on HistoryModel {
  HistoryEntity toEntity() {
    final parsedDate =
        DateTime.tryParse(insDate.replaceFirst(' ', 'T')) ?? DateTime.now();

    return HistoryEntity(
      key: key,
      longitude: longitude,
      latitude: latitude,
      alamat: alamat,
      panjang: panjang,
      lebar: lebar,
      tinggi: tinggi,
      insDate: parsedDate,
      insBy: insBy,
      photoUrl: foto?.imageUrl,
    );
  }
}
