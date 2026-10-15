// lib/presentation/features/auth/cubit/lupa_password_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/entities/auth/lupa_password_metode.dart';
import '../../../../domain/usecases/auth/auth_usecase.dart';
import 'lupa_password_state.dart';

/// Kirim permintaan reset kata sandi lewat email / WhatsApp.
@injectable
class LupaPasswordCubit extends Cubit<LupaPasswordState> {
  final AuthUseCase _useCase;
  LupaPasswordCubit(this._useCase) : super(const LupaPasswordIdle());

  Future<void> submit({
    required String nip,
    required LupaPasswordMetode metode,
    required String tujuan,
  }) async {
    if (state is LupaPasswordLoading) return;

    emit(const LupaPasswordLoading());
    final result = await _useCase.lupaPassword(
      nip: nip,
      metode: metode,
      tujuan: tujuan,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(LupaPasswordFailure(failure.message)),
      (_) => emit(LupaPasswordSuccess(tujuan)),
    );
  }

  void reset() => emit(const LupaPasswordIdle());
}
