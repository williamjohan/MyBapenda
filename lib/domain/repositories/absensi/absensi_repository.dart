import 'package:dartz/dartz.dart';

import '../../../core/errors/failure.dart';
import '../../entities/absensi/absen_entity.dart';
import '../../entities/absensi/riwayat_absensi_entity.dart';
import '../../entities/absensi/ringkasan_absensi_entity.dart';

abstract class AbsensiRepository {
  Future<Either<Failure, RingkasanAbsensiEntity>> getRingkasan({
    DateTime? tanggal,
  });

  Future<Either<Failure, RiwayatAbsensiPageResult>> getRiwayat({
    required int page,
    int pageSize = 20,
    int? tahun,
    int? bulan,
  });

  Future<Either<Failure, AbsenResultEntity>> absen(AbsenParams params);

  /// Unduh PDF laporan kehadiran bulanan, return path file lokal.
  Future<Either<Failure, String>> downloadLaporanPdf({
    required int tahun,
    required int bulan,
    void Function(double? progress)? onProgress,
  });
}
