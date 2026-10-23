// lib/domain/entities/my_task/my_task_checkin_entity.dart
import 'package:equatable/equatable.dart';

class TaskPetugasEntity extends Equatable {
  final String nip;
  final String? opd;

  const TaskPetugasEntity({required this.nip, this.opd});

  @override
  List<Object?> get props => [nip, opd];
}

class TaskCheckinPhotoEntity extends Equatable {
  final String path;
  final double? latitude;
  final double? longitude;
  final String? alamat;

  const TaskCheckinPhotoEntity({
    required this.path,
    this.latitude,
    this.longitude,
    this.alamat,
  });

  @override
  List<Object?> get props => [path, latitude, longitude, alamat];
}

class MyTaskCheckinRequestEntity extends Equatable {
  final String jenis;
  final String key;
  final int status;
  final String? keyKirim;

  final String keterangan;
  final List<TaskPetugasEntity> petugas;

  final TaskCheckinPhotoEntity? fotoCheckin;
  final TaskCheckinPhotoEntity? fotoSebelum;
  final TaskCheckinPhotoEntity? fotoSesudah;

  const MyTaskCheckinRequestEntity({
    required this.jenis,
    required this.key,
    required this.keterangan,
    required this.petugas,
    this.status = 1,
    this.keyKirim,
    this.fotoCheckin,
    this.fotoSebelum,
    this.fotoSesudah,
  });

  @override
  List<Object?> get props => [
    jenis,
    key,
    status,
    keyKirim,
    keterangan,
    petugas,
    fotoCheckin,
    fotoSebelum,
    fotoSesudah,
  ];
}
