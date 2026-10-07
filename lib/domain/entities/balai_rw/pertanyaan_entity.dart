import 'package:equatable/equatable.dart';

class PertanyaanEntity extends Equatable {
  final String key;
  final int idPertanyaan;
  final int idKategori;
  final String namaKategori;
  final String pertanyaan;
  final String tipeJawaban;
  final int seq;
  final bool aktif;

  const PertanyaanEntity({
    required this.key,
    required this.idPertanyaan,
    required this.idKategori,
    required this.namaKategori,
    required this.pertanyaan,
    required this.tipeJawaban,
    required this.seq,
    required this.aktif,
  });

  @override
  List<Object?> get props => [
        key,
        idPertanyaan,
        idKategori,
        namaKategori,
        pertanyaan,
        tipeJawaban,
        seq,
        aktif,
      ];
}