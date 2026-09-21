import 'package:bapendacore/domain/repositories/history/history_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class HistoryUseCase {
  final HistoryRepository repository;
  HistoryUseCase(this.repository);

  Future<HistoryListResult> getHistory({
    required DateTime tanggalAwal,
    required DateTime tanggalAkhir,
    int startData = 0,
    int jmlData = 20,
  }) {
    return repository.getHistory(
      tanggalAwal: tanggalAwal,
      tanggalAkhir: tanggalAkhir,
      startData: startData,
      jmlData: jmlData,
    );
  }
}
