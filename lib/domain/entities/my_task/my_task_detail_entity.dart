// lib/domain/entities/my_task/my_task_detail_entity.dart
import 'package:equatable/equatable.dart';
import 'my_task_entity.dart';

class MyTaskDetailEntity extends Equatable {
  final String jenis;
  final String jenisNama;
  final String keyTask;

  final String noReferensi;
  final String nomorPelayanan;
  final String namaWp;
  final String jenisPajak;
  final String jenisObjek;
  final String alamatObjek;

  final DateTime? taskAssign;
  final DateTime? expAssign;

  const MyTaskDetailEntity({
    required this.jenis,
    required this.jenisNama,
    required this.keyTask,
    required this.noReferensi,
    required this.nomorPelayanan,
    required this.namaWp,
    required this.jenisPajak,
    required this.jenisObjek,
    required this.alamatObjek,
    required this.taskAssign,
    required this.expAssign,
  });

  MyTaskJenis get jenisType => MyTaskJenis.fromCode(jenis);

  @override
  List<Object?> get props => [
    jenis,
    jenisNama,
    keyTask,
    noReferensi,
    nomorPelayanan,
    namaWp,
    jenisPajak,
    jenisObjek,
    alamatObjek,
    taskAssign,
    expAssign,
  ];
}
