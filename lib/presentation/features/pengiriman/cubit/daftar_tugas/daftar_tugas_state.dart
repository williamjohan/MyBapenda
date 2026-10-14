import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/pengiriman/berkas_entity.dart';
import '../../logic/tugas_tab_logic.dart';

enum DaftarTugasStatus { initial, loading, loaded, failure }

class DaftarTugasState extends Equatable {
  final DaftarTugasStatus status;

  /// Semua tugas dari server (sudah urut batas SLA).
  final List<BerkasEntity> semua;
  final TabTugas tab;
  final String query;
  final String? error;

  /// Terisi = data offline terakhir (gagal memuat dari server).
  final DateTime? tglCache;

  const DaftarTugasState({
    this.status = DaftarTugasStatus.initial,
    this.semua = const [],
    this.tab = TabTugas.ambil,
    this.query = '',
    this.error,
    this.tglCache,
  });

  List<BerkasEntity> get items => TugasTabLogic.filter(semua, tab, query);

  /// Badge per tab; null selama belum pernah termuat.
  Map<TabTugas, int>? get jumlah =>
      status == DaftarTugasStatus.loaded || semua.isNotEmpty
      ? TugasTabLogic.hitung(semua)
      : null;

  DaftarTugasState copyWith({
    DaftarTugasStatus? status,
    List<BerkasEntity>? semua,
    TabTugas? tab,
    String? query,
    String? error,
    DateTime? tglCache,
    bool aturCache = false,
  }) {
    return DaftarTugasState(
      status: status ?? this.status,
      semua: semua ?? this.semua,
      tab: tab ?? this.tab,
      query: query ?? this.query,
      // Error di-reset tiap kali tidak diisi eksplisit.
      error: error,
      tglCache: aturCache ? tglCache : this.tglCache,
    );
  }

  @override
  List<Object?> get props => [status, semua, tab, query, error, tglCache];
}
