import 'package:mybapenda/domain/usecases/survey_permohonan/survey_history_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'survey_history_detail_state.dart';

class SurveyHistoryDetailCubit extends Cubit<SurveyHistoryDetailState> {
  final SurveyHistoryUseCase _useCase;
  final String key;

  SurveyHistoryDetailCubit({
    required SurveyHistoryUseCase useCase,
    required this.key,
  }) : _useCase = useCase,
       super(const SurveyHistoryDetailState());

  Future<void> load() async {
    emit(
      state.copyWith(
        status: SurveyHistoryDetailStatus.loading,
        clearError: true,
      ),
    );

    final result = await _useCase.getHistoryDetail(key: key);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SurveyHistoryDetailStatus.failure,
          error: failure.message, // sesuaikan field di Failure
        ),
      ),
      (detail) => emit(
        state.copyWith(
          status: SurveyHistoryDetailStatus.success,
          detail: detail,
          clearError: true,
        ),
      ),
    );
  }

  /// Unduh laporan PDF ke folder temp. Pembukaan file dilakukan oleh halaman.
  Future<({String? path, String? error})> downloadPdf() async {
    final d = state.detail;
    final url = d?.laporanPdfUrl;
    if (d == null || url == null) {
      return (path: null, error: 'Laporan belum tersedia.');
    }
    if (state.downloading) return (path: null, error: null);

    emit(state.copyWith(downloading: true));
    final safe = d.noPelayanan.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final result = await _useCase.downloadLaporan(
      url: url,
      fileName: 'laporan_survey_$safe.pdf',
    );
    if (isClosed) return (path: null, error: null);
    emit(state.copyWith(downloading: false));

    return result.fold(
      (failure) => (path: null, error: failure.message),
      (path) => (path: path, error: null),
    );
  }
}
