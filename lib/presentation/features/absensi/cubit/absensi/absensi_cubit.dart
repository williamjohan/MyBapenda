import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../domain/entities/absensi/ringkasan_absensi_entity.dart';
import '../../../../../domain/usecases/absensi/absensi_usecase.dart';
import 'absensi_state.dart';

const int _pageSize = 20;

/// Ringkasan hari ini + riwayat scan (infinite scroll).
@injectable
class AbsensiCubit extends Cubit<AbsensiState> {
  final AbsensiUseCase _useCase;
  AbsensiCubit(this._useCase) : super(const AbsensiState());

  Future<void> load() async {
    await Future.wait([loadRingkasan(), _loadFirstPage()]);
  }

  Future<void> loadRingkasan() async {
    emit(state.copyWith(ringkasanStatus: AbsensiLoadStatus.loading));
    final result = await _useCase.getRingkasan();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          ringkasanStatus: AbsensiLoadStatus.failure,
          ringkasanError: failure.message,
        ),
      ),
      (ringkasan) => emit(
        state.copyWith(
          ringkasanStatus: AbsensiLoadStatus.loaded,
          ringkasan: ringkasan,
        ),
      ),
    );
  }

  Future<void> _loadFirstPage() async {
    emit(state.copyWith(riwayatStatus: AbsensiLoadStatus.loading));
    final result = await _useCase.getRiwayat(page: 1, pageSize: _pageSize);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          riwayatStatus: AbsensiLoadStatus.failure,
          riwayatError: failure.message,
        ),
      ),
      (pageResult) => emit(
        state.copyWith(
          riwayatStatus: AbsensiLoadStatus.loaded,
          riwayat: pageResult.items,
          page: 1,
          hasMore: pageResult.hasMore,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.riwayatStatus != AbsensiLoadStatus.loaded ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));
    final nextPage = state.page + 1;
    final result = await _useCase.getRiwayat(
      page: nextPage,
      pageSize: _pageSize,
    );
    if (isClosed) return;
    result.fold(
      (_) => emit(state.copyWith(isLoadingMore: false)),
      (pageResult) => emit(
        state.copyWith(
          riwayat: [...state.riwayat, ...pageResult.items],
          page: nextPage,
          hasMore: pageResult.hasMore,
          isLoadingMore: false,
        ),
      ),
    );
  }

  /// Setelah absen sukses: pakai ringkasan dari respons absen (sudah dihitung
  /// ulang server) lalu muat ulang riwayat dari halaman pertama.
  Future<void> onAbsenRecorded(RingkasanAbsensiEntity ringkasan) async {
    emit(
      state.copyWith(
        ringkasanStatus: AbsensiLoadStatus.loaded,
        ringkasan: ringkasan,
      ),
    );
    await _loadFirstPage();
  }
}
