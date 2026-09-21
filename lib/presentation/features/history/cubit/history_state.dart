import 'package:bapendacore/domain/entities/history/history_entity.dart';
import 'package:equatable/equatable.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<HistoryEntity> items;
  final List<HistoryEntity> filtered;
  final DateTime tanggalAwal;
  final DateTime tanggalAkhir;
  final bool hasMore;
  final bool isLoadingMore;
  final String query;

  const HistoryLoaded({
    required this.items,
    required this.filtered,
    required this.tanggalAwal,
    required this.tanggalAkhir,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.query = '',
  });

  HistoryLoaded copyWith({
    List<HistoryEntity>? items,
    List<HistoryEntity>? filtered,
    DateTime? tanggalAwal,
    DateTime? tanggalAkhir,
    bool? hasMore,
    bool? isLoadingMore,
    String? query,
  }) {
    return HistoryLoaded(
      items: items ?? this.items,
      filtered: filtered ?? this.filtered,
      tanggalAwal: tanggalAwal ?? this.tanggalAwal,
      tanggalAkhir: tanggalAkhir ?? this.tanggalAkhir,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [
    items,
    filtered,
    tanggalAwal,
    tanggalAkhir,
    hasMore,
    isLoadingMore,
    query,
  ];
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
  @override
  List<Object?> get props => [message];
}
