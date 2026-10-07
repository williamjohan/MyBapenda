import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/usecases/absensi/absensi_usecase.dart';
import 'laporan_state.dart';

/// Unduh PDF laporan kehadiran bulanan (sama dengan cetakan web).
@injectable
class LaporanCubit extends Cubit<LaporanState> {
  final AbsensiUseCase _useCase;
  LaporanCubit(this._useCase) : super(const LaporanIdle());

  Future<void> download({required int tahun, required int bulan}) async {
    if (state is LaporanDownloading) return;

    emit(const LaporanDownloading(null));
    final result = await _useCase.downloadLaporanPdf(
      tahun: tahun,
      bulan: bulan,
      onProgress: (progress) {
        if (!isClosed) emit(LaporanDownloading(progress));
      },
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(LaporanFailure(failure.message)),
      (path) => emit(LaporanSuccess(path)),
    );
  }

  void reset() => emit(const LaporanIdle());
}
