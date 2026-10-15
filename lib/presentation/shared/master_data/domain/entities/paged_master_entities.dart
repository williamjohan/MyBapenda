import 'package:equatable/equatable.dart';

class PagedResultEntity<T> extends Equatable {
  final List<T> items;
  final int currentPage;
  final int totalPage;
  final int totalData;

  const PagedResultEntity({
    required this.items,
    required this.currentPage,
    required this.totalPage,
    required this.totalData,
  });

  bool get hasMore => currentPage < totalPage;

  @override
  List<Object?> get props => [items, currentPage, totalPage, totalData];
}

class JalanEntity extends Equatable {
  final int id;
  final String nama;

  const JalanEntity({required this.id, required this.nama});

  @override
  List<Object?> get props => [id, nama];
}

class PersilEntity extends Equatable {
  final String idPersil;
  final String alamat;
  final String kec;
  final String kel;

  const PersilEntity({
    required this.idPersil,
    required this.alamat,
    required this.kec,
    required this.kel,
  });

  String get label => '$idPersil - $alamat';

  @override
  List<Object?> get props => [idPersil, alamat, kec, kel];
}

class PegawaiSurveyEntity extends Equatable {
  final String nip;
  final String nama;

  const PegawaiSurveyEntity({ required this.nip, required this.nama });

  @override
  List<Object?> get props => [nip, nama];
}
