import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/domain/entities/pengiriman/antrean_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/berkas_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/lacak_entity.dart';
import 'package:bapendacore/domain/usecases/pengiriman/pengiriman_usecase.dart';
import 'package:bapendacore/presentation/features/pengiriman/cubit/daftar_tugas/daftar_tugas_cubit.dart';
import 'package:bapendacore/presentation/features/pengiriman/cubit/daftar_tugas/daftar_tugas_state.dart';
import 'package:bapendacore/presentation/features/pengiriman/cubit/detail_berkas/detail_berkas_cubit.dart';
import 'package:bapendacore/presentation/features/pengiriman/cubit/detail_berkas/detail_berkas_state.dart';
import 'package:bapendacore/presentation/features/pengiriman/cubit/lacak/lacak_cubit.dart';
import 'package:bapendacore/presentation/features/pengiriman/cubit/lacak/lacak_state.dart';
import 'package:bapendacore/presentation/features/pengiriman/cubit/pantau/pantau_cubit.dart';
import 'package:bapendacore/presentation/features/pengiriman/cubit/pantau/pantau_state.dart';
import 'package:bapendacore/presentation/features/pengiriman/utils/pantau_ui_helper.dart';
import 'package:bapendacore/presentation/features/pengiriman/utils/tugas_tab_ui_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pengiriman_fakes.dart';

BerkasDetailEntity _detail(StatusBerkas s, List<AksiBerkas> aksi) =>
    BerkasDetailEntity(
      berkas: berkas(status: s, aksi: aksi),
    );

void main() {
  late FakePengirimanRepository repo;
  late PengirimanUseCase useCase;

  setUp(() {
    repo = FakePengirimanRepository();
    useCase = PengirimanUseCase(repo);
  });

  group('DaftarTugasCubit (Pengiriman Surat)', () {
    test('muat: loading → loaded, badge per tab', () async {
      final cubit = DaftarTugasCubit(useCase);
      final load = cubit.load();
      expect(cubit.state.status, DaftarTugasStatus.loading);
      expect(cubit.state.jumlah, isNull);

      repo.daftar.single.complete(
        Right(
          HasilBacaEntity([
            berkas(noResi: 'A'),
            berkas(noResi: 'B', status: StatusBerkas.tiba),
          ]),
        ),
      );
      await load;

      expect(cubit.state.status, DaftarTugasStatus.loaded);
      expect(cubit.state.jumlah, {
        TabTugas.ambil: 1,
        TabTugas.diantar: 1,
        TabTugas.gagal: 0,
      });
      await cubit.close();
    });

    test('refresh gagal: daftar lama tetap ada + pesan error', () async {
      final cubit = DaftarTugasCubit(useCase);
      final pertama = cubit.load();
      repo.daftar[0].complete(Right(HasilBacaEntity([berkas(noResi: 'A')])));
      await pertama;

      final kedua = cubit.load();
      expect(cubit.state.status, DaftarTugasStatus.loaded);
      repo.daftar[1].complete(const Left(NoInternetFailure()));
      await kedua;

      expect(cubit.state.status, DaftarTugasStatus.failure);
      expect(cubit.state.semua.single.noResi, 'A');
      expect(cubit.state.error, const NoInternetFailure().message);
      await cubit.close();
    });

    test('data offline: tanggal cache ikut ke state', () async {
      final cubit = DaftarTugasCubit(useCase);
      final tgl = DateTime(2026, 10, 15, 8);
      final load = cubit.load();
      repo.daftar.single.complete(
        Right(HasilBacaEntity([berkas()], tglCache: tgl)),
      );
      await load;

      expect(cubit.state.tglCache, tgl);
      await cubit.close();
    });

    test('respons lama tidak menimpa respons baru', () async {
      final cubit = DaftarTugasCubit(useCase);
      final lama = cubit.load();
      final baru = cubit.load();
      repo.daftar[1].complete(Right(HasilBacaEntity([berkas(noResi: 'B')])));
      await baru;
      repo.daftar[0].complete(Right(HasilBacaEntity([berkas(noResi: 'A')])));
      await lama;

      expect(cubit.state.semua.single.noResi, 'B');
      await cubit.close();
    });

    test('cari: query dirapikan, tidak emit ulang bila sama', () async {
      final cubit = DaftarTugasCubit(useCase);
      final states = <DaftarTugasState>[];
      final sub = cubit.stream.listen(states.add);

      cubit
        ..search('  maju ')
        ..search('maju');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.query, 'maju');
      expect(states, hasLength(1));
      await sub.cancel();
      await cubit.close();
    });
  });

  group('PantauCubit (Pantau Surat Pengiriman)', () {
    test('muat: jumlah per filter, terlambat masuk Perlu Perhatian', () async {
      final cubit = PantauCubit(useCase);
      final load = cubit.load();
      expect(cubit.state.status, PantauStatus.loading);
      repo.daftar.single.complete(
        Right(
          HasilBacaEntity([
            berkas(noResi: 'A'),
            berkas(
              noResi: 'B',
              status: StatusBerkas.dalamPerjalanan,
              terlambat: true,
            ),
          ]),
        ),
      );
      await load;

      expect(cubit.state.status, PantauStatus.loaded);
      expect(cubit.state.jumlah[PantauFilter.semua], 2);
      expect(cubit.state.jumlah[PantauFilter.menunggu], 1);
      expect(cubit.state.jumlah[PantauFilter.diantar], 1);
      expect(cubit.state.jumlah[PantauFilter.bermasalah], 1);
      await cubit.close();
    });

    test('gagal pertama kali: status failure, daftar kosong', () async {
      final cubit = PantauCubit(useCase);
      final load = cubit.load();
      repo.daftar.single.complete(const Left(ServerFailure('Server error')));
      await load;

      expect(cubit.state.status, PantauStatus.failure);
      expect(cubit.state.semua, isEmpty);
      expect(cubit.state.error, 'Server error');
      await cubit.close();
    });

    test('respons lama tidak menimpa respons baru', () async {
      final cubit = PantauCubit(useCase);
      final lama = cubit.load();
      final baru = cubit.load();
      repo.daftar[1].complete(Right(HasilBacaEntity([berkas(noResi: 'B')])));
      await baru;
      repo.daftar[0].complete(const Left(TimeoutFailure()));
      await lama;

      expect(cubit.state.status, PantauStatus.loaded);
      expect(cubit.state.semua.single.noResi, 'B');
      await cubit.close();
    });
  });

  group('LacakCubit', () {
    test('kode kosong diabaikan; kode dirapikan', () async {
      final cubit = LacakCubit(useCase);
      await cubit.lacak('   ');
      expect(repo.lacak, isEmpty);

      final f = cubit.lacak(' SKB1 ');
      expect(repo.lacak.single.kode, 'SKB1');
      expect(cubit.state.status, LacakStatus.loading);
      repo.lacak.single.c.complete(
        const Right(LacakResultEntity(noResi: 'SKB1', tugasSaya: true)),
      );
      await f;

      expect(cubit.state.status, LacakStatus.loaded);
      expect(cubit.state.result!.tugasSaya, isTrue);
      await cubit.close();
    });

    test('refresh kode sama: hasil lama tetap tampil saat memuat', () async {
      final cubit = LacakCubit(useCase);
      final f = cubit.lacak('SKB1');
      repo.lacak[0].c.complete(const Right(LacakResultEntity(noResi: 'SKB1')));
      await f;

      final r = cubit.refresh();
      expect(cubit.state.status, LacakStatus.loading);
      expect(cubit.state.result, isNotNull);
      repo.lacak[1].c.complete(
        const Left(ServerFailure('Berkas tidak ditemukan.')),
      );
      await r;

      expect(cubit.state.status, LacakStatus.failure);
      expect(cubit.state.error, 'Berkas tidak ditemukan.');
      await cubit.close();
    });

    test('kode baru mengosongkan hasil lama; respons lama diabaikan', () async {
      final cubit = LacakCubit(useCase);
      final a = cubit.lacak('A');
      final b = cubit.lacak('B');
      expect(cubit.state.kode, 'B');
      expect(cubit.state.result, isNull);

      repo.lacak[1].c.complete(const Right(LacakResultEntity(noResi: 'B')));
      await b;
      repo.lacak[0].c.complete(const Right(LacakResultEntity(noResi: 'A')));
      await a;

      expect(cubit.state.result!.noResi, 'B');
      await cubit.close();
    });
  });

  group('DetailBerkasCubit', () {
    test(
      'respons lama yang datang belakangan tidak menimpa data baru',
      () async {
        final cubit = DetailBerkasCubit(useCase);
        // #1 setelah halaman aksi ditutup, #2 setelah antrean terkirim.
        final lama = cubit.load('A');
        final baru = cubit.load('A');

        repo.detail[1].complete(
          Right(
            HasilBacaEntity(_detail(StatusBerkas.tiba, [AksiBerkas.serah])),
          ),
        );
        await baru;
        repo.detail[0].complete(
          Right(
            HasilBacaEntity(
              _detail(StatusBerkas.dalamPerjalanan, [AksiBerkas.tiba]),
            ),
          ),
        );
        await lama;

        expect(cubit.state.detail!.berkas.status, StatusBerkas.tiba);
        expect(cubit.state.detail!.berkas.aksi, [AksiBerkas.serah]);
        await cubit.close();
      },
    );

    test('refresh gagal: detail lama tetap tampil', () async {
      final cubit = DetailBerkasCubit(useCase);
      final pertama = cubit.load('A');
      repo.detail[0].complete(
        Right(HasilBacaEntity(_detail(StatusBerkas.tiba, [AksiBerkas.serah]))),
      );
      await pertama;

      final kedua = cubit.load('A');
      expect(cubit.state.status, DetailBerkasStatus.loaded);
      repo.detail[1].complete(const Left(NoInternetFailure()));
      await kedua;

      expect(cubit.state.status, DetailBerkasStatus.failure);
      expect(cubit.state.detail, isNotNull);
      await cubit.close();
    });

    test('tidak emit setelah ditutup', () async {
      final cubit = DetailBerkasCubit(useCase);
      final load = cubit.load('A');
      await cubit.close();
      repo.detail.single.complete(
        Right(HasilBacaEntity(_detail(StatusBerkas.tiba, const []))),
      );

      await expectLater(load, completes);
    });
  });
}
