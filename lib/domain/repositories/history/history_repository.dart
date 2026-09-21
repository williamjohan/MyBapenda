import 'package:bapendacore/domain/entities/history/history_entity.dart';

class HistoryListResult {
  final List<HistoryEntity> items;
  final bool hasMore;

  const HistoryListResult({required this.items, required this.hasMore});
}

abstract class HistoryRepository {
  Future<HistoryListResult> getHistory({
    required DateTime tanggalAwal,
    required DateTime tanggalAkhir,
    int startData = 0,
    int jmlData = 20,
  });
}
