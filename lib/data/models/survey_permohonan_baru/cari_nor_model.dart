import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/cek_reklames/survey_permohonan_baru/cari_nor_entity.dart';

part 'cari_nor_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CariNorModel {
  @JsonKey(name : 'idNor')
  final String idNor;
  @JsonKey(name : 'idPersil')
  final String idPersil;
  @JsonKey(name : 'nopPbb')
  final String nopPbb;
  @JsonKey(name : 'idJenisBangunan')
  final int idJenisBangunan;
  @JsonKey(name : 'jenisBangunan')
  final String jenisBangunan;
  @JsonKey(name : 'idJalan')
  final int idJalan;
  @JsonKey(name : 'namaJalan')
  final String namaJalan;
  @JsonKey(name : 'noAlamat')
  final String noAlamat;

  CariNorModel({
    required this.idNor,
    required this.idPersil,
    required this.nopPbb,
    required this.idJenisBangunan,
    required this.jenisBangunan,
    required this.idJalan,
    required this.namaJalan,
    required this.noAlamat,
  });

  factory CariNorModel.fromJson(Map<String, dynamic> json) => _$CariNorModelFromJson(json);
}

// Extension to convert Model to Entity
extension CariNorModelMapper on CariNorModel {
  CariNorEntity toEntity() {
    return CariNorEntity(
      idNor: idNor,
      idPersil: idPersil,
      nopPbb: nopPbb,
      idJenisBangunan: idJenisBangunan,
      jenisBangunan: jenisBangunan,
      idJalan: idJalan,
      namaJalan: namaJalan,
      noAlamat: noAlamat,
    );
  }
}