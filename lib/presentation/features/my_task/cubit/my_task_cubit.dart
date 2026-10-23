// lib/presentation/features/my_task/cubit/my_task/my_task_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mybapenda/core/errors/failure.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_entity.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_header_entity.dart';
import 'package:mybapenda/domain/usecases/my_task/my_task_usecase.dart';
import 'my_task_state.dart';

class MyTaskCubit extends Cubit<MyTaskState> {
  final MyTaskUseCase _useCase;

  static const _pageSize = 50;

  /// Pengaman: maksimal halaman yang diambil sekali muat (20 x 50 = 1000 tugas).
  static const _maxPages = 20;

  MyTaskCubit({required MyTaskUseCase useCase})
    : _useCase = useCase,
      super(const MyTaskState());

  /// Muat pertama / coba lagi: daftar diganti skeleton selama memuat.
  Future<void> load() async {
    emit(state.copyWith(status: MyTaskLoadStatus.loading, error: () => null));
    final result = await _fetchAll();
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MyTaskLoadStatus.failure,
          error: () => failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: MyTaskLoadStatus.success,
          summary: data.summary,
          tasks: data.items,
          error: () => null,
        ),
      ),
    );
  }

  /// Tarik-untuk-muat-ulang: daftar lama tetap tampil. Kalau gagal, daftar
  /// lama dipertahankan dan [MyTaskState.error] terisi.
  Future<void> refresh() async {
    final result = await _fetchAll();
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(error: () => failure.message)),
      (data) => emit(
        state.copyWith(
          status: MyTaskLoadStatus.success,
          summary: data.summary,
          tasks: data.items,
          error: () => null,
        ),
      ),
    );
  }

  /// [kode] null = semua jenis.
  void setJenisFilter(String? kode) => emit(
    state.copyWith(
      jenisFilter: () => (kode == null || kode == 'semua') ? null : kode,
    ),
  );

  void clearError() => emit(state.copyWith(error: () => null));

  // ---- Ambil semua halaman ----

  /// Server membatasi isi per halaman, sedangkan daftar disaring per tab di
  /// aplikasi. Karena itu semua halaman diambil dulu supaya jumlah di tiap tab
  /// tidak terpotong.
  Future<Either<Failure, MyTaskHeaderEntity>> _fetchAll() async {
    MyTaskSummaryEntity? summary;
    final byKey = <String, MyTaskEntity>{};

    for (var page = 1; page <= _maxPages; page++) {
      final result = await _useCase.getHeader(page: page, pageSize: _pageSize);
      final (failure, header) = result.fold<(Failure?, MyTaskHeaderEntity?)>(
        (f) => (f, null),
        (h) => (null, h),
      );

      if (failure != null) {
        if (page == 1) return left(failure);
        break; // halaman berikutnya gagal: tampilkan yang sudah terambil
      }

      final data = header!;
      summary ??= data.summary;
      for (final task in data.items) {
        byKey[task.keyTask] = task;
      }
      if (!data.summary.hasMore || data.items.isEmpty) break;
    }

    return right(
      MyTaskHeaderEntity(summary: summary!, items: byKey.values.toList()),
    );
  }
}
