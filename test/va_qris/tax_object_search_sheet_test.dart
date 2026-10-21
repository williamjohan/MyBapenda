import 'dart:async';

import 'package:mybapenda/core/constants/design_system/tokens/app_theme.dart';
import 'package:mybapenda/core/errors/failure.dart';
import 'package:mybapenda/domain/entities/va_qris/recent_reference_entity.dart';
import 'package:mybapenda/domain/entities/va_qris/tax_object_entity.dart';
import 'package:mybapenda/domain/repositories/va_qris/i_va_qris_repository.dart';
import 'package:mybapenda/domain/usecases/va_qris/va_qris_usecase.dart';
import 'package:mybapenda/presentation/features/va_qris/cubit/tax_object_search_cubit.dart';
import 'package:mybapenda/presentation/features/va_qris/widgets/nop/tax_object_search_sheet.dart';
import 'package:mybapenda/presentation/shared/master_data/domain/entities/paged_master_entities.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';

const _laundry = TaxObjectEntity(
  taxTypeId: 6,
  taxTypeName: 'Pajak Air Tanah',
  nop: '35.78.051.002.908.01977',
  name: 'CENTRAL LAUNDRY SURABAYA',
  address: 'MULYOREJO No.24',
);

const _parkir = TaxObjectEntity(
  taxTypeId: 4,
  taxTypeName: 'Pajak Jasa Parkir',
  nop: '35.78.051.002.904.00010',
  name: 'PARKIR MULYOREJO',
  address: 'MULYOREJO No.1',
);

final _recent = RecentReferenceEntity(
  taxTypeId: 1,
  taxTypeName: 'Pajak Makanan & Minuman',
  referenceNumber: '35.78.051.002.902.00282',
  name: 'ALMAZ FRIED CHICKEN MULYOREJO',
  savedAt: DateTime(2026, 10, 15),
);

const _counts = [
  TaxTypeCountEntity(taxTypeId: 4, taxTypeName: 'Pajak Jasa Parkir', count: 6),
  TaxTypeCountEntity(taxTypeId: 6, taxTypeName: 'Pajak Air Tanah', count: 1),
];

class _FakeRepository implements IVaQrisRepository {
  Either<Failure, TaxObjectSearchResultEntity> result = const Right(
    TaxObjectSearchResultEntity(
      page: PagedResultEntity(
        items: [_laundry],
        currentPage: 1,
        totalPage: 1,
        totalData: 1,
      ),
      typeCounts: _counts,
    ),
  );
  final List<String> keywords = [];

  /// Diisi agar pencarian menggantung (untuk melihat skeleton).
  Completer<void>? gate;

  @override
  Future<Either<Failure, TaxObjectSearchResultEntity>> searchObjects({
    required String keyword,
    required int page,
    required int pageSize,
  }) async {
    keywords.add(keyword);
    if (gate != null) await gate!.future;
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Halaman uji: tombol membuka sheet (cubit disuntik), hasil pilihan dicatat.
Future<List<ReferencePick?>> _pump(
  WidgetTester tester,
  _FakeRepository repository, {
  List<RecentReferenceEntity> recent = const [],
}) async {
  final picks = <ReferencePick?>[];
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.app,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                final pick = await showModalBottomSheet<ReferencePick>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => BlocProvider(
                    create: (_) =>
                        TaxObjectSearchCubit(VaQrisUseCase(repository)),
                    child: TaxObjectSearchSheet(recent: recent),
                  ),
                );
                picks.add(pick);
              },
              child: const Text('buka'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('buka'));
  await tester.pumpAndSettle();
  return picks;
}

/// `Skeletonizer` dibuat lewat factory (tipe aslinya privat).
final _skeleton = find.byWidgetPredicate((w) => w is Skeletonizer);

void main() {
  testWidgets('belum mencari: tampil riwayat, diketuk mengembalikan pilihan', (
    tester,
  ) async {
    final picks = await _pump(tester, _FakeRepository(), recent: [_recent]);

    expect(find.text('Terakhir dicari'), findsOneWidget);
    await tester.tap(find.text('ALMAZ FRIED CHICKEN MULYOREJO'));
    await tester.pumpAndSettle();

    expect(picks.single, (
      taxTypeId: 1,
      referenceNumber: '35.78.051.002.902.00282',
    ));
  });

  testWidgets('keyword pendek: pesan validasi, API tidak dipanggil', (
    tester,
  ) async {
    final repository = _FakeRepository();
    await _pump(tester, repository);

    await tester.enterText(find.byType(TextField), 'ab');
    await tester.tap(find.text('Cari'));
    await tester.pumpAndSettle();

    expect(
      find.text('Ketik minimal 3 huruf nama atau alamat objek pajak.'),
      findsOneWidget,
    );
    expect(repository.keywords, isEmpty);
  });

  testWidgets('cari lewat tombol: hasil tampil, diketuk mengembalikan NOP', (
    tester,
  ) async {
    final repository = _FakeRepository();
    final picks = await _pump(tester, repository);

    await tester.enterText(find.byType(TextField), 'laundry');
    await tester.tap(find.text('Cari'));
    await tester.pumpAndSettle();

    expect(repository.keywords.single, 'laundry');
    expect(find.text('1 objek pajak ditemukan'), findsOneWidget);
    expect(find.text('NOP 35.78.051.002.908.01977'), findsOneWidget);
    // Chip filter + chip jenis pajak di kartu hasil
    expect(find.text('Air Tanah'), findsNWidgets(2));

    await tester.tap(find.text('CENTRAL LAUNDRY SURABAYA'));
    await tester.pumpAndSettle();

    expect(picks.single, (
      taxTypeId: 6,
      referenceNumber: '35.78.051.002.908.01977',
    ));
  });

  testWidgets('tidak ditemukan & gagal tampil pesan yang sesuai', (
    tester,
  ) async {
    final repository = _FakeRepository()
      ..result = const Right(
        TaxObjectSearchResultEntity(
          page: PagedResultEntity(
            items: [],
            currentPage: 1,
            totalPage: 0,
            totalData: 0,
          ),
          typeCounts: [],
        ),
      );
    await _pump(tester, repository);

    await tester.enterText(find.byType(TextField), 'zzzqqq');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Objek pajak tidak ditemukan'), findsOneWidget);

    repository.result = const Left(NoInternetFailure());
    await tester.tap(find.text('Cari'));
    await tester.pumpAndSettle();
    expect(find.text('Gagal mencari'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('selama mencari tampil skeleton, bukan spinner', (tester) async {
    final repository = _FakeRepository()..gate = Completer<void>();
    await _pump(tester, repository);

    await tester.enterText(find.byType(TextField), 'laundry');
    await tester.tap(find.text('Cari'));
    await tester.pump();

    expect(_skeleton, findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    repository.gate!.complete();
    await tester.pumpAndSettle();
    expect(_skeleton, findsNothing);
    expect(find.text('CENTRAL LAUNDRY SURABAYA'), findsOneWidget);
  });

  testWidgets('chip filter jenis pajak: menyaring di HP tanpa memanggil API', (
    tester,
  ) async {
    final repository = _FakeRepository()
      ..result = const Right(
        TaxObjectSearchResultEntity(
          page: PagedResultEntity(
            items: [_laundry, _parkir],
            currentPage: 1,
            totalPage: 1,
            totalData: 7,
          ),
          typeCounts: _counts,
        ),
      );
    await _pump(tester, repository);

    // Belum mencari: belum ada chip
    expect(find.text('Semua'), findsNothing);

    await tester.enterText(find.byType(TextField), 'mulyorejo');
    await tester.tap(find.text('Cari'));
    await tester.pumpAndSettle();

    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('7'), findsOneWidget); // 6 + 1
    expect(find.text('6'), findsOneWidget);
    expect(find.text('CENTRAL LAUNDRY SURABAYA'), findsOneWidget);
    expect(find.text('PARKIR MULYOREJO'), findsOneWidget);

    await tester.tap(find.text('Parkir').first);
    await tester.pumpAndSettle();

    expect(repository.keywords, ['mulyorejo']);
    expect(find.text('6 objek pajak ditemukan'), findsOneWidget);
    expect(find.text('PARKIR MULYOREJO'), findsOneWidget);
    expect(find.text('CENTRAL LAUNDRY SURABAYA'), findsNothing);
  });

  testWidgets('difilter & masih ada halaman: info dan tombol muat berikutnya', (
    tester,
  ) async {
    final repository = _FakeRepository()
      ..result = const Right(
        TaxObjectSearchResultEntity(
          page: PagedResultEntity(
            items: [_laundry, _parkir],
            currentPage: 1,
            totalPage: 2,
            totalData: 7,
          ),
          typeCounts: _counts,
        ),
      );
    await _pump(tester, repository);

    await tester.enterText(find.byType(TextField), 'mulyorejo');
    await tester.tap(find.text('Cari'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Parkir').first);
    await tester.pumpAndSettle();

    expect(find.text('Menampilkan 1 dari 6'), findsOneWidget);
    await tester.tap(find.text('Muat berikutnya'));
    await tester.pumpAndSettle();

    expect(repository.keywords, ['mulyorejo', 'mulyorejo']);
  });
}
