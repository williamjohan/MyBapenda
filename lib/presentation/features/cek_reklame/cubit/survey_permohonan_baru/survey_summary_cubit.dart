
import 'package:bapendacore/domain/usecases/survey_permohonan/survey_permohonan_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'survey_summary_state.dart';

@injectable
class SurveySummaryCubit extends Cubit<SurveySummaryState> {
  final SurveyPermohonanUseCase _useCase;

  SurveySummaryCubit(this._useCase) : super(const SurveySummaryState());

  Future<void> load() async {
    emit(state.copyWith(status: SurveySummaryStatus.loading));

    final result = await _useCase.getSurveySummary();
    if (isClosed) return;

    result.fold(
      (_) => emit(state.copyWith(status: SurveySummaryStatus.failure)),
      (s) => emit(
        SurveySummaryState(status: SurveySummaryStatus.success, total: s.total),
      ),
    );
  }
}
