import 'package:bapendacore/data/models/history/history_model.dart';
import 'package:bapendacore/domain/repositories/history/history_repository.dart';
import 'package:injectable/injectable.dart';
import '../../datasources/cek_reklame/history_remote_datasource.dart';

@LazySingleton(as: HistoryRepository)
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource _remoteDataSource;
  HistoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<HistoryListResult> getHistory({
    required DateTime tanggalAwal,
    required DateTime tanggalAkhir,
    int startData = 0,
    int jmlData = 20,
  }) async {
    final models = await _remoteDataSource.getHistory(
      tanggalAwal: _formatDate(tanggalAwal),
      tanggalAkhir: _formatDate(tanggalAkhir),
      startData: startData,
      jmlData: jmlData,
    );

    return HistoryListResult(
      items: models.map((e) => e.toEntity()).toList(),
      hasMore: models.length >= jmlData,
    );
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
