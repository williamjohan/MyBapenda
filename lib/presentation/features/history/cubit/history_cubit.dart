import 'package:bapendacore/domain/entities/history/history_entity.dart';
import 'package:bapendacore/domain/usecases/history/history_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'history_state.dart';

const int _pageSize = 20;

@injectable
class HistoryCubit extends Cubit<HistoryState> {
  final HistoryUseCase _useCase;
  HistoryCubit(this._useCase) : super(const HistoryInitial());

  Future<void> loadHistory({
    DateTime? tanggalAwal,
    DateTime? tanggalAkhir,
  }) async {
    final now = DateTime.now();
    final awal = tanggalAwal ?? DateTime(now.year, now.month, 1);
    final akhir = tanggalAkhir ?? now;

    emit(const HistoryLoading());
    try {
      final result = await _useCase.getHistory(
        tanggalAwal: awal,
        tanggalAkhir: akhir,
        startData: 0,
        jmlData: _pageSize,
      );
      emit(
        HistoryLoaded(
          items: result.items,
          filtered: result.items,
          tanggalAwal: awal,
          tanggalAkhir: akhir,
          hasMore: result.hasMore,
        ),
      );
    } catch (e) {
      emit(HistoryError(_mapError(e)));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! HistoryLoaded) return;
    if (current.isLoadingMore || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      final result = await _useCase.getHistory(
        tanggalAwal: current.tanggalAwal,
        tanggalAkhir: current.tanggalAkhir,
        startData: current.items.length,
        jmlData: _pageSize,
      );
      final merged = [...current.items, ...result.items];
      emit(
        current.copyWith(
          items: merged,
          filtered: _applyQuery(merged, current.query),
          hasMore: result.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  void search(String query) {
    final current = state;
    if (current is! HistoryLoaded) return;
    emit(
      current.copyWith(
        query: query,
        filtered: _applyQuery(current.items, query),
      ),
    );
  }

  List<HistoryEntity> _applyQuery(List<HistoryEntity> items, String query) {
    if (query.trim().isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((e) => e.alamat.toLowerCase().contains(q)).toList();
  }

  String _mapError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('401') || msg.contains('unauthorized')) {
      return 'Sesi berakhir, silakan login kembali';
    }
    if (msg.contains('socket') || msg.contains('connection')) {
      return 'Tidak ada koneksi internet';
    }
    return 'Gagal memuat riwayat, silakan coba lagi';
  }
}
