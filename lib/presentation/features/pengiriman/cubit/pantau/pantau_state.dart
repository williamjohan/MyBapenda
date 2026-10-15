import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/pengiriman/berkas_entity.dart';
import '../../utils/pantau_ui_helper.dart';

enum PantauStatus { loading, loaded, failure }

class PantauState extends Equatable {
  final PantauStatus status;

  /// Semua berkas milik NIP login (dari `GET daftar`).
  final List<BerkasEntity> semua;
  final String query;
  final String? error;

  /// Terisi = data offline terakhir (gagal memuat dari server).
  final DateTime? tglCache;

  const PantauState({
    this.status = PantauStatus.loading,
    this.semua = const [],
    this.query = '',
    this.error,
    this.tglCache,
  });

  Map<PantauFilter, int> get jumlah => PantauUiHelper.hitung(semua);

  PantauState copyWith({
    PantauStatus? status,
    List<BerkasEntity>? semua,
    String? query,
    String? error,
    DateTime? tglCache,
    bool aturCache = false,
  }) {
    return PantauState(
      status: status ?? this.status,
      semua: semua ?? this.semua,
      query: query ?? this.query,
      // Error di-reset tiap kali tidak diisi eksplisit.
      error: error,
      tglCache: aturCache ? tglCache : this.tglCache,
    );
  }

  @override
  List<Object?> get props => [status, semua, query, error, tglCache];
}
