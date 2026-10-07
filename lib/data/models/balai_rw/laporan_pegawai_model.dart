import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/balai_rw/laporan_pegawai_entity.dart';

part 'laporan_pegawai_model.g.dart';

@JsonSerializable(explicitToJson: true) // 🚀 WAJIB true agar list bersarang bisa di-POST
class LaporanPegawaiModel {
  @JsonKey(name: 'key')
  final String key;
  
  @JsonKey(name: 'idLaporan')
  final int idLaporan;
  
  @JsonKey(name: 'idRoster')
  final int idRoster;
  
  @JsonKey(name: 'tanggalLaporan')
  final String tanggalLaporan;
  
  @JsonKey(name: 'insDate')
  final String insDate;
  
  @JsonKey(name: 'jawaban')
  final List<JawabanModel> jawaban;
  
  @JsonKey(name: 'kehadiran')
  final List<KehadiranModel> kehadiran;

  const LaporanPegawaiModel({
    required this.key,
    required this.idLaporan,
    required this.idRoster,
    required this.tanggalLaporan,
    required this.insDate,
    required this.jawaban,
    required this.kehadiran,
  });

  factory LaporanPegawaiModel.fromJson(Map<String, dynamic> json) =>
      _$LaporanPegawaiModelFromJson(json);

  Map<String, dynamic> toJson() => _$LaporanPegawaiModelToJson(this);
}

// ====================================================================
// SUB-MODELS (NESTED OBJECTS)
// ====================================================================

@JsonSerializable()
class JawabanModel {
  @JsonKey(name: 'idPertanyaan')
  final int idPertanyaan;
  
  @JsonKey(name: 'pertanyaan')
  final String pertanyaan;
  
  @JsonKey(name: 'jawaban')
  final String? jawaban; // 🚀 Nullable berdasarkan contoh JSON

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
class KehadiranModel {
  @JsonKey(name: 'key')
  final String key;
  
  @JsonKey(name: 'jamMasuk')
  final String jamMasuk;
  
  @JsonKey(name: 'jamPulang')
  final String? jamPulang; // 🚀 Nullable
  
  @JsonKey(name: 'keterangan')
  final String keterangan;
  
  @JsonKey(name: 'fotoUrl')
  final String? fotoUrl; // 🚀 Nullable

  const KehadiranModel({
    required this.key,
    required this.jamMasuk,
    this.jamPulang,
    required this.keterangan,
    this.fotoUrl,
  });

  factory KehadiranModel.fromJson(Map<String, dynamic> json) =>
      _$KehadiranModelFromJson(json);

  Map<String, dynamic> toJson() => _$KehadiranModelToJson(this);
}

// ====================================================================
// EXTENSIONS (MAPPER KE ENTITY) - Sesuai Aturan No. 2
// ====================================================================

extension LaporanPegawaiModelX on LaporanPegawaiModel {
  LaporanPegawaiEntity toEntity() => LaporanPegawaiEntity(
        key: key,
        idLaporan: idLaporan,
        idRoster: idRoster,
        tanggalLaporan: tanggalLaporan,
        insDate: insDate,
        jawaban: jawaban.map((e) => e.toEntity()).toList(),
        kehadiran: kehadiran.map((e) => e.toEntity()).toList(),
      );
}

extension JawabanModelX on JawabanModel {
  JawabanEntity toEntity() => JawabanEntity(
        idPertanyaan: idPertanyaan,
        pertanyaan: pertanyaan,
        jawaban: jawaban,
      );
}

extension KehadiranModelX on KehadiranModel {
  KehadiranEntity toEntity() => KehadiranEntity(
        key: key,
        jamMasuk: jamMasuk,
        jamPulang: jamPulang,
        keterangan: keterangan,
        fotoUrl: fotoUrl,
      );
}

// ====================================================================
// EXTENSIONS (MAPPER DARI ENTITY KEMBALI KE MODEL)
// Digunakan saat POST request di Repository
// ====================================================================

extension LaporanPegawaiEntityX on LaporanPegawaiEntity {
  LaporanPegawaiModel toModel() => LaporanPegawaiModel(
        key: key,
        idLaporan: idLaporan,
        idRoster: idRoster,
        tanggalLaporan: tanggalLaporan,
        insDate: insDate,
        jawaban: jawaban.map((e) => e.toModel()).toList(),
        kehadiran: kehadiran.map((e) => e.toModel()).toList(),
      );
}

extension JawabanEntityX on JawabanEntity {
  JawabanModel toModel() => JawabanModel(
        idPertanyaan: idPertanyaan,
        pertanyaan: pertanyaan,
        jawaban: jawaban,
      );
}

extension KehadiranEntityX on KehadiranEntity {
  KehadiranModel toModel() => KehadiranModel(
        key: key,
        jamMasuk: jamMasuk,
        jamPulang: jamPulang,
        keterangan: keterangan,
        fotoUrl: fotoUrl,
      );
}