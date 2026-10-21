import 'dart:async';
import 'package:mybapenda/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/paged_master_entities.dart';

typedef PageFetcher<E> =
    Future<Either<Failure, PagedResultEntity<E>>> Function({
      required String keyword,
      required int page,
      required int pageSize,
    });

enum PagedStatus {
  initial,
  idle,
  loading,
  success,
  failure,
}

class PagedSearchState<E> extends Equatable {
  final String keyword;
  final List<E> items;
  final PagedStatus status;

  /// Halaman terakhir yang sudah dimuat.
  final int page;
  final int totalData;
  final bool hasMore;
  final bool loadingMore;
  final bool loadMoreFailed;
  final String? error;

  const PagedSearchState({
    required this.items,
    this.keyword = '',
    this.status = PagedStatus.initial,
    this.page = 0,
    this.totalData = 0,
    this.hasMore = false,
    this.loadingMore = false,
    this.loadMoreFailed = false,
    this.error,
  });

  factory PagedSearchState.empty([PagedStatus status = PagedStatus.initial]) =>
      PagedSearchState<E>(items: <E>[], status: status);

  PagedSearchState<E> copyWith({
    String? keyword,
    List<E>? items,
    PagedStatus? status,
    int? page,
    int? totalData,
    bool? hasMore,
    bool? loadingMore,
    bool? loadMoreFailed,
    ValueGetter<String?>? error,
  }) => PagedSearchState<E>(
    keyword: keyword ?? this.keyword,
    items: items ?? this.items,
    status: status ?? this.status,
    page: page ?? this.page,
    totalData: totalData ?? this.totalData,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    error: error != null ? error() : this.error,
  );

  @override
  List<Object?> get props => [
    keyword,
    items,
    status,
    page,
    totalData,
    hasMore,
    loadingMore,
    loadMoreFailed,
    error,
  ];
}

/// Pencarian + infinite scroll untuk master berhalaman (nama jalan, persil, ...).
///
/// - Request dikirim setelah user berhenti mengetik (debounce).
/// - Jawaban dari pencarian lama diabaikan.
/// - [minKeywordLength] > 0: tidak ada request sebelum keyword cukup panjang
///   (cocok untuk data sangat besar seperti persil).
class PagedSearchCubit<E> extends Cubit<PagedSearchState<E>> {
  static const Duration _debounceDuration = Duration(milliseconds: 400);

  final PageFetcher<E> _fetch;
  final Object Function(E item) _idOf;
  final int pageSize;
  final int minKeywordLength;
  final String errorMessage;

  Timer? _debounce;

  /// Penanda pencarian terbaru.
  int _requestId = 0;

  PagedSearchCubit(
    this._fetch, {
    required Object Function(E item) idOf,
    this.pageSize = 30,
    this.minKeywordLength = 0,
    this.errorMessage = 'Gagal memuat data.\nPeriksa koneksi lalu coba lagi.',
  }) : _idOf = idOf,
       super(PagedSearchState<E>.empty());

  /// Dipanggil saat sheet dibuka.
  void open() {
    _debounce?.cancel();

    if (minKeywordLength > 0) {
      // Selalu mulai dari kondisi "menunggu ketikan" (kolom cari sheet kosong).
      final fresh =
          state.status == PagedStatus.idle &&
          state.keyword.isEmpty &&
          state.items.isEmpty;
      if (!fresh) {
        _requestId++;
        emit(PagedSearchState<E>.empty(PagedStatus.idle));
      }
      return;
    }

    final needsLoad =
        state.keyword.isNotEmpty ||
        state.status == PagedStatus.initial ||
        state.status == PagedStatus.failure;
    if (needsLoad) unawaited(_search(''));
  }

  /// Dipanggil setiap user mengetik.
  void onQueryChanged(String query) {
    final keyword = query.trim();
    _debounce?.cancel();
    if (keyword == state.keyword) return;

    if (keyword.length < minKeywordLength) {
      _requestId++; 
      emit(
        PagedSearchState<E>.empty(PagedStatus.idle).copyWith(keyword: keyword),
      );
      return;
    }

    _debounce = Timer(_debounceDuration, () => unawaited(_search(keyword)));
  }

  void retry() => unawaited(_search(state.keyword));

  Future<void> _search(String keyword) async {
    final id = ++_requestId;
    emit(
      state.copyWith(
        keyword: keyword,
        status: PagedStatus.loading,
        loadingMore: false,
        loadMoreFailed: false,
        error: () => null,
      ),
    );

    final result = await _fetch(keyword: keyword, page: 1, pageSize: pageSize);
    if (isClosed || id != _requestId) return; // jawaban basi

    result.fold(
      (failure) {
        debugPrint('Pencarian "$keyword" gagal: $failure');
        emit(
          state.copyWith(
            status: PagedStatus.failure,
            items: <E>[],
            hasMore: false,
            totalData: 0,
            error: () => errorMessage,
          ),
        );
      },
      (page) => emit(
        state.copyWith(
          status: PagedStatus.success,
          items: page.items,
          page: page.currentPage,
          totalData: page.totalData,
          hasMore: page.hasMore,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.status != PagedStatus.success ||
        state.loadingMore ||
        state.loadMoreFailed ||
        !state.hasMore) {
      return;
    }

    final id = _requestId;
    final keyword = state.keyword;
    final nextPage = state.page + 1;
    emit(state.copyWith(loadingMore: true));

    final result = await _fetch(
      keyword: keyword,
      page: nextPage,
      pageSize: pageSize,
    );
    if (isClosed || id != _requestId) return;

    result.fold(
      (failure) {
        debugPrint('Halaman $nextPage gagal dimuat: $failure');
        emit(state.copyWith(loadingMore: false, loadMoreFailed: true));
      },
      (page) {
        final merged = {
          for (final e in [...state.items, ...page.items]) _idOf(e): e,
        }.values.toList();
        emit(
          state.copyWith(
            items: merged,
            page: page.currentPage,
            totalData: page.totalData,
            hasMore: page.hasMore,
            loadingMore: false,
          ),
        );
      },
    );
  }

  void retryLoadMore() {
    emit(state.copyWith(loadMoreFailed: false));
    unawaited(loadMore());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
