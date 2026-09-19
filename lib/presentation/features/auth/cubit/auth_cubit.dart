// SESUDAH
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/usecases/auth/auth_usecase.dart';
import 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final AuthUseCase authUseCase;

  AuthCubit({required this.authUseCase})
    : super(const AuthInitial());

  Future<void> checkSession() async {
    emit(const AuthLoading());
    try {
      final isLoggedIn = await authUseCase.getCurrentSession();
      if (!isLoggedIn) {
        emit(const AuthUnauthenticated());
        return;
      }
      final mustChangePassword = await authUseCase.getMustChangePassword();
      emit(
        mustChangePassword
            ? const AuthNeedsPasswordReset()
            : const AuthAuthenticated(),
      );
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> login(String nip, String password) async {
    emit(const AuthLoading());
    try {
      final result = await authUseCase.login(nip: nip, password: password);
      emit(
        result.isResetPassword
            ? const AuthNeedsPasswordReset()
            : const AuthAuthenticated(),
      );
    } catch (e) {
      emit(AuthFailure(_mapError(e)));
    }
  }

  Future<void> logout() async {
    try {
      await authUseCase.logout();
    } finally {
      emit(const AuthUnauthenticated());
    }
  }

  String _mapError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('401') || msg.contains('unauthorized')) {
      return 'NIP atau kata sandi salah';
    }
    return 'Login gagal, silakan coba lagi';
  }
}
