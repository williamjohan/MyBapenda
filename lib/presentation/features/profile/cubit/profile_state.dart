// lib/presentation/features/profile/cubit/profile_state.dart
import 'package:bapendacore/domain/entities/users/user_entity.dart';
import 'package:equatable/equatable.dart';

enum ProfileStatus { loading, ready, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserEntity? user; // null = belum ada data (cache kosong & API gagal)
  final bool refreshing; // true = sedang ambil ulang dari server
  final bool uploadingFoto; // true = sedang unggah foto profil
  final int fotoVersi; // naik tiap ganti foto -> avatar muat ulang gambar
  final String? error;
  final String? info; // pesan sukses sekali tampil (snackbar)

  const ProfileState({
    this.status = ProfileStatus.loading,
    this.user,
    this.refreshing = false,
    this.uploadingFoto = false,
    this.fotoVersi = 0,
    this.error,
    this.info,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserEntity? user,
    bool? refreshing,
    bool? uploadingFoto,
    int? fotoVersi,
    String? error,
    String? info,
  }) => ProfileState(
    status: status ?? this.status,
    user: user ?? this.user,
    refreshing: refreshing ?? this.refreshing,
    uploadingFoto: uploadingFoto ?? this.uploadingFoto,
    fotoVersi: fotoVersi ?? this.fotoVersi,
    error: error,
    info: info,
  );

  @override
  List<Object?> get props => [
    status,
    user,
    refreshing,
    uploadingFoto,
    fotoVersi,
    error,
    info,
  ];
}
