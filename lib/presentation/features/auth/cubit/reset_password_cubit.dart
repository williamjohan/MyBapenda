// lib/presentation/features/auth/cubit/reset_password_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/usecases/auth/auth_usecase.dart';
import 'reset_password_state.dart';

/// Ganti kata sandi setelah login memakai reset key (isResetPassword = true).
@injectable
class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthUseCase _useCase;
  ResetPasswordCubit(this._useCase) : super(const ResetPasswordIdle());

  Future<void> submit({
    required String newPassword,
    required String confirmationPassword,
  }) async {
    if (state is ResetPasswordLoading) return;

    emit(const ResetPasswordLoading());
    final result = await _useCase.resetPassword(
      newPassword: newPassword,
      confirmationPassword: confirmationPassword,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(ResetPasswordFailure(failure.message)),
      (_) => emit(const ResetPasswordSuccess()),
    );
  }
}
