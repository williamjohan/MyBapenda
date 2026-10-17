// lib/presentation/features/auth/cubit/lupa_password_state.dart
import 'package:equatable/equatable.dart';

sealed class LupaPasswordState extends Equatable {
  const LupaPasswordState();
  @override
  List<Object?> get props => [];
}

class LupaPasswordIdle extends LupaPasswordState {
  const LupaPasswordIdle();
}

class LupaPasswordLoading extends LupaPasswordState {
  const LupaPasswordLoading();
}

class LupaPasswordSuccess extends LupaPasswordState {
  /// Email / nomor WhatsApp tujuan, untuk ditampilkan ke pegawai.
  final String tujuan;
  const LupaPasswordSuccess(this.tujuan);
  @override
  List<Object?> get props => [tujuan];
}

class LupaPasswordFailure extends LupaPasswordState {
  final String message;
  const LupaPasswordFailure(this.message);
  @override
  List<Object?> get props => [message];
}
