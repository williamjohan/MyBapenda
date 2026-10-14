import 'package:equatable/equatable.dart';

class KategoriPertanyaanEntity extends Equatable {
  final String key;
  final int idKategori;
  final String namaKategori;
  final bool aktif;

  const KategoriPertanyaanEntity({
    required this.key,
    required this.idKategori,
    required this.namaKategori,
    required this.aktif,
  });

  @override
  List<Object?> get props => [key, idKategori, namaKategori, aktif];
}


