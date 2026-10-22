import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../domain/usecases/survey_permohonan/survey_permohonan_usecase.dart';

/// Radius maksimal pin reklame (meter) untuk halaman Daftar Sisi: nilai
/// `survey-form`, lalu setting cadangan, dan ikut berubah saat ada push
/// SignalR `PENGATURAN_SURVEY`.
@injectable
class SurveyRadiusCubit extends Cubit<int> {
  final SurveyPermohonanUseCase _useCase;
  StreamSubscription<int>? _berubah;
  bool _dariPush = false;

  SurveyRadiusCubit(this._useCase)
    : super(SurveyPermohonanUseCase.radiusBawaanMeter);

  Future<void> mulai({int? dariForm}) async {
    _berubah ??= _useCase.radiusBerubah.listen((m) {
      _dariPush = true;
      if (!isClosed) emit(m);
    });
    if (dariForm != null && dariForm > 0) {
      emit(dariForm);
      return;
    }
    final m = await _useCase.radiusSurvey();
    // Push yang datang lebih dulu lebih baru dari setting cadangan.
    if (!isClosed && !_dariPush) emit(m);
  }

  @override
  Future<void> close() {
    _berubah?.cancel();
    return super.close();
  }
}
