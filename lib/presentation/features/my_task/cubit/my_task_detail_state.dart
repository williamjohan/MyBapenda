// lib/presentation/features/my_task/cubit/my_task_detail/my_task_detail_state.dart
import 'package:equatable/equatable.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_detail_entity.dart';

enum MyTaskDetailStatus { loading, success, failure }

class MyTaskDetailState extends Equatable {
  final MyTaskDetailStatus status;
  final MyTaskDetailEntity? detail;
  final String? error;

  const MyTaskDetailState({
    this.status = MyTaskDetailStatus.loading,
    this.detail,
    this.error,
  });

  MyTaskDetailState copyWith({
    MyTaskDetailStatus? status,
    MyTaskDetailEntity? detail,
    String? error,
    bool clearError = false,
  }) => MyTaskDetailState(
    status: status ?? this.status,
    detail: detail ?? this.detail,
    error: clearError ? null : error ?? this.error,
  );

  @override
  List<Object?> get props => [status, detail, error];
}
