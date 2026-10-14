import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../domain/usecases/pengiriman/pengiriman_usecase.dart';
import '../../logic/tugas_tab_logic.dart';
import 'daftar_tugas_state.dart';

/// Daftar tugas petugas. Server mengirim semua tugas sekaligus (tanpa paging),
/// jadi tab dan pencarian difilter lokal.
@injectable
class DaftarTugasCubit extends Cubit<DaftarTugasState> {
  final PengirimanUseCase _useCase;
  DaftarTugasCubit(this._useCase) : super(const DaftarTugasState());

  Future<void> load() async {
    // Muat ulang tidak mengosongkan daftar lama (tetap terlihat saat refresh).
    if (state.semua.isEmpty) {
      emit(state.copyWith(status: DaftarTugasStatus.loading));
    }
    final result = await _useCase.getDaftar();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DaftarTugasStatus.failure,
          error: failure.message,
        ),
      ),
      (hasil) => emit(
        state.copyWith(
          status: DaftarTugasStatus.loaded,
          semua: hasil.data,
          tglCache: hasil.tglCache,
          aturCache: true,
        ),
      ),
    );
  }

  void changeTab(TabTugas tab) {
    if (tab != state.tab) emit(state.copyWith(tab: tab));
  }

  void search(String query) {
    final q = query.trim();
    if (q != state.query) emit(state.copyWith(query: q));
  }
}
