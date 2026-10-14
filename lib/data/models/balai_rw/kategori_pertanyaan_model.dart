import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/balai_rw/kategori_pertanyaan_entity.dart';

part 'kategori_pertanyaan_model.g.dart';

@JsonSerializable()
class KategoriPertanyaanModel {
  @JsonKey(name: 'key')
  final String key;
  @JsonKey(name: 'idKategori')
  final int idKategori;
  @JsonKey(name: 'namaKategori')
  final String namaKategori;
  @JsonKey(name: 'aktif')
  final bool aktif;

  const KategoriPertanyaanModel({
    required this.key,
    required this.idKategori,
    required this.namaKategori,
    required this.aktif,
  });

  factory KategoriPertanyaanModel.fromJson(Map<String, dynamic> json) =>
      _$KategoriPertanyaanModelFromJson(json);

  Map<String, dynamic> toJson() => _$KategoriPertanyaanModelToJson(this);
}

/// Extension untuk mapping Model ke Entity
extension KategoriModelX on KategoriPertanyaanModel {
  KategoriPertanyaanEntity toEntity() => KategoriPertanyaanEntity(
        key: key,
        idKategori: idKategori,
        namaKategori: namaKategori,
        aktif: aktif,
      );
}