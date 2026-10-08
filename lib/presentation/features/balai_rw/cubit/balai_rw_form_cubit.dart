// lib/presentation/features/balai_rw/cubit/balai_rw_form_cubit.dart
import 'package:bapendacore/domain/usecases/balai_rw/balai_rw_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'balai_rw_form_state.dart';

@injectable
class BalaiRwFormCubit extends Cubit<BalaiRwFormState> {
  final BalaiRwUseCase _useCase;

  BalaiRwFormCubit(this._useCase) : super(const BalaiRwFormState());

  Future<void> load() async {
    emit(state.copyWith(status: BalaiRwFormStatus.loading));

    // 1) kategori dulu
    final kategoriRes = await _useCase.getKategori();
    if (isClosed) return;
    if (kategoriRes.isLeft()) return _fail();

    // 2) baru pertanyaan
    final pertanyaanRes = await _useCase.getPertanyaan();
    if (isClosed) return;
    if (pertanyaanRes.isLeft()) return _fail();

    final kategori = kategoriRes.getOrElse(() => const []);
    final pertanyaan = pertanyaanRes.getOrElse(() => const []);

    final sections = <BalaiRwSection>[];
    for (final k in kategori) {
      final qs = pertanyaan.where((q) => q.idKategori == k.idKategori).toList()
        ..sort((a, b) => a.seq.compareTo(b.seq));
      if (qs.isEmpty) continue; // kategori tanpa pertanyaan tidak ditampilkan
      sections.add(BalaiRwSection(kategori: k, pertanyaan: qs));
    }

    emit(state.copyWith(status: BalaiRwFormStatus.success, sections: sections));
  }

  void _fail() {
    // TODO: kalau Failure-mu punya pesan, pakai di sini
    // (mis. lewat fold: (f) => f.message). Aku belum lihat class Failure-nya.
    emit(
      state.copyWith(
        status: BalaiRwFormStatus.failure,
        error: 'Gagal memuat form. Periksa koneksi lalu coba lagi.',
      ),
    );
  }
}
