import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/pengiriman/berkas_entity.dart';
import '../../logic/pantau_logic.dart';

enum PantauStatus { loading, loaded, failure }

class PantauState extends Equatable {
  final PantauStatus status;

  /// Semua berkas milik NIP login (dari `GET daftar`).
  final List<BerkasEntity> semua;
  final PantauFilter filter;
  final String query;
  final String? error;

  /// Terisi = data offline terakhir (gagal memuat dari server).
  final DateTime? tglCache;

  const PantauState({
    this.status = PantauStatus.loading,
    this.semua = const [],
    this.filter = PantauFilter.semua,
    this.query = '',
    this.error,
    this.tglCache,
  });

  List<BerkasEntity> get items => PantauLogic.filter(semua, filter, query);

  Map<PantauFilter, int> get jumlah => PantauLogic.hitung(semua);

  PantauState copyWith({
    PantauStatus? status,
    List<BerkasEntity>? semua,
    PantauFilter? filter,
    String? query,
    String? error,
    DateTime? tglCache,
    bool aturCache = false,
  }) {
    return PantauState(
      status: status ?? this.status,
      semua: semua ?? this.semua,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      // Error di-reset tiap kali tidak diisi eksplisit.
      error: error,
      tglCache: aturCache ? tglCache : this.tglCache,
    );
  }

  @override
  List<Object?> get props => [status, semua, filter, query, error, tglCache];
}
