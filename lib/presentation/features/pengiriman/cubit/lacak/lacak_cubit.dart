import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../domain/usecases/pengiriman/pengiriman_usecase.dart';
import 'lacak_state.dart';

/// Pantau berkas lewat `GET lacak?kode=` (no resi atau isi QR mentah).
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
    result.fold(
      (failure) => emit(
        state.copyWith(status: LacakStatus.failure, error: failure.message),
      ),
      (data) => emit(state.copyWith(status: LacakStatus.loaded, result: data)),
    );
  }

  Future<void> refresh() => lacak(state.kode);
}
