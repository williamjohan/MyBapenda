// lib/presentation/features/profile/cubit/profile_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/usecases/auth/auth_usecase.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final AuthUseCase _useCase;

  ProfileCubit(this._useCase) : super(const ProfileState());

  /// Tampilkan cache dulu (instan), lalu perbarui dari `/api/profile`.
  Future<void> load() async {
    final cached = await _useCase.getCurrentUserProfile();
    if (isClosed) return;
    if (cached != null) {
      emit(state.copyWith(status: ProfileStatus.ready, user: cached));
    }
    await refresh();
  }

  Future<void> refresh() async {
    emit(state.copyWith(refreshing: true));

    final result = await _useCase.getProfile();
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          // Kalau sudah ada data cache, tetap tampilkan; cukup info error.
          status: state.user == null
              ? ProfileStatus.failure
              : ProfileStatus.ready,
          refreshing: false,
          error: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: ProfileStatus.ready,
          user: user,
          refreshing: false,
        ),
      ),
    );
  }
}
