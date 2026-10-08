// lib/data/models/balai_rw/laporan_pegawai_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/balai_rw/laporan_pegawai_entity.dart';

part 'laporan_pegawai_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LaporanPegawaiModel {
  @JsonKey(name: 'key', defaultValue: '')
  final String key;

  @JsonKey(name: 'idLaporan', defaultValue: 0)
  final int idLaporan;

  @JsonKey(name: 'idRoster', defaultValue: 0)
  final int idRoster;

  @JsonKey(name: 'tanggalLaporan', defaultValue: '')
  final String tanggalLaporan;

  @JsonKey(name: 'insDate', defaultValue: '')
  final String insDate;

  @JsonKey(name: 'jawaban', defaultValue: [])
  final List<JawabanModel> jawaban;

  @JsonKey(name: 'checkin')
  final AbsenModel? checkin;

  @JsonKey(name: 'checkout')
  final AbsenModel? checkout;

  const LaporanPegawaiModel({
    required this.key,
    required this.idLaporan,
    required this.idRoster,
    required this.tanggalLaporan,
    required this.insDate,
    required this.jawaban,
    this.checkin,
    this.checkout,
  });

  factory LaporanPegawaiModel.fromJson(Map<String, dynamic> json) =>
      _$LaporanPegawaiModelFromJson(json);

  Map<String, dynamic> toJson() => _$LaporanPegawaiModelToJson(this);
}

@JsonSerializable()
class JawabanModel {
  @JsonKey(name: 'idPertanyaan')
  final int idPertanyaan;

  @JsonKey(name: 'pertanyaan', defaultValue: '')
  final String pertanyaan;

  @JsonKey(name: 'jawaban')
  final String? jawaban;

  const JawabanModel({
    required this.idPertanyaan,
    required this.pertanyaan,
    this.jawaban,
  });

  factory JawabanModel.fromJson(Map<String, dynamic> json) =>
      _$JawabanModelFromJson(json);

  Map<String, dynamic> toJson() => _$JawabanModelToJson(this);
}

@JsonSerializable()
class AbsenModel {
  @JsonKey(name: 'key', defaultValue: '')
  final String key;

  @JsonKey(name: 'jam')
  final String? jam;

  @JsonKey(name: 'waktu')
  final String? waktu;

  @JsonKey(name: 'keterangan')
  final String? keterangan;

  @JsonKey(name: 'fotoUrl')
  final String? fotoUrl;

  const AbsenModel({
    required this.key,
    this.jam,
    this.waktu,
    this.keterangan,
    this.fotoUrl,
  });

  factory AbsenModel.fromJson(Map<String, dynamic> json) =>
      _$AbsenModelFromJson(json);

  Map<String, dynamic> toJson() => _$AbsenModelToJson(this);
}

// Mapper ke Entity
extension LaporanPegawaiModelX on LaporanPegawaiModel {
  LaporanPegawaiEntity toEntity() => LaporanPegawaiEntity(
    key: key,
    idLaporan: idLaporan,
    idRoster: idRoster,
    tanggalLaporan: tanggalLaporan,
    insDate: insDate,
    jawaban: jawaban.map((e) => e.toEntity()).toList(),
    checkin: checkin?.toEntity(),
    checkout: checkout?.toEntity(),
  );
}

extension JawabanModelX on JawabanModel {
  JawabanEntity toEntity() => JawabanEntity(
    idPertanyaan: idPertanyaan,
    pertanyaan: pertanyaan,
    jawaban: jawaban,
  );
}

extension AbsenModelX on AbsenModel {
  String get _jamFinal {
    final j = jam?.trim() ?? '';
    if (j.isNotEmpty) return j;
    final parts = (waktu ?? '').trim().split(RegExp(r'[ T]'));
    return parts.length > 1 ? parts[1] : '';
  }

  AbsenEntity toEntity() => AbsenEntity(
    key: key,
    jam: _jamFinal,
    keterangan: keterangan,
    fotoUrl: fotoUrl,
  );
}
