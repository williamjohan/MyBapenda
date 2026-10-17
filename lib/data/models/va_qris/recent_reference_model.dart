import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/va_qris/recent_reference_entity.dart';

part 'recent_reference_model.g.dart';

/// Bentuk riwayat "Terakhir dicari" yang disimpan di SharedPreferences.
@JsonSerializable()
class RecentReferenceModel {
  @JsonKey(name: 'jenisPajak')
  final int jenisPajak;

  @JsonKey(name: 'jenisPajakNama', defaultValue: '')
  final String jenisPajakNama;

  @JsonKey(name: 'noReferensi')
  final String noReferensi;

  @JsonKey(name: 'nama', defaultValue: '')
  final String nama;

  @JsonKey(name: 'disimpan')
  final DateTime disimpan;

  const RecentReferenceModel({
    required this.jenisPajak,
    required this.jenisPajakNama,
    required this.noReferensi,
    required this.nama,
    required this.disimpan,
  });

  factory RecentReferenceModel.fromJson(Map<String, dynamic> json) =>
      _$RecentReferenceModelFromJson(json);

  factory RecentReferenceModel.fromEntity(RecentReferenceEntity entity) =>
      RecentReferenceModel(
        jenisPajak: entity.taxTypeId,
        jenisPajakNama: entity.taxTypeName,
        noReferensi: entity.referenceNumber,
        nama: entity.name,
        disimpan: entity.savedAt,
      );

  Map<String, dynamic> toJson() => _$RecentReferenceModelToJson(this);
}

extension RecentReferenceModelX on RecentReferenceModel {
  RecentReferenceEntity toEntity() => RecentReferenceEntity(
    taxTypeId: jenisPajak,
    taxTypeName: jenisPajakNama,
    referenceNumber: noReferensi,
    name: nama,
    savedAt: disimpan,
  );
}
