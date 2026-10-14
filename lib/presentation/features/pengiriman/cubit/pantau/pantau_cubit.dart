import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../domain/usecases/pengiriman/pengiriman_usecase.dart';
import '../../logic/pantau_logic.dart';
import 'pantau_state.dart';

/// Pantau berkas milik NIP login: daftar langsung tampil, filter & cari lokal.
@injectable
class PantauCubit extends Cubit<PantauState> {
  final PengirimanUseCase _useCase;
  PantauCubit(this._useCase) : super(const PantauState());

  Future<void> load() async {
    // Refresh tetap menampilkan daftar lama sampai yang baru datang.
    if (state.semua.isEmpty) {
      emit(state.copyWith(status: PantauStatus.loading));
    }
    final result = await _useCase.getDaftar();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(status: PantauStatus.failure, error: failure.message),
      ),
      (hasil) => emit(
        state.copyWith(
          status: PantauStatus.loaded,
          semua: hasil.data,
          tglCache: hasil.tglCache,
          aturCache: true,
        ),
      ),
    );
  }

  void changeFilter(PantauFilter filter) {
    if (filter != state.filter) emit(state.copyWith(filter: filter));
  }

  void search(String query) {
    final q = query.trim();
    if (q != state.query) emit(state.copyWith(query: q));
  }
}
