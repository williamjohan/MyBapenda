import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mybapenda/presentation/features/my_task/logic/task_draft.dart';

class MyTaskWorkState extends Equatable {
  final TaskDraft draft;
  final bool isLocating;
  final String? locationError;

  const MyTaskWorkState({
    this.draft = const TaskDraft(),
    this.isLocating = false,
    this.locationError,
  });

  MyTaskWorkState copyWith({
    TaskDraft? draft,
    bool? isLocating,
    ValueGetter<String?>? locationError,
  }) => MyTaskWorkState(
    draft: draft ?? this.draft,
    isLocating: isLocating ?? this.isLocating,
    locationError: locationError != null ? locationError() : this.locationError,
  );

  @override
  List<Object?> get props => [draft, isLocating, locationError];
}
