// lib/presentation/features/profile/cubit/profile_state.dart
import 'package:bapendacore/domain/entities/users/user_entity.dart';
import 'package:equatable/equatable.dart';

enum ProfileStatus { loading, ready, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserEntity? user; // null = belum ada data (cache kosong & API gagal)
  final bool refreshing; // true = sedang ambil ulang dari server
  final String? error;

  const ProfileState({
    this.status = ProfileStatus.loading,
    this.user,
    this.refreshing = false,
    this.error,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserEntity? user,
    bool? refreshing,
    String? error,
  }) => ProfileState(
    status: status ?? this.status,
    user: user ?? this.user,
    refreshing: refreshing ?? this.refreshing,
    error: error,
  );

  @override
  List<Object?> get props => [status, user, refreshing, error];
}
