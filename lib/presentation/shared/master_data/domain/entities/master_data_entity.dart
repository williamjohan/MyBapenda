import 'package:equatable/equatable.dart';

class MasterDataEntity extends Equatable {
  // ID angka
  final Map<int, String> lokasiTertentu;
  final Map<int, String> lokasiPenyelenggaraan;
  final Map<int, String> jenisReklame;
  final Map<int, String> letakReklame;
  final Map<int, String> statusTanah;
  final Map<int, String> sudutPandang;
  final Map<int, String> jenisBangunan;

  // ID berupa kode / belum dipastikan angka
  final Map<String, String> persil;
  final Map<String, String> namaJalan;
  final Map<String, String> kecamatan;

  const MasterDataEntity({
    required this.lokasiTertentu,
    required this.lokasiPenyelenggaraan,
    required this.jenisReklame,
    required this.letakReklame,
    required this.statusTanah,
    required this.sudutPandang,
    required this.jenisBangunan,
    required this.persil,
    required this.namaJalan,
    required this.kecamatan,
  });

  @override
  List<Object?> get props => [
    lokasiTertentu,
    lokasiPenyelenggaraan,
    jenisReklame,
    letakReklame,
    statusTanah,
    sudutPandang,
    jenisBangunan,
    persil,
    namaJalan,
    kecamatan,
  ];
}
