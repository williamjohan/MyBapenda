import 'package:equatable/equatable.dart';

enum SurveySummaryStatus { initial, loading, success, failure }

class SurveySummaryState extends Equatable {
  final SurveySummaryStatus status;

  final int? total;
  final int? baru;
  final int? dikembalikanPenilaian;

  const SurveySummaryState({
    this.status = SurveySummaryStatus.initial,
    this.total,
    this.baru,
    this.dikembalikanPenilaian,
  });

  SurveySummaryState copyWith({SurveySummaryStatus? status, int? total}) {
    return SurveySummaryState(
      status: status ?? this.status,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [status, total];
}
