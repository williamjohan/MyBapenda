import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/va_qris/tax_type_entity.dart';

part 'tax_type_model.g.dart';

@JsonSerializable()
class TaxTypeModel {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'nama', defaultValue: '')
  final String nama;

  @JsonKey(name: 'labelReferensi', defaultValue: '')
  final String labelReferensi;

  @JsonKey(name: 'hint', defaultValue: '')
  final String hint;

  @JsonKey(name: 'panjangReferensi')
  final int? panjangReferensi;

  @JsonKey(name: 'hanyaAngka', defaultValue: false)
  final bool hanyaAngka;

  @JsonKey(name: 'mask')
  final String? mask;

  const TaxTypeModel({
    required this.id,
    required this.nama,
    required this.labelReferensi,
    required this.hint,
    required this.hanyaAngka,
    this.panjangReferensi,
    this.mask,
  });

  factory TaxTypeModel.fromJson(Map<String, dynamic> json) =>
      _$TaxTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaxTypeModelToJson(this);
}

extension TaxTypeModelX on TaxTypeModel {
  TaxTypeEntity toEntity() => TaxTypeEntity(
    id: id,
    name: nama,
    referenceLabel: labelReferensi,
    hint: hint,
    digitsOnly: hanyaAngka,
    referenceLength: panjangReferensi,
    mask: mask,
  );
}
