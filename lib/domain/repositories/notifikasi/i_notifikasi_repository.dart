import 'package:dartz/dartz.dart';

import '../../../core/errors/failure.dart';
import '../../entities/notifikasi/notifikasi_entity.dart';

abstract class INotifikasiRepository {
  /// Cadangan saja (kontrak): badge normalnya dari event hub.
  Future<Either<Failure, int>> getJumlahBelumDibaca();

  Future<Either<Failure, HalamanNotifikasiEntity>> getInbox({
    int page = 1,
    int pageSize = 20,
    bool hanyaBelumDibaca = false,
  });

  /// Jumlah yang berubah (1 berhasil, 0 sudah dibaca sebelumnya). Badge
  /// diperbarui snapshot dari server, bukan dihitung app.
  Future<Either<Failure, int>> baca(int id);

  Future<Either<Failure, int>> bacaSemua();

  /// Berbunyi tiap event hub `NOTIF` (baru maupun snapshot).
  Stream<void> get perubahan;

  /// Nilai badge dari event hub.
  Stream<int> get jumlahBelumDibaca;

  /// Nilai badge terakhir yang diketahui; null = belum ada event.
  int? get jumlahTerakhir;
}
