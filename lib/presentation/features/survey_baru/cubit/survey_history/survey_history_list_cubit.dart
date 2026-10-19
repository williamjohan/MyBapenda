
import 'package:bapendacore/domain/usecases/survey_permohonan/survey_history_usecase.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'survey_history_list_state.dart';

class SurveyHistoryListCubit extends Cubit<SurveyHistoryListState> {
  final SurveyHistoryUseCase _useCase;
  int _reqId = 0;

  SurveyHistoryListCubit({required SurveyHistoryUseCase useCase})
    : _useCase = useCase,
      super(SurveyHistoryListState(range: rangeOf(HistoryRangePreset.days30)));

  static DateTimeRange rangeOf(HistoryRangePreset p) {
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    switch (p) {
      case HistoryRangePreset.days7:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
        );
      case HistoryRangePreset.thisMonth:
        return DateTimeRange(start: DateTime(n.year, n.month, 1), end: today);
      case HistoryRangePreset.days30:
      case HistoryRangePreset.custom:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 29)),
          end: today,
        );
    }
  }

  Future<void> load() async {
    final id = ++_reqId;
    // Pull-to-refresh: list lama tetap tampil, tanpa spinner penuh.
    if (state.items.isEmpty) {
      emit(
        state.copyWith(status: SurveyHistoryStatus.loading, clearError: true),
      );
    }

    final result = await _useCase.getHistory(
      tglAwal: state.range.start,
      tglAkhir: state.range.end,
    );
    if (isClosed || id != _reqId) return; // hasil basi diabaikan

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SurveyHistoryStatus.failure,
          error: failure.message, // sesuaikan field di Failure
        ),
      ),
      (items) => emit(
        state.copyWith(
          status: SurveyHistoryStatus.success,
          items: items,
          clearError: true,
        ),
      ),
    );
  }

  void search(String q) => emit(state.copyWith(query: q));

  /// Ganti rentang: data lama dibuang karena sudah tidak relevan.
  Future<void> setPreset(HistoryRangePreset p) {
    emit(
      state.copyWith(
        preset: p,
        range: rangeOf(p),
        items: const [],
        status: SurveyHistoryStatus.loading,
      ),
    );
    return load();
  }

  Future<void> setCustomRange(DateTimeRange r) {
    emit(
      state.copyWith(
        preset: HistoryRangePreset.custom,
        range: r,
        items: const [],
        status: SurveyHistoryStatus.loading,
      ),
    );
    return load();
  }
}
