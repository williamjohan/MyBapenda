import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failure.dart';
import '../../entities/absensi/absen_entity.dart';
import '../../entities/absensi/riwayat_absensi_entity.dart';
import '../../entities/absensi/ringkasan_absensi_entity.dart';
import '../../repositories/absensi/absensi_repository.dart';

@lazySingleton
class AbsensiUseCase {
  final AbsensiRepository repository;
  AbsensiUseCase(this.repository);

  Future<Either<Failure, RingkasanAbsensiEntity>> getRingkasan({
    DateTime? tanggal,
  }) => repository.getRingkasan(tanggal: tanggal);

  Future<Either<Failure, RiwayatAbsensiPageResult>> getRiwayat({
    required int page,
    int pageSize = 20,
    int? tahun,
    int? bulan,
  }) => repository.getRiwayat(
    page: page,
    pageSize: pageSize,
    tahun: tahun,
    bulan: bulan,
  );

  Future<Either<Failure, AbsenResultEntity>> absen(AbsenParams params) =>
      repository.absen(params);

  Future<Either<Failure, String>> downloadLaporanPdf({
    required int tahun,
    required int bulan,
    void Function(double? progress)? onProgress,
  }) => repository.downloadLaporanPdf(
    tahun: tahun,
    bulan: bulan,
    onProgress: onProgress,
  );
}
