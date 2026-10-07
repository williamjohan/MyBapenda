import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/absensi/absen_entity.dart';
import 'ringkasan_absensi_model.dart';

part 'absen_model.g.dart';

/// Body `POST /api/kantor/absensi/absen`. Waktu TIDAK dikirim (pakai jam server),
/// NIP juga tidak (diambil dari token).
@JsonSerializable(createFactory: false)
class AbsenRequestModel {
  final String kodeDevice;
  final String namaDevice;
  final String merkModel;
  final String osVersion;
  final double latitude;
  final double longitude;
  final double akurasiMeter;
  final bool isMockLocation;
  final String metodeVerifikasi;
  final String appVersion;

  const AbsenRequestModel({
    required this.kodeDevice,
    required this.namaDevice,
    required this.merkModel,
    required this.osVersion,
    required this.latitude,
    required this.longitude,
    required this.akurasiMeter,
    required this.isMockLocation,
    required this.metodeVerifikasi,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() => _$AbsenRequestModelToJson(this);
}

@JsonSerializable()
class AbsenResultModel {
  final String tglPresensi;
  @JsonKey(defaultValue: 'SCAN')
  final String jenis;
  final String? namaLokasi;
  final double? jarakMeter;
  @JsonKey(defaultValue: 0)
  final int menitTelat;
  @JsonKey(defaultValue: 0)
  final int menitPsw;
  final RingkasanAbsensiModel ringkasan;

  const AbsenResultModel({
    required this.tglPresensi,
    required this.jenis,
    this.namaLokasi,
    this.jarakMeter,
    required this.menitTelat,
    required this.menitPsw,
    required this.ringkasan,
  });

  factory AbsenResultModel.fromJson(Map<String, dynamic> json) =>
      _$AbsenResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$AbsenResultModelToJson(this);
}

extension AbsenResultModelX on AbsenResultModel {
  AbsenResultEntity toEntity({required String message}) => AbsenResultEntity(
    message: message,
    tglPresensi: DateTime.parse(tglPresensi),
    jenis: JenisAbsen.fromCode(jenis),
    namaLokasi: namaLokasi,
    jarakMeter: jarakMeter,
    menitTelat: menitTelat,
    menitPsw: menitPsw,
    ringkasan: ringkasan.toEntity(),
  );
}
