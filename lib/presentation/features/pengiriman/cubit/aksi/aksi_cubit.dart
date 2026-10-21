import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/errors/failure.dart';
// 🚀 REFACTOR: Gunakan IGeoLocationService dan IPermissionService terbaru
import '../../../../../core/services/geo_location/i_geo_location_service.dart';
import '../../../../../core/services/permission/i_permission_service.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../domain/entities/pengiriman/antrean_entity.dart';
import '../../../../../domain/entities/pengiriman/master_pengiriman_entity.dart';
import '../../../../../domain/entities/pengiriman/pengiriman_payload_entity.dart';
import '../../../../../domain/usecases/pengiriman/pengiriman_usecase.dart';
import '../../utils/pengiriman_foto.dart';
import 'aksi_state.dart';

/// Form aksi petugas (ambil, perjalanan, tiba, serah, gagal, kembalikan):
/// lokasi GPS, foto bercap, lalu kirim. Satu instance per halaman.
@injectable
class AksiCubit extends Cubit<AksiState> {
  final PengirimanUseCase _useCase;
  final IGeoLocationService _lokasiService; 
  final IPermissionService _permissionService; 
  final PengirimanFoto _foto;

  AksiCubit(
    this._useCase,
    this._lokasiService,
    this._permissionService,
    this._foto,
  ) : super(const AksiState());

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
    
    final locationResult = await _lokasiService.getCurrentPosition();
    if (isClosed) return;

    locationResult.fold(
      (failure) {
        // Jika gagal karena masalah izin (GPS mati/Ditolak), flag = true
        final isPermissionIssue = failure is PermissionFailure;
        
        emit(
          state.copyWith(
            lokasiStatus: LokasiStatus.gagal,
            lokasiError: failure.message,
            requiresLocationSettings: isPermissionIssue,
          ),
        );
      },
      (position) {
        // Sukses (Sudah lolos filter anti-mock dari Service)
        emit(
          state.copyWith(
            lokasiStatus: LokasiStatus.siap,
            lokasi: position,
            requiresLocationSettings: false, // Reset flag
          ),
        );
      },
    );
  }

  Future<void> bukaPengaturanLokasi() async {
    await _permissionService.openSettings();
  }

  Future<void> ambilFoto(FotoSlot slot, {required String noResi}) async {
    if (state.fotoDiproses != null) return;
    emit(state.copyWith(fotoDiproses: slot));
    try {
      final path = await _foto.ambil(
        judul: slot.label,
        noResi: noResi,
        // 🚀 GeoPosition masih utuh karena kita menggunakan typedef yang persis sama
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

  void tampilkanError(String pesan) {
    emit(state.copyWith());
    emit(state.copyWith(error: pesan));
  }

  // ---------------------------------------------------------------------------
  // Kirim (TIDAK ADA LOGIKA BISNIS YANG BERUBAH)
  // ---------------------------------------------------------------------------

  bool _lolos(String? error) {
    if (error == null) return true;
    tampilkanError(error);
    return false;
  }

  Set<FotoSlot> get _fotoAda => state.foto.keys.toSet();

  bool cekSerah({
    required CaraSerah? cara,
    required String namaPenerima,
    required int? idHubungan,
    required bool adaTtd,
    required bool wajibFotoObjek,
  }) => _lolos(
    _useCase.validasiSerah(
      cara: cara,
      namaPenerima: namaPenerima,
      idHubungan: idHubungan,
      adaTtd: adaTtd,
      wajibFotoObjek: wajibFotoObjek,
      foto: _fotoAda,
    ),
  );

  Future<void> kirimAmbil(List<String> noResiList) async {
    final error = _useCase.validasiAmbil(
      jumlahResi: noResiList.length,
      foto: _fotoAda,
    );
    if (!_lolos(error)) return;
    return _kirimAmbil(noResiList);
  }

  Future<void> _kirimAmbil(List<String> noResiList) => _kirim(
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
  }) async {
    if (jenis == JenisCheckin.tiba &&
        !_lolos(_useCase.validasiTiba(_fotoAda))) {
      return;
    }
    return _antreCheckin(jenis, noResi, keterangan: keterangan);
  }

  Future<void> _antreCheckin(
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
    required OpsiMasterEntity? alasan,
    String keterangan = '',
  }) async {
    final error = _useCase.validasiGagal(
      alasan: alasan,
      keterangan: keterangan,
      foto: _fotoAda,
    );
    if (!_lolos(error)) return;
    return _antreGagal(noResi, alasan!.id, keterangan);
  }

  Future<void> _antreGagal(String noResi, int idAlasan, String keterangan) =>
      _antre(
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

  Future<void> kirimKembalikan(List<String> noResiList) async {
    final error = _useCase.validasiKembalikan(jumlahResi: noResiList.length);
    if (!_lolos(error)) return;
    return _antreKembalikan(noResiList);
  }

  Future<void> _antreKembalikan(List<String> noResiList) => _antre(
    (c) => _useCase.antreKembalikan(
      KembalikanPayloadEntity(noResiList: noResiList, checkin: c),
    ),
  );

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
      
      // 🚀 REFACTOR: Fix Mock Location. Karena filter anti-mock ditarik ke Service, 
      // yang lolos sampai ke sini dipastikan false.
      isMockLocation: false, 
      
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