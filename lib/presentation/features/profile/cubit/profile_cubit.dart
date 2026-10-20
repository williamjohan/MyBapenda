// lib/presentation/features/profile/cubit/profile_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/entities/profile/kontak_profil_entity.dart';
import '../../../../domain/usecases/auth/auth_usecase.dart';
import '../../../../domain/usecases/profile/profile_usecase.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final AuthUseCase _useCase;
  final ProfileUseCase _profileUseCase;

  ProfileCubit(this._useCase, this._profileUseCase)
    : super(const ProfileState());

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

  /// Unggah foto profil baru (path JPEG sudah dikompres), lalu sinkron cache.
  Future<void> gantiFoto(String fotoPath) async {
    if (state.uploadingFoto) return;
    emit(state.copyWith(uploadingFoto: true));

    final result = await _profileUseCase.gantiFoto(fotoPath);
    if (isClosed) return;

    final berhasil = result.fold(
      (failure) {
        emit(state.copyWith(uploadingFoto: false, error: failure.message));
        return false;
      },
      (foto) {
        emit(
          state.copyWith(
            user: state.user?.copyWith(foto: foto),
            uploadingFoto: false,
            fotoVersi: state.fotoVersi + 1,
            info: 'Foto profil berhasil diganti',
          ),
        );
        return true;
      },
    );
    if (berhasil) await _sinkronDiam();
  }

  /// Dipanggil setelah OTP kontak terverifikasi di halaman ubah kontak.
  Future<void> kontakDiperbarui(KontakProfilEntity kontak) async {
    emit(
      state.copyWith(
        user: state.user?.copyWith(
          hp: kontak.hp,
          email: kontak.email,
          isValidEmail: kontak.isValidEmail,
          isValidWa: kontak.isValidWa,
        ),
        info: 'Kontak berhasil diperbarui',
      ),
    );
    await _sinkronDiam();
  }

  /// Perbarui cache profil tanpa mengganggu tampilan bila gagal.
  Future<void> _sinkronDiam() async {
    final result = await _useCase.getProfile();
    if (isClosed) return;
    result.fold((_) {}, (user) => emit(state.copyWith(user: user)));
  }
}
