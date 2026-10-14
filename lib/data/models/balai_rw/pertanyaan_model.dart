import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/balai_rw/pertanyaan_entity.dart';

part 'pertanyaan_model.g.dart';

@JsonSerializable()
class PertanyaanModel {
  @JsonKey(name: 'key')
  final String key;
  @JsonKey(name: 'idPertanyaan')
  final int idPertanyaan;
  @JsonKey(name: 'idKategori')
  final int idKategori;
  @JsonKey(name: 'namaKategori')
  final String namaKategori;
  @JsonKey(name: 'pertanyaan')
  final String pertanyaan;
  @JsonKey(name: 'tipeJawaban')
  final String tipeJawaban;
  @JsonKey(name: 'seq')
  final int seq;
  @JsonKey(name: 'aktif')
  final bool aktif;

  const PertanyaanModel({
    required this.key,
    required this.idPertanyaan,
    required this.idKategori,
    required this.namaKategori,
    required this.pertanyaan,
    required this.tipeJawaban,
    required this.seq,
    required this.aktif,
  });

  factory PertanyaanModel.fromJson(Map<String, dynamic> json) =>
      _$PertanyaanModelFromJson(json);

  Map<String, dynamic> toJson() => _$PertanyaanModelToJson(this);
}

/// Extension untuk mapping Model ke Entity
extension PertanyaanModelX on PertanyaanModel {
  PertanyaanEntity toEntity() => PertanyaanEntity(
        key: key,
        idPertanyaan: idPertanyaan,
        idKategori: idKategori,
        namaKategori: namaKategori,
        pertanyaan: pertanyaan,
        tipeJawaban: tipeJawaban,
        seq: seq,
        aktif: aktif,
      );
}