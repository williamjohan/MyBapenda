import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../../../../domain/entities/pengiriman/lacak_entity.dart';
import '../../../../../domain/usecases/pengiriman/pengiriman_usecase.dart';
import 'lacak_state.dart';

/// Pantau berkas lewat `GET lacak?kode=` (no resi atau isi QR mentah),
/// lalu rute jalan antar titik perjalanannya untuk peta.
@injectable
class LacakCubit extends Cubit<LacakState> {
  final PengirimanUseCase _useCase;
  LacakCubit(this._useCase) : super(const LacakState());

  /// Naik tiap pencarian, agar respons lama tidak menimpa hasil terbaru.
  int _requestId = 0;

  Future<void> lacak(String kode) async {
    final k = kode.trim();
    if (k.isEmpty) return;

    final reqId = ++_requestId;
    // Pencarian kode baru mengosongkan hasil lama; refresh kode sama tidak.
    emit(
      k == state.kode && state.result != null
          ? state.copyWith(status: LacakStatus.loading)
          : LacakState(status: LacakStatus.loading, kode: k),
    );
    final result = await _useCase.getLacak(k);
    if (isClosed || reqId != _requestId) return;
    LacakResultEntity? data;
    result.fold(
      (failure) => emit(
        state.copyWith(status: LacakStatus.failure, error: failure.message),
      ),
      (d) {
        data = d;
        emit(state.copyWith(status: LacakStatus.loaded, result: d));
      },
    );
    if (data != null) await _muatRute(data!, reqId);
  }

  /// Rute jalan untuk peta. Gagal (mis. Routes API belum aktif) cukup
  /// dicatat: peta tetap menampilkan titik-titiknya.
  Future<void> _muatRute(LacakResultEntity data, int reqId) async {
    final titik = data.titikRute;
    if (titik.length < 2) return;
    final result = await _useCase.getRute(titik);
    if (isClosed || reqId != _requestId) return;
    result.fold(
      (f) => AppLogger.warning(
        '[Pengiriman] rute peta tidak tersedia: ${f.message}',
      ),
      (rute) {
        if (rute.length >= 2) emit(state.copyWith(rute: rute));
      },
    );
  }

  Future<void> refresh() => lacak(state.kode);
}
