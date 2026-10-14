import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/services/geo_location_service.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../domain/entities/pengiriman/antrean_entity.dart';
import '../../../../../domain/entities/pengiriman/master_pengiriman_entity.dart';
import '../../../../../domain/entities/pengiriman/pengiriman_payload_entity.dart';
import '../../../../../domain/usecases/pengiriman/pengiriman_usecase.dart';
import '../../logic/aksi_validasi.dart';
import '../../utils/pengiriman_foto.dart';
import 'aksi_state.dart';

/// Form aksi petugas (ambil, perjalanan, tiba, serah, gagal, kembalikan):
/// lokasi GPS, foto bercap, lalu kirim. Satu instance per halaman.
@injectable
class AksiCubit extends Cubit<AksiState> {
  final PengirimanUseCase _useCase;
  final GeoLocationService _lokasiService;

  AksiCubit(this._useCase, this._lokasiService) : super(const AksiState());

  Future<void> init({bool butuhMaster = false}) async {
    await Future.wait([cariLokasi(), if (butuhMaster) muatMaster()]);
  }

  Future<void> muatMaster() async {
    final result = await _useCase.getMaster();
    if (isClosed) return;
    result.fold(
      (_) => emit(state.copyWith(masterGagal: true)),
      (master) => emit(state.copyWith(master: master, masterGagal: false)),
    );
  }

  Future<void> cariLokasi() async {
    emit(state.copyWith(lokasiStatus: LokasiStatus.mencari));
    try {
      final p = await _lokasiService.getCurrentPosition();
      if (isClosed) return;
      if (p.isMocked) {
        emit(
          state.copyWith(
            lokasiStatus: LokasiStatus.gagal,
            lokasiError:
                'Terdeteksi lokasi palsu (Fake GPS). Matikan aplikasi '
                'mock location lalu coba lagi.',
          ),
        );
        return;
      }
      emit(state.copyWith(lokasiStatus: LokasiStatus.siap, lokasi: p));
    } on GeoLocationException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          lokasiStatus: LokasiStatus.gagal,
          lokasiError: switch (e.error) {
            GeoLocationError.serviceDisabled => 'GPS HP mati. Nyalakan GPS.',
            GeoLocationError.permissionDenied => 'Izin lokasi dibutuhkan.',
            GeoLocationError.permissionDeniedForever =>
              'Izin lokasi ditolak. Aktifkan dari pengaturan aplikasi.',
            GeoLocationError.timeout =>
              'Sinyal GPS lemah. Coba di area yang lebih terbuka.',
          },
          lokasiErrorKode: e.error,
        ),
      );
    }
  }

  Future<void> bukaPengaturanLokasi() async {
    switch (state.lokasiErrorKode) {
      case GeoLocationError.serviceDisabled:
        await _lokasiService.openLocationSettings();
      case GeoLocationError.permissionDeniedForever:
        await _lokasiService.openAppSettings();
      default:
        break;
    }
  }

  Future<void> ambilFoto(FotoSlot slot, {required String noResi}) async {
    if (state.fotoDiproses != null) return;
    emit(state.copyWith(fotoDiproses: slot));
    try {
      final path = await PengirimanFoto.ambil(
        judul: slot.label,
        noResi: noResi,
        lokasi: state.lokasi,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          hapusFotoDiproses: true,
          foto: path == null ? null : {...state.foto, slot: path},
        ),
      );
    } catch (e, st) {
      AppLogger.error('[Pengiriman] gagal memproses foto', e, st);
      if (isClosed) return;
      emit(
        state.copyWith(
          hapusFotoDiproses: true,
          error: 'Gagal memproses foto. Coba ambil ulang.',
        ),
      );
    }
  }

  void hapusFoto(FotoSlot slot) =>
      emit(state.copyWith(foto: {...state.foto}..remove(slot)));

  /// Pesan galat ringan (validasi form) tanpa mengubah status kirim.
  /// Dikosongkan dulu supaya pesan yang sama tetap memicu snackbar lagi.
  void tampilkanError(String pesan) {
    emit(state.copyWith());
    emit(state.copyWith(error: pesan));
  }

  // ---------------------------------------------------------------------------
  // Kirim
  // ---------------------------------------------------------------------------

  /// Ambil selalu online: hasil per berkas langsung ditampilkan.
  Future<void> kirimAmbil(List<String> noResiList) => _kirim(
    (c) => _useCase.postAmbil(
      AmbilPayloadEntity(
        noResiList: noResiList,
        fotoAmbilPath: state.foto[FotoSlot.ambil]!,
        checkin: c,
      ),
    ),
    (hasil) => state.copyWith(kirim: KirimStatus.sukses, hasil: hasil),
  );

  Future<void> kirimCheckin(
    JenisCheckin jenis,
    String noResi, {
    String? keterangan,
  }) => _antre(
    (c) => _useCase.antreCheckin(
      CheckinPayloadEntity(jenis: jenis, noResi: noResi, checkin: c),
    ),
    keterangan: keterangan,
  );

  Future<void> kirimSerah({
    required String noResi,
    required CaraSerah cara,
    String? namaPenerima,
    int? idHubungan,
    String? fotoTtdPath,
    String? keterangan,
  }) => _antre(
    (c) => _useCase.antreSerah(
      SerahPayloadEntity(
        noResi: noResi,
        caraSerah: cara,
        namaPenerima: cara.butuhPenerima ? namaPenerima : null,
        idHubungan: cara.butuhPenerima ? idHubungan : null,
        fotoSerahPath: cara.butuhPenerima ? state.foto[FotoSlot.serah] : null,
        fotoTtdPath: cara.butuhPenerima ? fotoTtdPath : null,
        fotoTempelPath: cara.butuhPenerima ? null : state.foto[FotoSlot.tempel],
        fotoObjekPath: state.foto[FotoSlot.objek],
        checkin: c,
      ),
    ),
    keterangan: keterangan,
  );

  Future<void> kirimGagal({
    required String noResi,
    required int idAlasan,
    String? keterangan,
  }) => _antre(
    (c) => _useCase.antreGagal(
      GagalPayloadEntity(
        noResi: noResi,
        idAlasan: idAlasan,
        fotoGagalPath: state.foto[FotoSlot.gagal]!,
        checkin: c,
      ),
    ),
    keterangan: keterangan,
  );

  Future<void> kirimKembalikan(List<String> noResiList) => _antre(
    (c) => _useCase.antreKembalikan(
      KembalikanPayloadEntity(noResiList: noResiList, checkin: c),
    ),
  );

  /// Simpan ke antrean offline; terkirim otomatis (lihat repository).
  Future<void> _antre(
    Future<Either<Failure, AntreanPengirimanEntity>> Function(
      CheckinPengirimanEntity checkin,
    )
    simpan, {
    String? keterangan,
  }) => _kirim(
    simpan,
    (antrean) => state.copyWith(kirim: KirimStatus.sukses, antrean: antrean),
    keterangan: keterangan,
  );

  Future<void> _kirim<T>(
    Future<Either<Failure, T>> Function(CheckinPengirimanEntity checkin) post,
    AksiState Function(T data) sukses, {
    String? keterangan,
  }) async {
    if (state.kirim == KirimStatus.mengirim) return;
    final p = state.lokasi;
    if (!state.lokasiSiap || p == null) {
      emit(state.copyWith(error: 'Lokasi belum didapat. Tunggu GPS siap.'));
      return;
    }

    emit(state.copyWith(kirim: KirimStatus.mengirim));
    final checkin = CheckinPengirimanEntity(
      checkinUuid: const Uuid().v4(),
      tglCheckin: DateTime.now(),
      latitude: p.latitude,
      longitude: p.longitude,
      akurasi: p.akurasiMeter,
      isMockLocation: p.isMocked,
      keterangan: keterangan,
      fotoLokasiPath: state.foto[FotoSlot.lokasi],
    );
    final result = await post(checkin);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(kirim: KirimStatus.gagal, error: failure.message),
      ),
      (data) => emit(sukses(data)),
    );
  }
}
