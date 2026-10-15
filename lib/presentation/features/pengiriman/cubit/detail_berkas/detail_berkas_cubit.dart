import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../domain/usecases/pengiriman/pengiriman_usecase.dart';
import 'detail_berkas_state.dart';

/// Detail satu tugas (`GET detail`) beserta timeline jejak.
@injectable
class DetailBerkasCubit extends Cubit<DetailBerkasState> {
  final PengirimanUseCase _useCase;
  DetailBerkasCubit(this._useCase) : super(const DetailBerkasState());

  /// Nomor request terakhir. Setelah aksi, load bisa dipanggil berdekatan
  /// (halaman aksi ditutup lalu antrean terkirim); respons lama yang datang
  /// belakangan tidak boleh menimpa data baru (tombol aksi lama muncul lagi).
  int _urutan = 0;

  Future<void> load(String noResi) async {
    final urutan = ++_urutan;
    // Refresh tetap menampilkan data lama sampai yang baru datang.
    if (state.detail == null) {
      emit(state.copyWith(status: DetailBerkasStatus.loading));
    }
    final result = await _useCase.getDetail(noResi);
    if (isClosed || urutan != _urutan) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DetailBerkasStatus.failure,
          error: failure.message,
        ),
      ),
      (hasil) => emit(
        state.copyWith(
          status: DetailBerkasStatus.loaded,
          detail: hasil.data,
          tglCache: hasil.tglCache,
          aturCache: true,
        ),
      ),
    );
  }
}
