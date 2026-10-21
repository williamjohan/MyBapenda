import 'package:mybapenda/domain/entities/cek_reklames/survey_permohonan_baru/survey_history_entity.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_history/history_format.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;

enum SurveyHistoryStatus { initial, loading, success, failure }

enum HistoryRangePreset { days7, days30, thisMonth, custom }

class HistoryMonthGroup {
  final String label;
  final List<SurveyHistoryEntity> items;
  HistoryMonthGroup(this.label, this.items);
}

class SurveyHistoryListState extends Equatable {
  final SurveyHistoryStatus status;
  final List<SurveyHistoryEntity> items;
  final String query;
  final DateTimeRange range;
  final HistoryRangePreset preset;
  final String? error;

  const SurveyHistoryListState({
    required this.range,
    this.status = SurveyHistoryStatus.initial,
    this.items = const [],
    this.query = '',
    this.preset = HistoryRangePreset.days30,
    this.error,
  });

  /// Pencarian di sisi aplikasi (data sudah dibatasi rentang tanggal).
  List<SurveyHistoryEntity> get filtered {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items
        .where(
          (e) =>
              e.noPelayanan.toLowerCase().contains(q) ||
              e.npwpd.toLowerCase().contains(q) ||
              e.namaPemohon.toLowerCase().contains(q) ||
              e.lokPenyelenggaraan.toLowerCase().contains(q),
        )
        .toList();
  }

  static DateTime? _dateOf(SurveyHistoryEntity e) =>
      e.tglSurvey ?? e.tanggalPermohonan;

  /// Terbaru di atas, dikelompokkan per bulan.
  List<HistoryMonthGroup> get groups {
    final sorted = [...filtered]
      ..sort((a, b) {
        final da = _dateOf(a);
        final db = _dateOf(b);
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });

    final out = <HistoryMonthGroup>[];
    for (final e in sorted) {
      final d = _dateOf(e);
      final label = d == null ? 'Tanpa tanggal' : HistoryFmt.bulanTahun(d);
      if (out.isNotEmpty && out.last.label == label) {
        out.last.items.add(e);
      } else {
        out.add(HistoryMonthGroup(label, [e]));
      }
    }
    return out;
  }

  SurveyHistoryListState copyWith({
    SurveyHistoryStatus? status,
    List<SurveyHistoryEntity>? items,
    String? query,
    DateTimeRange? range,
    HistoryRangePreset? preset,
    String? error,
    bool clearError = false,
  }) => SurveyHistoryListState(
    status: status ?? this.status,
    items: items ?? this.items,
    query: query ?? this.query,
    range: range ?? this.range,
    preset: preset ?? this.preset,
    error: clearError ? null : error ?? this.error,
  );

  @override
  List<Object?> get props => [status, items, query, range, preset, error];
}
