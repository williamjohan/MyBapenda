import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/exception.dart';
import '../../../core/errors/failure.dart';
import '../../../core/network/dio_error_handler.dart';
import '../../../core/network/safe_api_call.dart';
import '../../../core/storage/app_secure_storage.dart';
import '../../../core/storage/pengiriman_cache_storage.dart';
import '../../../core/storage/pengiriman_queue_storage.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/pengiriman/antrean_entity.dart';
import '../../../domain/entities/pengiriman/berkas_entity.dart';
import '../../../domain/entities/pengiriman/lacak_entity.dart';
import '../../../domain/entities/pengiriman/master_pengiriman_entity.dart';
import '../../../domain/entities/pengiriman/pengiriman_payload_entity.dart';
import '../../../domain/repositories/pengiriman/i_pengiriman_repository.dart';
import '../../datasources/pengiriman/pengiriman_remote_datasource.dart';
import '../../datasources/pengiriman/rute_remote_datasource.dart';
import '../../models/pengiriman/berkas_model.dart';
import '../../models/pengiriman/lacak_model.dart';
import '../../models/pengiriman/master_pengiriman_model.dart';
import '../../models/pengiriman/pengiriman_payload_model.dart';
import '../../models/pengiriman/rute_model.dart';
import 'pengiriman_antrean_overlay.dart';

@LazySingleton(as: IPengirimanRepository)
class PengirimanRepositoryImpl implements IPengirimanRepository {
  final IPengirimanRemoteDataSource _remoteDataSource;
  final PengirimanQueueStorage _queue;
  final PengirimanCacheStorage _cache;
  final AppSecureStorage _secureStorage;
  final IRuteRemoteDataSource _ruteDataSource;

  PengirimanRepositoryImpl(
    this._remoteDataSource,
    this._queue,
    this._cache,
    this._secureStorage,
    this._ruteDataSource,
  );

  final _perubahan = StreamController<RingkasanAntreanEntity>.broadcast();

  /// Kunci supaya dua proses kirim antrean tidak berjalan bersamaan.
  bool _sinkronJalan = false;

  /// Antrean & cache disimpan per NIP login.
  Future<String> _nip() async =>
      (await _secureStorage.getCurrentNip())?.trim().nonEmpty ?? 'anon';

  // ---------------------------------------------------------------------------
  // Baca (dengan cache offline + tampilan sementara antrean)
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, MasterPengirimanEntity>> getMaster() {
    return executeSafeApiCall<MasterPengirimanEntity>(() async {
      final model = await _remoteDataSource.getMaster();
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, HasilBacaEntity<List<BerkasEntity>>>>
  getDaftar() async {
    final nip = await _nip();
    final result = await executeSafeApiCall(() async {
      final models = await _remoteDataSource.getDaftar();
      await _cache.simpanDaftar(nip, models.map((m) => m.toJson()).toList());
      return HasilBacaEntity(models.map((m) => m.toEntity()).toList());
    });
    final hasil = result
        .fold<Either<Failure, HasilBacaEntity<List<BerkasEntity>>>>((failure) {
          final c = _bolehCache(failure) ? _cache.bacaDaftar(nip) : null;
          if (c == null) return Left(failure);
          return Right(
            HasilBacaEntity(
              c.data.map((j) => BerkasModel.fromJson(j).toEntity()).toList(),
              tglCache: c.tgl,
            ),
          );
        }, (h) => Right(h));
    final menunggu = _menunggu(nip);
    return hasil.map(
      (h) => HasilBacaEntity([
        for (final b in h.data) PengirimanAntreanOverlay.berkas(b, menunggu),
      ], tglCache: h.tglCache),
    );
  }

  @override
  Future<Either<Failure, HasilBacaEntity<BerkasDetailEntity>>> getDetail(
    String noResi,
  ) async {
    final nip = await _nip();
    final result = await executeSafeApiCall(() async {
      final model = await _remoteDataSource.getDetail(noResi);
      // BerkasDetailModel.toJson tidak memuat field berkas (rata di induk).
      await _cache.simpanDetail(nip, noResi, {
        ...model.berkas.toJson(),
        ...model.toJson(),
      });
      return HasilBacaEntity(model.toEntity());
    });
    final hasil = result
        .fold<Either<Failure, HasilBacaEntity<BerkasDetailEntity>>>((failure) {
          final c = _bolehCache(failure)
              ? _cache.bacaDetail(nip, noResi)
              : null;
          if (c == null) return Left(failure);
          return Right(
            HasilBacaEntity(
              BerkasDetailModel.fromJson(c.data).toEntity(),
              tglCache: c.tgl,
            ),
          );
        }, (h) => Right(h));
    final menunggu = _menunggu(nip);
    return hasil.map(
      (h) => HasilBacaEntity(
        PengirimanAntreanOverlay.detail(h.data, menunggu),
        tglCache: h.tglCache,
      ),
    );
  }

  /// Cache hanya dipakai bila gagal karena jaringan, bukan ditolak server.
  static bool _bolehCache(Failure f) =>
      f is NoInternetFailure || f is TimeoutFailure;

  @override
  Future<Either<Failure, LacakResultEntity>> getLacak(String kode) {
    return executeSafeApiCall<LacakResultEntity>(() async {
      final model = await _remoteDataSource.getLacak(kode);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, List<TitikRute>>> getRute(List<TitikRute> titik) {
    return executeSafeApiCall<List<TitikRute>>(() async {
      final model = await _ruteDataSource.hitungRute(titik);
      return model.toEntity();
    });
  }

  // ---------------------------------------------------------------------------
  // Tulis
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, List<HasilCheckinEntity>>> postAmbil(
    AmbilPayloadEntity payload,
  ) {
    return executeSafeApiCall<List<HasilCheckinEntity>>(() async {
      final models = await _remoteDataSource.postAmbil(
        await payload.toFormData(),
      );
      return models.map((e) => e.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, AntreanPengirimanEntity>> antreCheckin(
    CheckinPayloadEntity payload,
  ) => _antre(payload.toRecord());

  @override
  Future<Either<Failure, AntreanPengirimanEntity>> antreSerah(
    SerahPayloadEntity payload,
  ) => _antre(payload.toRecord());

  @override
  Future<Either<Failure, AntreanPengirimanEntity>> antreGagal(
    GagalPayloadEntity payload,
  ) => _antre(payload.toRecord());

  @override
  Future<Either<Failure, AntreanPengirimanEntity>> antreKembalikan(
    KembalikanPayloadEntity payload,
  ) => _antre(payload.toRecord());

  /// Simpan ke antrean lalu langsung coba kirim (tanpa ditunggu).
  Future<Either<Failure, AntreanPengirimanEntity>> _antre(
    AntreanRecord record,
  ) async {
    try {
      final nip = await _nip();
      final disimpan = await _queue.tambah(nip, record);
      await _beritahu(nip);
      unawaited(sinkronkan());
      return Right(disimpan.toEntity());
    } catch (e, st) {
      AppLogger.error('[Antrean] gagal menyimpan ke antrean', e, st);
      return const Left(
        CacheFailure('Gagal menyimpan data di HP. Coba ambil foto ulang.'),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Antrean offline
  // ---------------------------------------------------------------------------

  List<AntreanPengirimanEntity> _menunggu(String nip) =>
      _queue.menunggu(nip).map((r) => r.toEntity()).toList();

  @override
  Stream<RingkasanAntreanEntity> get perubahanAntrean => _perubahan.stream;

  @override
  Future<RingkasanAntreanEntity> bacaAntrean() async {
    final nip = await _nip();
    return RingkasanAntreanEntity(
      menunggu: _menunggu(nip),
      gagal: _queue.gagal(nip).map((r) => r.toEntity()).toList(),
    );
  }

  Future<void> _beritahu(String nip) async {
    if (_perubahan.hasListener) _perubahan.add(await bacaAntrean());
  }

  @override
  Future<void> hapusGagal(String checkinUuid) async {
    final nip = await _nip();
    await _queue.hapusGagal(nip, checkinUuid);
    await _beritahu(nip);
  }

  /// Kirim antrean berurutan (FIFO). Berhenti di galat sementara (offline,
  /// timeout, 5xx) supaya urutan per berkas tetap terjaga; dicoba lagi pada
  /// pemicu berikutnya.
  @override
  Future<void> sinkronkan() async {
    if (_sinkronJalan) return;
    _sinkronJalan = true;
    try {
      final nip = await _nip();
      while (true) {
        final antre = _queue.menunggu(nip);
        if (antre.isEmpty) break;
        final rec = antre.first;

        try {
          final hasil = await _remoteDataSource.postForm(
            rec.endpoint,
            await rec.toFormData(),
          );
          final diabaikan = hasil.where((h) => h.diabaikan).toList();
          if (diabaikan.isEmpty) {
            await _queue.selesai(nip, rec.checkinUuid);
          } else {
            await _queue.pindahKeGagal(
              nip,
              rec.copyWith(
                diabaikan: true,
                pesanError: diabaikan
                    .map((h) => h.pesan?.trim())
                    .whereType<String>()
                    .where((p) => p.isNotEmpty)
                    .join('; ')
                    .nonEmpty,
              ),
            );
          }
          await _beritahu(nip);
        } catch (e) {
          final k = klasifikasiGagalKirim(e);
          AppLogger.warning(
            '[Antrean] ${rec.jenis} ${rec.noResi.join(',')} '
            '${k.permanen ? 'ditolak' : 'tertunda'}: ${k.pesan}',
          );
          if (k.permanen) {
            await _queue.pindahKeGagal(nip, rec.copyWith(pesanError: k.pesan));
            await _beritahu(nip);
            continue;
          }
          await _queue.perbarui(
            nip,
            rec.copyWith(jmlCoba: rec.jmlCoba + 1, pesanError: k.pesan),
          );
          await _beritahu(nip);
          break;
        }
      }
    } finally {
      _sinkronJalan = false;
    }
  }
}

/// Galat kirim antrean:
/// - permanen (dibuang ke daftar gagal): ditolak bisnis (`isSuccess=false`),
///   HTTP 4xx selain 401/408/429, atau foto antrean hilang;
/// - sementara (dicoba lagi): offline, timeout, 5xx, 401, lainnya.
({bool permanen, String pesan}) klasifikasiGagalKirim(Object e) {
  if (e is DioException) {
    final app = DioErrorHandler.handle(e);
    final kode = e.response?.statusCode;
    final permanen =
        app is ServerException &&
        kode != null &&
        kode >= 400 &&
        kode < 500 &&
        !const {401, 408, 429}.contains(kode);
    return (permanen: permanen, pesan: app.message);
  }
  if (e is ServerException) return (permanen: true, pesan: e.message);
  if (e is FileSystemException) {
    return (permanen: true, pesan: 'Foto antrean tidak ditemukan di HP.');
  }
  if (e is AppException) return (permanen: false, pesan: e.message);
  return (permanen: false, pesan: 'Gagal mengirim, akan dicoba lagi.');
}

extension on String {
  String? get nonEmpty => isEmpty ? null : this;
}
