import 'package:json_annotation/json_annotation.dart';

import 'package:bapendacore/domain/entities/history/history_entity.dart';

part 'history_model.g.dart';

@JsonSerializable()
class HistoryModel {
  final String key;

  final String longitude;

  final String latitude;

  final String alamat;

  final String insDate;

  final String insBy;

  final String? ukuran;

  @JsonKey(name: 'foto')
  final String? photoUrl;

  const HistoryModel({
    required this.key,
    required this.longitude,
    required this.latitude,
    required this.alamat,
    required this.insDate,
    required this.insBy,
    this.ukuran,
    this.photoUrl,
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
      insDate: parsedDate,
      insBy: insBy,
      ukuran: ukuran,
      photoUrl: photoUrl,
    );
  }
}
