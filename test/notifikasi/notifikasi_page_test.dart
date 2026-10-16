import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/domain/entities/notifikasi/notifikasi_entity.dart';
import 'package:bapendacore/domain/repositories/notifikasi/i_notifikasi_repository.dart';
import 'package:bapendacore/domain/usecases/notifikasi/notifikasi_usecase.dart';
import 'package:bapendacore/presentation/features/notifikasi/cubit/notifikasi_cubit.dart';
import 'package:bapendacore/presentation/features/notifikasi/pages/notifikasi_page.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements INotifikasiRepository {
  Either<Failure, HalamanNotifikasiEntity> inbox;
  int bacaSemuaDipanggil = 0;

  _Repo(this.inbox);

  @override
  Future<Either<Failure, HalamanNotifikasiEntity>> getInbox({
    int page = 1,
    int pageSize = 20,
    bool hanyaBelumDibaca = false,
  }) async => inbox;

  @override
  Future<Either<Failure, int>> bacaSemua() async {
    bacaSemuaDipanggil++;
    return const Right(1);
  }

  @override
  Future<Either<Failure, int>> baca(int id) async => const Right(1);

  @override
  Stream<void> get perubahan => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pasang(WidgetTester tester, _Repo repo) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider(
        key: UniqueKey(),
        create: (_) => NotifikasiCubit(NotifikasiUseCase(repo))..load(),
        child: const NotifikasiPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('daftar + tandai semua dibaca', (tester) async {
    final repo = _Repo(
      const Right(
        HalamanNotifikasiEntity(
          items: [
            NotifikasiEntity(
              id: 1,
              kodeJenis: 'LAIN',
              namaJenis: 'Info',
              judul: 'Pengumuman',
              isi: 'Rapat jam 9',
              dibaca: false,
            ),
          ],
          page: 1,
          totalPage: 1,
          totalData: 1,
        ),
      ),
    );
    await _pasang(tester, repo);

    expect(find.text('Pengumuman'), findsOneWidget);
    await tester.tap(find.byTooltip('Tandai semua dibaca'));
    await tester.pumpAndSettle();
    expect(repo.bacaSemuaDipanggil, 1);
    // Tidak ada yang belum dibaca lagi: tombol hilang.
    expect(find.byTooltip('Tandai semua dibaca'), findsNothing);
  });

  testWidgets('kosong & gagal', (tester) async {
    final repo = _Repo(
      const Right(
        HalamanNotifikasiEntity(items: [], page: 1, totalPage: 1, totalData: 0),
      ),
    );
    await _pasang(tester, repo);
    expect(find.text('Belum ada notifikasi.'), findsOneWidget);

    repo.inbox = const Left(ServerFailure('Server sibuk'));
    await _pasang(tester, repo);
    expect(find.text('Server sibuk'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });
}
