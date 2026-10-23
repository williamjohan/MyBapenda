// lib/domain/entities/my_task/my_task_header_entity.dart
import 'package:equatable/equatable.dart';
import 'my_task_entity.dart';

class MyTaskFilterEntity extends Equatable {
  final String kode;
  final String nama;
  final int jumlah;

  const MyTaskFilterEntity({
    required this.kode,
    required this.nama,
    required this.jumlah,
  });

  @override
  List<Object?> get props => [kode, nama, jumlah];
}

class MyTaskSummaryEntity extends Equatable {
  final int aktif;
  final int mendesak;
  final int selesai;
  final int terlewat;

  final MyTaskEntity? tugasTerdekat;

  final List<MyTaskFilterEntity> tabList;
  final List<MyTaskFilterEntity> jenisList;

  final int totalItems;
  final int page;
  final int pageSize;

  const MyTaskSummaryEntity({
    required this.aktif,
    required this.mendesak,
    required this.selesai,
    required this.terlewat,
    required this.tugasTerdekat,
    required this.tabList,
    required this.jenisList,
    required this.totalItems,
    required this.page,
    required this.pageSize,
  });

  bool get hasMore => pageSize > 0 && page * pageSize < totalItems;

  @override
  List<Object?> get props => [
    aktif,
    mendesak,
    selesai,
    terlewat,
    tugasTerdekat,
    tabList,
    jenisList,
    totalItems,
    page,
    pageSize,
  ];
}

class MyTaskHeaderEntity extends Equatable {
  final MyTaskSummaryEntity summary;
  final List<MyTaskEntity> items;

  const MyTaskHeaderEntity({required this.summary, required this.items});

  @override
  List<Object?> get props => [summary, items];
}
