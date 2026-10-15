// lib/presentation/features/auth/cubit/reset_password_state.dart
import 'package:equatable/equatable.dart';

sealed class ResetPasswordState extends Equatable {
  const ResetPasswordState();
  @override
  List<Object?> get props => [];
}

class ResetPasswordIdle extends ResetPasswordState {
  const ResetPasswordIdle();
}

class ResetPasswordLoading extends ResetPasswordState {
  const ResetPasswordLoading();
}

class ResetPasswordSuccess extends ResetPasswordState {
  const ResetPasswordSuccess();
}

class ResetPasswordFailure extends ResetPasswordState {
  final String message;
  const ResetPasswordFailure(this.message);
  @override
  List<Object?> get props => [message];
}
