import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/pengiriman/berkas_entity.dart';

enum DetailBerkasStatus { loading, loaded, failure }

class DetailBerkasState extends Equatable {
  final DetailBerkasStatus status;
  final BerkasDetailEntity? detail;
  final String? error;

  /// Terisi = data offline terakhir (gagal memuat dari server).
  final DateTime? tglCache;

  const DetailBerkasState({
    this.status = DetailBerkasStatus.loading,
    this.detail,
    this.error,
    this.tglCache,
  });

  DetailBerkasState copyWith({
    DetailBerkasStatus? status,
    BerkasDetailEntity? detail,
    String? error,
    DateTime? tglCache,
    bool aturCache = false,
  }) {
    return DetailBerkasState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      error: error,
      tglCache: aturCache ? tglCache : this.tglCache,
    );
  }

  @override
  List<Object?> get props => [status, detail, error, tglCache];
}
