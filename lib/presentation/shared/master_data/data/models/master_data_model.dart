import 'package:mybapenda/presentation/shared/master_data/domain/entities/master_data_entity.dart';
import 'master_option_model.dart';

/// Gabungan master reklame yang di-fetch sekali (juga dipakai untuk cache lokal).
/// Kelurahan TIDAK termasuk: harus diambil per kecamatan.
class MasterDataModel {
  final List<MasterOptionModel> lokasiTertentu;
  final List<MasterOptionModel> lokasiPenyelenggaraan;
  final List<MasterOptionModel> jenisReklame;
  final List<MasterOptionModel> letakReklame;
  final List<MasterOptionModel> statusTanah;
  final List<MasterOptionModel> sudutPandang;
  final List<MasterOptionModel> persil;
  final List<MasterOptionModel> jenisBangunan;
  final List<MasterOptionModel> namaJalan;
  final List<MasterOptionModel> kecamatan;

  const MasterDataModel({
    required this.lokasiTertentu,
    required this.lokasiPenyelenggaraan,
    required this.jenisReklame,
    required this.letakReklame,
    required this.statusTanah,
    required this.sudutPandang,
    required this.persil,
    required this.jenisBangunan,
    required this.namaJalan,
    required this.kecamatan,
  });

  static List<MasterOptionModel> _list(Map<String, dynamic> json, String key) =>
      (json[key] as List)
          .map(
            (e) =>
                MasterOptionModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();

  /// Dipakai untuk membaca cache lokal.
  factory MasterDataModel.fromJson(Map<String, dynamic> json) =>
      MasterDataModel(
        lokasiTertentu: _list(json, 'lokasiTertentu'),
        lokasiPenyelenggaraan: _list(json, 'lokasiPenyelenggaraan'),
        jenisReklame: _list(json, 'jenisReklame'),
        letakReklame: _list(json, 'letakReklame'),
        statusTanah: _list(json, 'statusTanah'),
        sudutPandang: _list(json, 'sudutPandang'),
        persil: _list(json, 'persil'),
        jenisBangunan: _list(json, 'jenisBangunan'),
        namaJalan: _list(json, 'namaJalan'),
        kecamatan: _list(json, 'kecamatan'),
      );

  /// Dipakai untuk menyimpan cache lokal.
  Map<String, dynamic> toJson() => {
    'lokasiTertentu': lokasiTertentu.map((e) => e.toJson()).toList(),
    'lokasiPenyelenggaraan': lokasiPenyelenggaraan.map((e) => e.toJson()).toList(),
    'jenisReklame': jenisReklame.map((e) => e.toJson()).toList(),
    'letakReklame': letakReklame.map((e) => e.toJson()).toList(),
    'statusTanah': statusTanah.map((e) => e.toJson()).toList(),
    'sudutPandang': sudutPandang.map((e) => e.toJson()).toList(),
    'persil': persil.map((e) => e.toJson()).toList(),
    'jenisBangunan': jenisBangunan.map((e) => e.toJson()).toList(),
    'namaJalan': namaJalan.map((e) => e.toJson()).toList(),
    'kecamatan': kecamatan.map((e) => e.toJson()).toList(),
  };
}

/// Extension untuk mapping Model ke Entity
extension MasterDataModelX on MasterDataModel {
  MasterDataEntity toEntity() => MasterDataEntity(
    // ID angka
    lokasiTertentu: lokasiTertentu.toIntOptionMap(),
    lokasiPenyelenggaraan: lokasiPenyelenggaraan.toIntOptionMap(),
    jenisReklame: jenisReklame.toIntOptionMap(),
    letakReklame: letakReklame.toIntOptionMap(),
    statusTanah: statusTanah.toIntOptionMap(),
    sudutPandang: sudutPandang.toIntOptionMap(),
    jenisBangunan: jenisBangunan.toIntOptionMap(),
    // ID kode / belum dipastikan
    persil: persil.toOptionMap(),
    namaJalan: namaJalan.toOptionMap(),
    kecamatan: kecamatan.toOptionMap(),
  );
}
