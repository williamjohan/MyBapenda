import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/core/network/safe_api_call.dart';
import 'package:bapendacore/presentation/shared/master_data/data/datasources/master_local_datasource.dart';
import 'package:bapendacore/presentation/shared/master_data/data/datasources/master_remote_datasource.dart';
import 'package:bapendacore/presentation/shared/master_data/data/models/master_option_model.dart';
import 'package:bapendacore/presentation/shared/master_data/data/models/paged_master_data_model.dart';
import 'package:bapendacore/presentation/shared/master_data/domain/entities/master_option_type.dart';
import 'package:bapendacore/presentation/shared/master_data/domain/entities/paged_master_entities.dart';
import 'package:bapendacore/presentation/shared/master_data/domain/repositories/i_master_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IMasterRepository)
class MasterRepositoryImpl implements IMasterRepository {
  static const Duration _ttl = Duration(hours: 24);

  final IMasterRemoteDataSource _remote;
  final IMasterLocalDataSource _local;

  MasterRepositoryImpl(this._remote, this._local);

  final Map<String, Map<String, String>> _memory = {};
  final Map<String, Future<Either<Failure, Map<String, String>>>> _inFlight =
      {};

  PagedResultEntity<JalanEntity>? _jalanDefaultPage;
  int? _jalanDefaultPageSize;
  PagedResultEntity<PegawaiSurveyEntity>? _pegawaiDefaultPage;
  int? _pegawaiDefaultPageSize;

  // ===========================================================================
  // OPTIONS & KELURAHAN (cache memori + disk, TTL)
  // ===========================================================================

  @override
  Future<Either<Failure, Map<String, String>>> getOptions(
    MasterOptionType type, {
    bool forceRefresh = false,
  }) => _get(
    key: 'opt_${type.name}',
    forceRefresh: forceRefresh,
    readLocal: () => _local.readOptions(type),
    saveLocal: (items) => _local.saveOptions(type, items),
    fetchRemote: () => _remote.getOptions(type),
  );

  @override
  Future<Either<Failure, Map<String, String>>> getKelurahan(
    String kecamatanId, {
    bool forceRefresh = false,
  }) => _get(
    key: 'kel_$kecamatanId',
    forceRefresh: forceRefresh,
    readLocal: () => _local.readKelurahan(kecamatanId),
    saveLocal: (items) => _local.saveKelurahan(kecamatanId, items),
    fetchRemote: () => _remote.getKelurahan(kecamatanId),
  );

  Future<Either<Failure, Map<String, String>>> _get({
    required String key,
    required bool forceRefresh,
    required CachedOptions? Function() readLocal,
    required Future<void> Function(List<MasterOptionModel>) saveLocal,
    required Future<List<MasterOptionModel>> Function() fetchRemote,
  }) {
    final memory = _memory[key];
    if (!forceRefresh && memory != null) return Future.value(Right(memory));

    return _inFlight[key] ??=
        _load(
          key: key,
          force: forceRefresh,
          readLocal: readLocal,
          saveLocal: saveLocal,
          fetchRemote: fetchRemote,
        ).whenComplete(() {
          _inFlight.remove(key);
        });
  }

  Future<Either<Failure, Map<String, String>>> _load({
    required String key,
    required bool force,
    required CachedOptions? Function() readLocal,
    required Future<void> Function(List<MasterOptionModel>) saveLocal,
    required Future<List<MasterOptionModel>> Function() fetchRemote,
  }) {
    return executeSafeApiCall<Map<String, String>>(() async {
      final cached = readLocal();
      final isFresh =
          cached != null && DateTime.now().difference(cached.savedAt) < _ttl;

      if (!force && isFresh) {
        final map = cached.items.toOptionMap();
        _memory[key] = map;
        return map;
      }

      try {
        final items = await fetchRemote();
        final map = items.toOptionMap();
        if (map.isNotEmpty) {
          await saveLocal(items);
          _memory[key] = map;
        }
        return map;
      } catch (_) {
        if (cached != null) {
          final map = cached.items.toOptionMap();
          _memory[key] = map;
          return map;
        }
        rethrow;
      }
    });
  }

  // ===========================================================================
  // YANG BERHALAMAN (dicari ke server)
  // ===========================================================================

  @override
  Future<Either<Failure, PagedResultEntity<JalanEntity>>> searchJalan({
    required String keyword,
    required int page,
    required int pageSize,
  }) {
    final isDefault = keyword.isEmpty && page == 1;
    final cached = _jalanDefaultPage;
    if (isDefault && cached != null && _jalanDefaultPageSize == pageSize) {
      return Future.value(Right(cached));
    }

    return executeSafeApiCall<PagedResultEntity<JalanEntity>>(() async {
      final model = await _remote.getJalan(
        keyword: keyword,
        page: page,
        pageSize: pageSize,
      );
      final entity = model.toEntity((e) => e.toEntity());

      if (isDefault && entity.items.isNotEmpty) {
        _jalanDefaultPage = entity;
        _jalanDefaultPageSize = pageSize;
      }
      return entity;
    });
  }

  @override
  Future<Either<Failure, PagedResultEntity<PersilEntity>>> searchPersil({
    required String keyword,
    required int page,
    required int pageSize,
  }) {
    return executeSafeApiCall<PagedResultEntity<PersilEntity>>(() async {
      final model = await _remote.getPersil(
        keyword: keyword,
        page: page,
        pageSize: pageSize,
      );
      return model.toEntity((e) => e.toEntity());
    });
  }

  @override
  Future<Either<Failure, PagedResultEntity<PegawaiSurveyEntity>>>
  searchPegawaiSurvey({
    required String keyword,
    required int page,
    required int pageSize,
  }) {
    final isDefault = keyword.isEmpty && page == 1;
    final cached = _pegawaiDefaultPage;
    if (isDefault && cached != null && _pegawaiDefaultPageSize == pageSize) {
      return Future.value(Right(cached));
    }

    return executeSafeApiCall<PagedResultEntity<PegawaiSurveyEntity>>(() async {
      final model = await _remote.getPegawaiSurvey(
        keyword: keyword,
        page: page,
        pageSize: pageSize,
      );
      final entity = model.toEntity((e) => e.toEntity());

      // Hanya simpan kalau berhasil dan ada isinya.
      if (isDefault && entity.items.isNotEmpty) {
        _pegawaiDefaultPage = entity;
        _pegawaiDefaultPageSize = pageSize;
      }
      return entity;
    });
  }

  // ===========================================================================
  // CACHE
  // ===========================================================================

  @override
  Future<void> clearCache() async {
    _memory.clear();
    _jalanDefaultPage = null;
    _jalanDefaultPageSize = null;
    _pegawaiDefaultPage = null;
    _pegawaiDefaultPageSize = null;
    await _local.clear();
  }
}
