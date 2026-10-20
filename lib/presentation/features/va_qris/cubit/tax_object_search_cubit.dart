import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/va_qris_constants.dart';
import '../../../../domain/usecases/va_qris/va_qris_usecase.dart';
import 'tax_object_search_state.dart';

/// "Cari objek pajak" di sheet Create VA & QRIS. Pencarian dikirim saat
/// tombol Cari ditekan (tanpa debounce); hasil difilter per jenis pajak di HP
/// dari data yang sudah dimuat (tanpa memanggil API lagi) dan scroll ke bawah
/// memuat halaman berikutnya. Jawaban dari pencarian lama diabaikan.
@injectable
class TaxObjectSearchCubit extends Cubit<TaxObjectSearchState> {
  final VaQrisUseCase _useCase;

  TaxObjectSearchCubit(this._useCase) : super(const TaxObjectSearchState());

  /// Maksimal dari API, supaya umumnya semua hasil termuat sekali panggil
  /// dan filter jenis pajak langsung lengkap.
  static const int pageSize = 100;

  /// Penanda pencarian terbaru.
  int _requestId = 0;

  /// Pencarian baru: filter jenis pajak kembali ke "Semua".
  Future<void> search(String query) async {
    final keyword = query.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (keyword.length < kTaxObjectMinKeyword) {
      _requestId++;
      emit(
        TaxObjectSearchState(
          keyword: keyword,
          errorMessage:
              'Ketik minimal $kTaxObjectMinKeyword huruf nama atau alamat '
              'objek pajak.',
        ),
      );
      return;
    }

    emit(
      TaxObjectSearchState(
        status: TaxObjectSearchStatus.loading,
        keyword: keyword,
      ),
    );
    await _loadFirstPage();
  }

  /// Filter hasil per jenis pajak (null = semua) dari data yang sudah dimuat.
  void filter(int? taxTypeId) {
    if (state.status != TaxObjectSearchStatus.success ||
        taxTypeId == state.taxTypeFilter) {
      return;
    }
    emit(state.copyWith(taxTypeFilter: () => taxTypeId));
  }

  Future<void> retry() async {
    if (state.keyword.length < kTaxObjectMinKeyword) return;
    emit(
      state.copyWith(
        status: TaxObjectSearchStatus.loading,
        errorMessage: () => null,
      ),
    );
    await _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    final id = ++_requestId;
    final res = await _useCase.searchObjects(
      keyword: state.keyword,
      page: 1,
      pageSize: pageSize,
    );
    if (isClosed || id != _requestId) return; // jawaban basi

    res.fold(
      (f) => emit(
        state.copyWith(
          status: TaxObjectSearchStatus.failure,
          errorMessage: () => f.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          status: TaxObjectSearchStatus.success,
          items: result.page.items,
          page: result.page.currentPage,
          totalData: result.page.totalData,
          hasMore: result.page.hasMore,
          typeCounts: result.typeCounts,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.status != TaxObjectSearchStatus.success ||
        !state.hasMore ||
        state.loadingMore) {
      return;
    }

    final id = _requestId;
    emit(state.copyWith(loadingMore: true, loadMoreFailed: false));

    final res = await _useCase.searchObjects(
      keyword: state.keyword,
      page: state.page + 1,
      pageSize: pageSize,
    );
    if (isClosed || id != _requestId) return;

    res.fold(
      (f) {
        AppLogger.warning('Muat objek pajak berikutnya gagal: $f');
        emit(state.copyWith(loadingMore: false, loadMoreFailed: true));
      },
      (result) => emit(
        state.copyWith(
          items: [...state.items, ...result.page.items],
          page: result.page.currentPage,
          totalData: result.page.totalData,
          hasMore: result.page.hasMore,
          loadingMore: false,
        ),
      ),
    );
  }
}
