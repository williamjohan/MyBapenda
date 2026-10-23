// lib/domain/entities/my_task/my_task_entity.dart
import 'package:equatable/equatable.dart';

enum MyTaskJenis {
  himbauan('himbauan'),
  teguran('teguran'),
  silang('silang'),
  unsilang('unsilang'),
  bongkar('bongkar'),
  unknown('');

  final String code;
  const MyTaskJenis(this.code);

  static MyTaskJenis fromCode(String? code) {
    final c = (code ?? '').trim().toLowerCase();
    return MyTaskJenis.values.firstWhere(
      (e) => e != MyTaskJenis.unknown && e.code == c,
      orElse: () => MyTaskJenis.unknown,
    );
  }
}

enum MyTaskStatus {
  berjalan('berjalan'),
  selesai('selesai'),
  terlewat('terlewat'),
  unknown('');

  final String code;
  const MyTaskStatus(this.code);

  static MyTaskStatus fromCode(String? code) {
    final c = (code ?? '').trim().toLowerCase();
    return MyTaskStatus.values.firstWhere(
      (e) => e != MyTaskStatus.unknown && e.code == c,
      orElse: () => MyTaskStatus.unknown,
    );
  }
}

class MyTaskEntity extends Equatable {
  final String jenis;
  final String jenisNama;
  final String keyTask;
  final String noSkpd;
  final DateTime? tglSurat;
  final DateTime? startTask;
  final DateTime? expTask;
  final int sisaHari;

  final String status;
  final String statusNama;
  final bool bisaDikerjakan;
  final String? keterangan;

  final String npwpd;
  final String namaWp;
  final String alamatWp;
  final String jenisReklameNama;

  const MyTaskEntity({
    required this.jenis,
    required this.jenisNama,
    required this.keyTask,
    required this.noSkpd,
    required this.tglSurat,
    required this.startTask,
    required this.expTask,
    required this.sisaHari,
    required this.status,
    required this.statusNama,
    required this.bisaDikerjakan,
    required this.keterangan,
    required this.npwpd,
    required this.namaWp,
    required this.alamatWp,
    required this.jenisReklameNama,
  });

  MyTaskJenis get jenisType => MyTaskJenis.fromCode(jenis);
  MyTaskStatus get statusType => MyTaskStatus.fromCode(status);

  bool get isSelesai => statusType == MyTaskStatus.selesai;

  @override
  List<Object?> get props => [
    jenis,
    jenisNama,
    keyTask,
    noSkpd,
    tglSurat,
    startTask,
    expTask,
    sisaHari,
    status,
    statusNama,
    bisaDikerjakan,
    keterangan,
    npwpd,
    namaWp,
    alamatWp,
    jenisReklameNama,
  ];
}
