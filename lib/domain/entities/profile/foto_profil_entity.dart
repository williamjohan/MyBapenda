// lib/domain/entities/profile/foto_profil_entity.dart
import 'package:equatable/equatable.dart';

/// Info file foto profil pegawai (`foto` di `/api/profile`).
class FotoProfilEntity extends Equatable {
  /// URL publik foto; `key` di dalamnya berlaku sampai ganti hari.
  final String fotoUrl;
  final String namaFile;
  final String ukuranFile;
  final String tipeFile;
  final String contentType;

  const FotoProfilEntity({
    required this.fotoUrl,
    required this.namaFile,
    required this.ukuranFile,
    required this.tipeFile,
    required this.contentType,
  });

  @override
  List<Object?> get props => [
    fotoUrl,
    namaFile,
    ukuranFile,
    tipeFile,
    contentType,
  ];
}
