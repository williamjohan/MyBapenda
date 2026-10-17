// lib/data/repositories/profile/profile_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failure.dart';
import '../../../core/network/safe_api_call.dart';
import '../../../domain/entities/profile/foto_profil_entity.dart';
import '../../../domain/entities/profile/jenis_kontak.dart';
import '../../../domain/entities/profile/kontak_profil_entity.dart';
import '../../../domain/repositories/profile/i_profile_repository.dart';
import '../../datasources/profile/profile_remote_datasource.dart';
import '../../models/profile/profile_model.dart';

@LazySingleton(as: IProfileRepository)
class ProfileRepositoryImpl implements IProfileRepository {
  final IProfileRemoteDataSource _remote;

  ProfileRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, FotoProfilEntity>> gantiFoto(String fotoPath) =>
      executeSafeApiCall(() async {
        final model = await _remote.gantiFoto(
          GantiFotoPayloadModel(fotoPath: fotoPath),
        );
        return model.toEntity();
      });

  @override
  Future<Either<Failure, KirimOtpEntity>> kirimOtpKontak({
    required JenisKontak kontak,
    required String tujuan,
  }) => executeSafeApiCall(() async {
    final model = await _remote.kirimOtpKontak(
      KirimOtpKontakRequestModel(
        kontak: kontak.apiValue,
        tujuan: tujuan.trim(),
      ),
    );
    return model.toEntity();
  });

  @override
  Future<Either<Failure, KontakProfilEntity>> verifikasiOtpKontak({
    required JenisKontak kontak,
    required String tujuan,
    required String kode,
  }) => executeSafeApiCall(() async {
    final model = await _remote.verifikasiOtpKontak(
      VerifikasiOtpKontakRequestModel(
        kontak: kontak.apiValue,
        tujuan: tujuan.trim(),
        kode: kode.trim(),
      ),
    );
    return model.toEntity();
  });
}
