import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/absensi/ringkasan_absensi_entity.dart';

part 'ringkasan_absensi_model.g.dart';

@JsonSerializable()
class RingkasanAbsensiModel {
  @JsonKey(defaultValue: '')
  final String nip;
  @JsonKey(defaultValue: '')
  final String nama;

  /// "yyyy-MM-dd"
  final String tanggal;

  /// "yyyy-MM-ddTHH:mm:ss" WIB tanpa offset.
  final String? masuk;
  final String? pulang;
  final String? jamMasukJadwal;
  final String? jamPulangJadwal;
  @JsonKey(defaultValue: 0)
  final int menitTelat;
  @JsonKey(defaultValue: 0)
  final int menitPsw;
  final String? keterangan;

  const RingkasanAbsensiModel({
    required this.nip,
    required this.nama,
    required this.tanggal,
    this.masuk,
    this.pulang,
    this.jamMasukJadwal,
    this.jamPulangJadwal,
    required this.menitTelat,
    required this.menitPsw,
    this.keterangan,
  });

  factory RingkasanAbsensiModel.fromJson(Map<String, dynamic> json) =>
      _$RingkasanAbsensiModelFromJson(json);

  Map<String, dynamic> toJson() => _$RingkasanAbsensiModelToJson(this);
}

extension RingkasanAbsensiModelX on RingkasanAbsensiModel {
  // Waktu dari API sudah WIB tanpa offset → DateTime.parse langsung,
  // jangan .toLocal() lagi.
  RingkasanAbsensiEntity toEntity() => RingkasanAbsensiEntity(
    nip: nip,
    nama: nama,
    tanggal: DateTime.parse(tanggal),
    masuk: masuk == null ? null : DateTime.tryParse(masuk!),
    pulang: pulang == null ? null : DateTime.tryParse(pulang!),
    jamMasukJadwal: jamMasukJadwal,
    jamPulangJadwal: jamPulangJadwal,
    menitTelat: menitTelat,
    menitPsw: menitPsw,
    keterangan: keterangan,
  );
}
