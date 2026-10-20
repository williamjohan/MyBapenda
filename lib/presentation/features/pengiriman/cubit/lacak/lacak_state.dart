import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/pengiriman/lacak_entity.dart';

enum LacakStatus { initial, loading, loaded, failure }

class LacakState extends Equatable {
  final LacakStatus status;

  /// Kode terakhir yang dilacak (no resi / isi QR).
  final String kode;
  final LacakResultEntity? result;
  final String? error;

  /// Jalur jalan antar titik perjalanan; null = belum ada / tidak tersedia
  /// (peta cukup menampilkan titik).
  final List<TitikRute>? rute;

  const LacakState({
    this.status = LacakStatus.initial,
    this.kode = '',
    this.result,
    this.error,
    this.rute,
  });

  LacakState copyWith({
    LacakStatus? status,
    String? kode,
    LacakResultEntity? result,
    String? error,
    List<TitikRute>? rute,
  }) {
    return LacakState(
      status: status ?? this.status,
      kode: kode ?? this.kode,
      result: result ?? this.result,
      error: error,
      rute: rute ?? this.rute,
    );
  }

  @override
  List<Object?> get props => [status, kode, result, error, rute];
}
