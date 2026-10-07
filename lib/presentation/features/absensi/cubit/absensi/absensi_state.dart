import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/absensi/riwayat_absensi_entity.dart';
import '../../../../../domain/entities/absensi/ringkasan_absensi_entity.dart';

enum AbsensiLoadStatus { initial, loading, loaded, failure }

class AbsensiState extends Equatable {
  final AbsensiLoadStatus ringkasanStatus;
  final RingkasanAbsensiEntity? ringkasan;
  final String? ringkasanError;

  final AbsensiLoadStatus riwayatStatus;
  final List<RiwayatAbsensiEntity> riwayat;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String? riwayatError;

  const AbsensiState({
    this.ringkasanStatus = AbsensiLoadStatus.initial,
    this.ringkasan,
    this.ringkasanError,
    this.riwayatStatus = AbsensiLoadStatus.initial,
    this.riwayat = const [],
    this.page = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.riwayatError,
  });

  AbsensiState copyWith({
    AbsensiLoadStatus? ringkasanStatus,
    RingkasanAbsensiEntity? ringkasan,
    String? ringkasanError,
    AbsensiLoadStatus? riwayatStatus,
    List<RiwayatAbsensiEntity>? riwayat,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? riwayatError,
  }) {
    return AbsensiState(
      ringkasanStatus: ringkasanStatus ?? this.ringkasanStatus,
      ringkasan: ringkasan ?? this.ringkasan,
      // Error di-reset tiap kali tidak diisi eksplisit.
      ringkasanError: ringkasanError,
      riwayatStatus: riwayatStatus ?? this.riwayatStatus,
      riwayat: riwayat ?? this.riwayat,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      riwayatError: riwayatError,
    );
  }

  @override
  List<Object?> get props => [
    ringkasanStatus,
    ringkasan,
    ringkasanError,
    riwayatStatus,
    riwayat,
    page,
    hasMore,
    isLoadingMore,
    riwayatError,
  ];
}
