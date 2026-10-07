import 'package:bapendacore/data/models/balai_rw/kategori_pertanyaan_model.dart';
import 'package:bapendacore/data/models/balai_rw/laporan_pegawai_model.dart';
import 'package:bapendacore/data/models/balai_rw/roster_pegawai_model.dart';
import 'package:bapendacore/domain/entities/balai_rw/laporan_pegawai_entity.dart';
import 'package:bapendacore/domain/entities/balai_rw/roster_pegawai_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/network/safe_api_call.dart';
import '../../../domain/entities/balai_rw/kategori_pertanyaan_entity.dart';
import '../../../domain/entities/balai_rw/pertanyaan_entity.dart';
import '../../../domain/repositories/balai_rw/i_balai_rw_repository.dart';
import '../../datasources/balai_rw/balai_rw_remote_datasource.dart';
import '../../models/balai_rw/pertanyaan_model.dart';


@LazySingleton(as: IBalaiRwRepository)
class BalaiRwRepositoryImpl implements IBalaiRwRepository {
  final IBalaiRwRemoteDataSource _remoteDataSource;

  BalaiRwRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<KategoriPertanyaanEntity>>> getKategori({
    bool hanyaAktif = true,
  }) {
    return executeSafeApiCall<List<KategoriPertanyaanEntity>>(() async {
      final models = await _remoteDataSource.getKategori(hanyaAktif: hanyaAktif);
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<PertanyaanEntity>>> getPertanyaan({
    int? idKategori,
    bool hanyaAktif = true,
  }) {
    return executeSafeApiCall<List<PertanyaanEntity>>(() async {
      final models = await _remoteDataSource.getPertanyaan(
        idKategori: idKategori,
        hanyaAktif: hanyaAktif,
      );
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<RosterPegawaiEntity>>> getRosterPegawai({required String tanggalAwal, required String tanggalAkhir}) {
    return executeSafeApiCall<List<RosterPegawaiEntity>>(() async {
      final models = await _remoteDataSource.getRosterPegawai(
        tanggalAwal: tanggalAwal,
        tanggalAkhir: tanggalAkhir,
      );
      return models.map((model) => model.toEntity()).toList();
    });
  }
  
  @override
  Future<Either<Failure, List<LaporanPegawaiEntity>>> getLaporanAbsensi({required String tanggalAwal, required String tanggalAkhir}) {
    return executeSafeApiCall<List<LaporanPegawaiEntity>>(() async {
      final models = await _remoteDataSource.getLaporanAbsensi(
        tanggalAwal: tanggalAwal,
        tanggalAkhir: tanggalAkhir,
      );
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, bool>> postLaporanPegawai(LaporanPegawaiEntity payload) {
    return executeSafeApiCall<bool>(() async {
      // 1. Mapping dari Entity (Domain) kembali menjadi Model (Data)
      final modelPayload = payload.toModel();
      
      // 2. Teruskan payload model ke Remote Data Source
      return await _remoteDataSource.postLaporanPegawai(modelPayload);
    });
  }
}