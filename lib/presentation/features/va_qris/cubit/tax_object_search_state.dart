import 'package:equatable/equatable.dart';
import '../../../../domain/entities/va_qris/tax_object_entity.dart';

enum TaxObjectSearchStatus { initial, loading, success, failure }

class TaxObjectSearchState extends Equatable {
  const TaxObjectSearchState({
    this.status = TaxObjectSearchStatus.initial,
    this.keyword = '',
    this.items = const [],
    this.page = 0,
    this.totalData = 0,
    this.hasMore = false,
    this.loadingMore = false,
    this.loadMoreFailed = false,
    this.typeCounts = const [],
    this.taxTypeFilter,
    this.errorMessage,
  });

  final TaxObjectSearchStatus status;

  /// Keyword pencarian terakhir yang dikirim.
  final String keyword;

  /// Semua hasil yang sudah dimuat (semua jenis pajak). Yang tampil:
  /// [visibleItems].
  final List<TaxObjectEntity> items;
  final int page;

  /// Jumlah semua hasil untuk [keyword] (semua jenis pajak).
  final int totalData;
  final bool hasMore;
  final bool loadingMore;
  final bool loadMoreFailed;

  /// Jumlah hasil per jenis pajak untuk [keyword] (tanpa filter), untuk chip.
  final List<TaxTypeCountEntity> typeCounts;

  /// Jenis pajak yang sedang difilter (di HP, tanpa memanggil API);
  /// null = semua.
  final int? taxTypeFilter;

  /// Validasi keyword (status tetap initial) atau error pencarian (failure).
  final String? errorMessage;

  /// Jumlah semua hasil (chip "Semua").
  int get totalAllTypes => typeCounts.fold(0, (sum, c) => sum + c.count);

  /// Hasil yang sudah dimuat sesuai [taxTypeFilter].
  List<TaxObjectEntity> get visibleItems {
    final filter = taxTypeFilter;
    if (filter == null) return items;
    return items.where((o) => o.taxTypeId == filter).toList();
  }

  /// Jumlah semua hasil sesuai [taxTypeFilter] (dari [typeCounts]), termasuk
  /// yang belum dimuat.
  int get visibleTotal {
    final filter = taxTypeFilter;
    if (filter == null) return totalData;
    return typeCounts.where((c) => c.taxTypeId == filter).firstOrNull?.count ??
        visibleItems.length;
  }

  TaxObjectSearchState copyWith({
    TaxObjectSearchStatus? status,
    String? keyword,
    List<TaxObjectEntity>? items,
    int? page,
    int? totalData,
    bool? hasMore,
    bool? loadingMore,
    bool? loadMoreFailed,
    List<TaxTypeCountEntity>? typeCounts,
    int? Function()? taxTypeFilter,
    String? Function()? errorMessage,
  }) {
    return TaxObjectSearchState(
      status: status ?? this.status,
      keyword: keyword ?? this.keyword,
      items: items ?? this.items,
      page: page ?? this.page,
      totalData: totalData ?? this.totalData,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      typeCounts: typeCounts ?? this.typeCounts,
      taxTypeFilter: taxTypeFilter != null
          ? taxTypeFilter()
          : this.taxTypeFilter,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    keyword,
    items,
    page,
    totalData,
    hasMore,
    loadingMore,
    loadMoreFailed,
    typeCounts,
    taxTypeFilter,
    errorMessage,
  ];
}
