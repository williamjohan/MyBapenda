import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/failure.dart';
import '../../../core/network/safe_api_call.dart';
import '../../../core/services/device_identity_service.dart';
import '../../../core/storage/app_secure_storage.dart';
import '../../../domain/entities/absensi/absen_entity.dart';
import '../../../domain/entities/absensi/riwayat_absensi_entity.dart';
import '../../../domain/entities/absensi/ringkasan_absensi_entity.dart';
import '../../../domain/repositories/absensi/absensi_repository.dart';
import '../../datasources/absensi/absensi_remote_datasource.dart';
import '../../models/absensi/absen_model.dart';
import '../../models/absensi/riwayat_absensi_model.dart';
import '../../models/absensi/ringkasan_absensi_model.dart';

@LazySingleton(as: AbsensiRepository)
class AbsensiRepositoryImpl implements AbsensiRepository {
  final AbsensiRemoteDataSource _remoteDataSource;
  final DeviceIdentityService _deviceIdentityService;
  final AppSecureStorage _secureStorage;

  AbsensiRepositoryImpl(
    this._remoteDataSource,
    this._deviceIdentityService,
    this._secureStorage,
  );

  @override
  Future<Either<Failure, RingkasanAbsensiEntity>> getRingkasan({
    DateTime? tanggal,
  }) {
    return executeSafeApiCall(() async {
      final model = await _remoteDataSource.getRingkasan(
        tanggal: tanggal == null ? null : _formatDate(tanggal),
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, RiwayatAbsensiPageResult>> getRiwayat({
    required int page,
    int pageSize = 20,
    int? tahun,
    int? bulan,
  }) {
    return executeSafeApiCall(() async {
      final model = await _remoteDataSource.getRiwayat(
        page: page,
        pageSize: pageSize,
        tahun: tahun,
        bulan: bulan,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, AbsenResultEntity>> absen(AbsenParams params) {
    return executeSafeApiCall(() async {
      final device = await _deviceIdentityService.getIdentity();
      final result = await _remoteDataSource.absen(
        AbsenRequestModel(
          kodeDevice: device.kodeDevice,
          namaDevice: device.namaDevice,
          merkModel: device.merkModel,
          osVersion: device.osVersion,
          latitude: params.latitude,
          longitude: params.longitude,
          akurasiMeter: params.akurasiMeter,
          isMockLocation: params.isMockLocation,
          metodeVerifikasi: params.metodeVerifikasi,
          appVersion: device.appVersion,
        ),
      );
      return result.data.toEntity(message: result.message);
    });
  }

  @override
  Future<Either<Failure, String>> downloadLaporanPdf({
    required int tahun,
    required int bulan,
    void Function(double? progress)? onProgress,
  }) async {
    final result = await executeSafeApiCall(
      () => _remoteDataSource.downloadLaporanPdf(
        tahun: tahun,
        bulan: bulan,
        onReceiveProgress: onProgress == null
            ? null
            : (received, total) =>
                  onProgress(total > 0 ? received / total : null),
      ),
    );

    return result.fold<
      Future<Either<Failure, String>>
    >((failure) async => Left(failure), (pdf) async {
      try {
        final fileName = pdf.fileName ?? await _defaultFileName(tahun, bulan);
        final dir = Directory(
          '${(await getApplicationDocumentsDirectory()).path}/laporan_absensi',
        );
        if (!await dir.exists()) await dir.create(recursive: true);

        final file = File('${dir.path}/${_sanitize(fileName)}');
        await file.writeAsBytes(pdf.bytes, flush: true);
        return Right(file.path);
      } on FileSystemException {
        return const Left(FileWriteFailure());
      }
    });
  }

  // ---------------------------------------------------------------------------

  /// `Kehadiran_<NIP>_<yyyyMM>.pdf` bila server tidak mengirim nama file.
  Future<String> _defaultFileName(int tahun, int bulan) async {
    final nip = await _secureStorage.getCurrentNip() ?? 'pegawai';
    return 'Kehadiran_${nip}_$tahun${bulan.toString().padLeft(2, '0')}.pdf';
  }

  String _sanitize(String fileName) =>
      fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
