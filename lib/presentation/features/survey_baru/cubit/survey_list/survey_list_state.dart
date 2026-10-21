import 'package:equatable/equatable.dart';
import 'package:mybapenda/domain/entities/cek_reklames/survey_permohonan_baru/survey_permohonan_entity.dart';

enum SurveyListStatus { initial, loading, success, failure }

class SurveyListState extends Equatable {
  final SurveyListStatus status;
  final List<SurveyPermohonanEntity> items;
  final String query;
  final String? error;
  final bool isOpening;

  const SurveyListState({
    this.status = SurveyListStatus.initial,
    this.items = const [],
    this.query = '',
    this.error,
    this.isOpening = false,
  });

  List<SurveyPermohonanEntity> get filtered {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items
        .where(
          (e) =>
              e.noPelayanan.toLowerCase().contains(q) ||
              e.npwpd.toLowerCase().contains(q),
        )
        .toList();
  }

  SurveyListState copyWith({
    SurveyListStatus? status,
    List<SurveyPermohonanEntity>? items,
    String? query,
    String? error,
    bool clearError = false,
    bool? isOpening,
  }) => SurveyListState(
    status: status ?? this.status,
    items: items ?? this.items,
    query: query ?? this.query,
    error: clearError ? null : error ?? this.error,
    isOpening: isOpening ?? this.isOpening,
  );

  @override
  List<Object?> get props => [status, items, query, error, isOpening];
}
