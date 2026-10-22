import 'dart:async';

import 'package:mybapenda/core/errors/failure.dart';
import 'package:mybapenda/core/services/notifikasi/notifikasi_lokal.dart';
import 'package:mybapenda/core/services/notifikasi/notifikasi_task_handler.dart';
import 'package:mybapenda/data/models/notifikasi/notifikasi_model.dart';
import 'package:mybapenda/domain/entities/notifikasi/notifikasi_entity.dart';
import 'package:mybapenda/domain/repositories/notifikasi/i_notifikasi_repository.dart';
import 'package:mybapenda/domain/usecases/notifikasi/notifikasi_usecase.dart';
import 'package:mybapenda/presentation/features/notifikasi/cubit/notifikasi_badge_cubit.dart';
import 'package:mybapenda/presentation/features/notifikasi/cubit/notifikasi_cubit.dart';
import 'package:mybapenda/presentation/features/notifikasi/cubit/notifikasi_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

NotifikasiEntity _n(int id, {bool dibaca = false}) => NotifikasiEntity(
  id: id,
  kodeJenis: KodeNotifikasi.suratDitugaskan,
  namaJenis: 'Ditugaskan',
  reffNo: 'R$id',
  judul: 'J$id',
  isi: 'I$id',
  dibaca: dibaca,
);

HalamanNotifikasiEntity _hal(List<int> ids, {int page = 1, int total = 1}) =>
    HalamanNotifikasiEntity(
      items: ids.map(_n).toList(),
      page: page,
      totalPage: total,
      totalData: ids.length,
    );

/// Repository palsu: jawaban inbox per halaman diatur tes.
class _FakeRepo implements INotifikasiRepository {
  final halaman = <int, Either<Failure, HalamanNotifikasiEntity>>{};
  Either<Failure, int> jawabBaca = const Right(1);
  int? jumlahAwal;
  int restJumlahDipanggil = 0;
  final _jumlah = StreamController<int>.broadcast();

  void kirimJumlah(int n) => _jumlah.add(n);

  @override
  Stream<int> get jumlahBelumDibaca => _jumlah.stream;

  @override
  int? get jumlahTerakhir => jumlahAwal;
  final dibaca = <int>[];
  final _perubahan = StreamController<void>.broadcast();

  void ubah() => _perubahan.add(null);

  @override
  Stream<void> get perubahan => _perubahan.stream;

  @override
  Future<Either<Failure, HalamanNotifikasiEntity>> getInbox({
    int page = 1,
    int pageSize = 20,
    bool hanyaBelumDibaca = false,
  }) async => halaman[page] ?? const Left(ServerFailure('tidak ada'));

  @override
  Future<Either<Failure, int>> getJumlahBelumDibaca() async {
    restJumlahDipanggil++;
    return const Right(0);
  }

  @override
  Future<Either<Failure, int>> baca(int id) async {
    dibaca.add(id);
    return jawabBaca;
  }

  @override
  Future<Either<Failure, int>> bacaSemua() async => jawabBaca;
}

Future<void> _tunggu() => Future<void>.delayed(Duration.zero);

void main() {
  late _FakeRepo repo;
  late NotifikasiCubit cubit;

  setUp(() {
    repo = _FakeRepo();
    cubit = NotifikasiCubit(NotifikasiUseCase(repo));
  });
  tearDown(() => cubit.close());

  group('NotifikasiCubit', () {
    test('load + muatLagi menyambung halaman tanpa duplikat', () async {
      repo.halaman[1] = Right(_hal([3, 2], total: 2));
      repo.halaman[2] = Right(_hal([2, 1], page: 2, total: 2));

      await cubit.load();
      expect(cubit.state.status, NotifikasiStatus.success);
      expect(cubit.state.adaLagi, isTrue);

      await cubit.muatLagi();
      expect(cubit.state.items.map((n) => n.id), [3, 2, 1]);
      expect(cubit.state.adaLagi, isFalse);
    });

    test('gagal saat kosong → failure dengan pesan', () async {
      await cubit.load();
      expect(cubit.state.status, NotifikasiStatus.failure);
      expect(cubit.state.pesan, 'tidak ada');
    });

    test('baca optimistis; gagal server → dikembalikan', () async {
      repo.halaman[1] = Right(_hal([1]));
      await cubit.load();

      await cubit.baca(cubit.state.items.single);
      expect(cubit.state.items.single.dibaca, isTrue);
      expect(repo.dibaca, [1]);

      repo.halaman[1] = Right(_hal([2]));
      await cubit.load();
      repo.jawabBaca = const Left(ServerFailure('Notifikasi tidak ditemukan.'));
      await cubit.baca(cubit.state.items.single);
      expect(cubit.state.items.single.dibaca, isFalse);
      expect(cubit.state.pesan, 'Notifikasi tidak ditemukan.');
    });

    test('bacaSemua menandai semua', () async {
      repo.halaman[1] = Right(_hal([1, 2]));
      await cubit.load();
      await cubit.bacaSemua();
      expect(cubit.state.items.every((n) => n.dibaca), isTrue);
      expect(cubit.state.adaBelumDibaca, isFalse);
    });

    test(
      'perubahan (event baru) memuat ulang; halaman lanjut dipertahankan',
      () async {
        repo.halaman[1] = Right(_hal([3, 2], total: 2));
        repo.halaman[2] = Right(_hal([1], page: 2, total: 2));
        await cubit.load();
        await cubit.muatLagi();

        repo.halaman[1] = Right(_hal([4, 3], total: 2));
        repo.ubah();
        await _tunggu();
        await _tunggu();

        expect(cubit.state.items.map((n) => n.id), [4, 3, 2, 1]);
        expect(cubit.state.page, 2);
      },
    );
  });

  test(
    'NotifikasiBadgeCubit: nilai awal & tiap event hub, tanpa REST',
    () async {
      repo.jumlahAwal = 2;
      final badge = NotifikasiBadgeCubit(NotifikasiUseCase(repo));
      expect(badge.state, 2);

      repo.kirimJumlah(5);
      await _tunggu();
      expect(badge.state, 5);
      expect(repo.restJumlahDipanggil, 0);
      await badge.close();
    },
  );

  group('notifikasi status bar (idTerakhirDitampilkan)', () {
    NotifikasiModel m(int id, {String? reff = 'SKB1'}) => NotifikasiModel(
      id: id,
      kodeJenis: KodeNotifikasi.suratDitugaskan,
      namaJenis: '',
      reffNo: reff,
      judul: 'Berkas baru ditugaskan',
      isi: 'isi $id',
      dibaca: false,
    );

    NotifEventModel ev(
      List<NotifikasiModel> items, {
      bool snapshot = false,
      int? baru,
    }) => NotifEventModel(
      snapshot: snapshot,
      jumlahBaru: snapshot ? 0 : (baru ?? items.length),
      jumlahBelumDibaca: items.length,
      items: items,
    );

    test('login pertama: tidak tampil, catat max id', () {
      final h = NotifikasiTampil.proses(ev([m(3), m(7)], snapshot: true), null);
      expect(h.tampil, isEmpty);
      expect(h.idTerakhir, 7);
      expect(
        NotifikasiTampil.proses(ev([], snapshot: true), null).idTerakhir,
        0,
      );
    });

    test('satu baru → detail berkas, id tidak bentrok service', () {
      final h = NotifikasiTampil.proses(ev([m(9)]), 8);
      final t = h.tampil.single;
      expect(h.idTerakhir, 9);
      expect(t.judul, 'Berkas baru ditugaskan');
      expect(t.id, greaterThanOrEqualTo(1000));
      final p = PayloadBerkas.parse(t.payload)!;
      expect((p.id, p.noResi), (9, 'SKB1'));
    });

    test('dua berkas baru → dua notifikasi, terlama dulu', () {
      final h = NotifikasiTampil.proses(ev([m(12), m(11)]), 10);
      expect(h.tampil.map((t) => PayloadBerkas.parse(t.payload)!.id), [11, 12]);
      expect(h.tampil.map((t) => t.id).toSet(), hasLength(2));
    });

    test(
      'snapshot berulang tidak dobel; setelah offline muncul yang terlewat',
      () {
        expect(
          NotifikasiTampil.proses(ev([m(9), m(8)], snapshot: true), 9).tampil,
          isEmpty,
        );
        final h = NotifikasiTampil.proses(
          ev([m(12), m(11), m(9)], snapshot: true),
          9,
        );
        expect(h.tampil, hasLength(2));
        expect(h.idTerakhir, 12);
      },
    );

    test('jumlahBaru > 5 item → 5 notifikasi + "N berkas lain"', () {
      final h = NotifikasiTampil.proses(
        ev([for (var i = 11; i <= 15; i++) m(i)], baru: 7),
        10,
      );
      expect(h.tampil, hasLength(6));
      final lain = h.tampil.last;
      expect(lain.judul, '2 berkas lain ditugaskan');
      expect(lain.payload, NotifikasiLokal.payloadInbox);
      expect(lain.id, NotifikasiTampil.idRingkasan);
    });

    test('tanpa reffNo → kotak masuk', () {
      final t = NotifikasiTampil.proses(
        ev([m(2, reff: null)]),
        1,
      ).tampil.single;
      expect(t.payload, NotifikasiLokal.payloadInbox);
    });

    test('PayloadBerkas.parse menolak payload rusak', () {
      expect(PayloadBerkas.parse('inbox'), isNull);
      expect(PayloadBerkas.parse('berkas:abc:R1'), isNull);
      expect(PayloadBerkas.parse('berkas:5:'), isNull);
      expect(PayloadBerkas.parse('berkas:5:HMB:1')!.noResi, 'HMB:1');
    });
  });
}
