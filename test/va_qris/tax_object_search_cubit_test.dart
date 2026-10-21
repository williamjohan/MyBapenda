import 'dart:async';

import 'package:mybapenda/core/errors/failure.dart';
import 'package:mybapenda/domain/entities/va_qris/tax_object_entity.dart';
import 'package:mybapenda/domain/repositories/va_qris/i_va_qris_repository.dart';
import 'package:mybapenda/domain/usecases/va_qris/va_qris_usecase.dart';
import 'package:mybapenda/presentation/features/va_qris/cubit/tax_object_search_cubit.dart';
import 'package:mybapenda/presentation/features/va_qris/cubit/tax_object_search_state.dart';
import 'package:mybapenda/presentation/shared/master_data/domain/entities/paged_master_entities.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

TaxObjectEntity _op(int i, {int jenis = 1}) => TaxObjectEntity(
  taxTypeId: jenis,
  taxTypeName: 'Pajak $jenis',
  nop: '35.78.051.002.902.${i.toString().padLeft(5, '0')}',
  name: 'WARUNG $i',
  address: 'JL. MULYOREJO $i',
);

const _counts = [
  TaxTypeCountEntity(taxTypeId: 4, taxTypeName: 'Pajak Jasa Parkir', count: 6),
  TaxTypeCountEntity(taxTypeId: 1, taxTypeName: 'Pajak Resto', count: 5),
];

TaxObjectSearchResultEntity _result(
  int page,
  int totalPage,
  int from, {
  int jenis = 1,
}) => TaxObjectSearchResultEntity(
  page: PagedResultEntity(
    items: [
      _op(from, jenis: jenis),
      _op(from + 1, jenis: jenis),
    ],
    currentPage: page,
    totalPage: totalPage,
    totalData: totalPage * 2,
  ),
  typeCounts: _counts,
);

/// Hanya `searchObjects` yang dipakai cubit ini. Hasil dipilih per halaman
/// (`semua|halaman`; API selalu mengembalikan semua jenis pajak).
class _FakeRepository implements IVaQrisRepository {
  final Map<String, Either<Failure, TaxObjectSearchResultEntity>> results = {};
  final List<String> calls = [];

  /// Diisi agar request menggantung sampai di-complete oleh test.
  Completer<void>? gate;

  @override
  Future<Either<Failure, TaxObjectSearchResultEntity>> searchObjects({
    required String keyword,
    required int page,
    required int pageSize,
  }) async {
    calls.add('$keyword|$page|$pageSize|semua');
    if (gate != null) await gate!.future;
    return results['semua|$page']!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeRepository repository;
  late TaxObjectSearchCubit cubit;

  setUp(() {
    repository = _FakeRepository();
    cubit = TaxObjectSearchCubit(VaQrisUseCase(repository));
  });

  tearDown(() => cubit.close());

  test('keyword < 3 huruf: tidak memanggil API, tampil pesan', () async {
    await cubit.search(' ab ');

    expect(repository.calls, isEmpty);
    expect(cubit.state.status, TaxObjectSearchStatus.initial);
    expect(
      cubit.state.errorMessage,
      'Ketik minimal 3 huruf nama atau alamat objek pajak.',
    );
  });

  test(
    'sukses: loading → success, spasi dirapikan, jumlah per jenis',
    () async {
      repository.results['semua|1'] = Right(_result(1, 2, 1));
      final states = expectLater(
        cubit.stream.map((s) => s.status),
        emitsInOrder([
          TaxObjectSearchStatus.loading,
          TaxObjectSearchStatus.success,
        ]),
      );

      await cubit.search('  warung   mulyorejo ');
      await states;

      expect(repository.calls.single, 'warung mulyorejo|1|100|semua');
      expect(cubit.state.keyword, 'warung mulyorejo');
      expect(cubit.state.items, [_op(1), _op(2)]);
      expect(cubit.state.totalData, 4);
      expect(cubit.state.hasMore, isTrue);
      expect(cubit.state.typeCounts, _counts);
      expect(cubit.state.totalAllTypes, 11);
      expect(cubit.state.taxTypeFilter, isNull);
      expect(cubit.state.errorMessage, isNull);
    },
  );

  test('gagal: status failure dengan pesan, retry mengulang keyword', () async {
    repository.results['semua|1'] = const Left(NoInternetFailure());

    await cubit.search('warung');
    expect(cubit.state.status, TaxObjectSearchStatus.failure);
    expect(cubit.state.errorMessage, const NoInternetFailure().message);

    repository.results['semua|1'] = Right(_result(1, 1, 1));
    await cubit.retry();

    expect(repository.calls, ['warung|1|100|semua', 'warung|1|100|semua']);
    expect(cubit.state.status, TaxObjectSearchStatus.success);
    expect(cubit.state.errorMessage, isNull);
  });

  test('retry sebelum pernah mencari: tidak memanggil API', () async {
    await cubit.retry();

    expect(repository.calls, isEmpty);
  });

  group('filter jenis pajak (di HP, tanpa memanggil API)', () {
    /// Halaman 1: 2 objek Resto (1) + 1 Parkir (4); halaman 2: 1 Parkir.
    TaxObjectSearchResultEntity campur(int page, List<TaxObjectEntity> items) =>
        TaxObjectSearchResultEntity(
          page: PagedResultEntity(
            items: items,
            currentPage: page,
            totalPage: 2,
            totalData: 4,
          ),
          typeCounts: const [
            TaxTypeCountEntity(taxTypeId: 1, taxTypeName: 'Resto', count: 2),
            TaxTypeCountEntity(taxTypeId: 4, taxTypeName: 'Parkir', count: 2),
          ],
        );

    setUp(() {
      repository.results['semua|1'] = Right(
        campur(1, [_op(1), _op(2), _op(3, jenis: 4)]),
      );
      repository.results['semua|2'] = Right(campur(2, [_op(4, jenis: 4)]));
    });

    test(
      'menyaring data yang sudah dimuat, API tidak dipanggil lagi',
      () async {
        await cubit.search('mulyorejo');

        cubit.filter(4);

        expect(repository.calls, ['mulyorejo|1|100|semua']);
        expect(cubit.state.status, TaxObjectSearchStatus.success);
        expect(cubit.state.taxTypeFilter, 4);
        expect(cubit.state.visibleItems, [_op(3, jenis: 4)]);
        expect(cubit.state.visibleTotal, 2);
        // Data semua jenis tetap tersimpan
        expect(cubit.state.items, hasLength(3));
      },
    );

    test('kembali ke "Semua" (null)', () async {
      await cubit.search('mulyorejo');
      cubit.filter(4);

      cubit.filter(null);

      expect(cubit.state.taxTypeFilter, isNull);
      expect(cubit.state.visibleItems, hasLength(3));
      expect(cubit.state.visibleTotal, 4);
      expect(repository.calls, hasLength(1));
    });

    test('loadMore memuat semua jenis, filter langsung diterapkan', () async {
      await cubit.search('mulyorejo');
      cubit.filter(4);

      await cubit.loadMore();

      expect(repository.calls.last, 'mulyorejo|2|100|semua');
      expect(cubit.state.items, hasLength(4));
      expect(cubit.state.visibleItems, [_op(3, jenis: 4), _op(4, jenis: 4)]);
      expect(cubit.state.hasMore, isFalse);
    });

    test('filter sama / belum ada hasil: tidak berubah', () async {
      cubit.filter(4);
      expect(cubit.state.taxTypeFilter, isNull);

      await cubit.search('mulyorejo');
      final before = cubit.state;
      cubit.filter(null);
      expect(cubit.state, same(before));
    });

    test('cari ulang mengembalikan filter ke "Semua"', () async {
      await cubit.search('mulyorejo');
      cubit.filter(4);

      await cubit.search('mulyorejo');

      expect(cubit.state.taxTypeFilter, isNull);
    });

    test('jenis pajak tanpa jumlah di perJenisPajak: total = yang dimuat', () {
      final state = TaxObjectSearchState(
        status: TaxObjectSearchStatus.success,
        items: [_op(1), _op(2, jenis: 9)],
        taxTypeFilter: 9,
      );

      expect(state.visibleTotal, 1);
    });
  });

  test('loadMore menambah halaman berikutnya', () async {
    repository.results['semua|1'] = Right(_result(1, 2, 1));
    repository.results['semua|2'] = Right(_result(2, 2, 3));
    await cubit.search('warung');

    await cubit.loadMore();

    expect(repository.calls.last, 'warung|2|100|semua');
    expect(cubit.state.items, [_op(1), _op(2), _op(3), _op(4)]);
    expect(cubit.state.hasMore, isFalse);
    expect(cubit.state.loadingMore, isFalse);
  });

  test('loadMore saat tidak ada halaman lagi: tidak memanggil API', () async {
    repository.results['semua|1'] = Right(_result(1, 1, 1));
    await cubit.search('warung');

    await cubit.loadMore();

    expect(repository.calls, hasLength(1));
  });

  test('loadMore gagal: tanda gagal, data lama tetap', () async {
    repository.results['semua|1'] = Right(_result(1, 2, 1));
    repository.results['semua|2'] = const Left(TimeoutFailure());
    await cubit.search('warung');

    await cubit.loadMore();

    expect(cubit.state.loadMoreFailed, isTrue);
    expect(cubit.state.items, hasLength(2));
    expect(cubit.state.status, TaxObjectSearchStatus.success);
  });

  test('loadMore dobel saat masih memuat: API dipanggil sekali', () async {
    repository.results['semua|1'] = Right(_result(1, 3, 1));
    repository.results['semua|2'] = Right(_result(2, 3, 3));
    await cubit.search('warung');
    repository.gate = Completer<void>();

    final first = cubit.loadMore();
    await cubit.loadMore();
    repository.gate!.complete();
    await first;

    expect(repository.calls.where((c) => c.contains('|2|100|')), hasLength(1));
  });

  test('jawaban pencarian lama diabaikan', () async {
    repository.gate = Completer<void>();
    repository.results['semua|1'] = Right(_result(1, 1, 1));
    final lama = cubit.search('warung');

    // Pencarian baru dengan keyword terlalu pendek membatalkan yang lama
    await cubit.search('wa');
    repository.gate!.complete();
    await lama;

    expect(cubit.state.status, TaxObjectSearchStatus.initial);
    expect(cubit.state.items, isEmpty);
  });

  test('Cubit ditutup sebelum response datang: tidak emit', () async {
    repository.gate = Completer<void>();
    repository.results['semua|1'] = Right(_result(1, 1, 1));
    final future = cubit.search('warung');
    await cubit.close();
    repository.gate!.complete();

    await expectLater(future, completes);
    expect(cubit.state.status, TaxObjectSearchStatus.loading);
  });
}
