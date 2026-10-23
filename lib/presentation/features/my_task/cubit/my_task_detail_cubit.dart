// lib/presentation/features/my_task/cubit/my_task_detail/my_task_detail_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_entity.dart';
import 'package:mybapenda/domain/usecases/my_task/my_task_usecase.dart';
import 'my_task_detail_state.dart';

class MyTaskDetailCubit extends Cubit<MyTaskDetailState> {
  final MyTaskUseCase _useCase;

  /// Tugas dari daftar. Dipakai untuk tampilan awal dan untuk memanggil detail
  /// (jenis + keyTask).
  final MyTaskEntity task;

  MyTaskDetailCubit({required MyTaskUseCase useCase, required this.task})
    : _useCase = useCase,
      super(const MyTaskDetailState());

  Future<void> load() async {
    emit(state.copyWith(status: MyTaskDetailStatus.loading, clearError: true));

    final result = await _useCase.getHeaderDetail(
      jenis: task.jenis,
      key: task.keyTask,
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MyTaskDetailStatus.failure,
          error: failure.message,
        ),
      ),
      (detail) => emit(
        state.copyWith(
          status: MyTaskDetailStatus.success,
          detail: detail,
          clearError: true,
        ),
      ),
    );
  }
}
