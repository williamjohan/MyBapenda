import 'package:bapendacore/domain/entities/cek_reklames/survey_permohonan_baru/survey_history_entity.dart';
import 'package:equatable/equatable.dart';

enum SurveyHistoryDetailStatus { loading, success, failure }

class SurveyHistoryDetailState extends Equatable {
  final SurveyHistoryDetailStatus status;
  final SurveyHistoryDetailEntity? detail;
  final String? error;
  final bool downloading;

  const SurveyHistoryDetailState({
    this.status = SurveyHistoryDetailStatus.loading,
    this.detail,
    this.error,
    this.downloading = false,
  });

  SurveyHistoryDetailState copyWith({
    SurveyHistoryDetailStatus? status,
    SurveyHistoryDetailEntity? detail,
    String? error,
    bool clearError = false,
    bool? downloading,
  }) => SurveyHistoryDetailState(
    status: status ?? this.status,
    detail: detail ?? this.detail,
    error: clearError ? null : error ?? this.error,
    downloading: downloading ?? this.downloading,
  );

  @override
  List<Object?> get props => [status, detail, error, downloading];
}
