// lib/presentation/features/my_task/cubit/my_task/my_task_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_entity.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_header_entity.dart';
import 'package:mybapenda/presentation/features/my_task/logic/task_priority_logic.dart';

enum MyTaskLoadStatus { initial, loading, success, failure }

class MyTaskState extends Equatable {
  final MyTaskLoadStatus status;
  final MyTaskSummaryEntity? summary;
  final List<MyTaskEntity> tasks;
  final String? jenisFilter;
  final String? error;

  const MyTaskState({
    this.status = MyTaskLoadStatus.initial,
    this.summary,
    this.tasks = const [],
    this.jenisFilter,
    this.error,
  });

  bool get isLoading =>
      status == MyTaskLoadStatus.initial || status == MyTaskLoadStatus.loading;

  List<MyTaskEntity> tasksOf(MyTaskStatus tab) =>
      TaskPriorityLogic.forStatus(tasks, tab, jenis: jenisFilter);

  MyTaskState copyWith({
    MyTaskLoadStatus? status,
    MyTaskSummaryEntity? summary,
    List<MyTaskEntity>? tasks,
    ValueGetter<String?>? jenisFilter,
    ValueGetter<String?>? error,
  }) => MyTaskState(
    status: status ?? this.status,
    summary: summary ?? this.summary,
    tasks: tasks ?? this.tasks,
    jenisFilter: jenisFilter != null ? jenisFilter() : this.jenisFilter,
    error: error != null ? error() : this.error,
  );

  @override
  List<Object?> get props => [status, summary, tasks, jenisFilter, error];
}
