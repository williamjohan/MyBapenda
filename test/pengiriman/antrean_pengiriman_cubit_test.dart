import 'dart:async';

import 'package:mybapenda/core/network/network_cubit.dart';
import 'package:mybapenda/domain/entities/pengiriman/antrean_entity.dart';
import 'package:mybapenda/domain/repositories/pengiriman/i_pengiriman_repository.dart';
import 'package:mybapenda/domain/usecases/pengiriman/pengiriman_usecase.dart';
import 'package:mybapenda/presentation/features/auth/cubit/auth_state.dart';
import 'package:mybapenda/presentation/features/pengiriman/cubit/antrean/antrean_pengiriman_cubit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pengiriman_fakes.dart';

AntreanPengirimanEntity _item(String uuid) => AntreanPengirimanEntity(
  checkinUuid: uuid,
  jenis: JenisAksiAntrean.tiba,
  noResi: const ['A'],
  tglDibuat: DateTime(2026, 10, 15),
);

/// Repository palsu: [isi] = isi antrean; sinkronkan mengosongkannya
/// (bisa ditahan dengan [tahan]).
class _FakeRepository implements IPengirimanRepository {
  var isi = <AntreanPengirimanEntity>[];
  var jmlSinkron = 0;
  Completer<void>? tahan;
  final perubahan = StreamController<RingkasanAntreanEntity>.broadcast();
  final dihapus = <String>[];

  @override
  Stream<RingkasanAntreanEntity> get perubahanAntrean => perubahan.stream;

  @override
  Future<RingkasanAntreanEntity> bacaAntrean() async =>
      RingkasanAntreanEntity(menunggu: List.of(isi));

  @override
  Future<void> sinkronkan() async {
    jmlSinkron++;
    await tahan?.future;
    isi = [];
  }

  @override
  Future<void> hapusGagal(String checkinUuid) async => dihapus.add(checkinUuid);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _tunggu() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeRepository repo;
  late FakeAuth auth;
  late FakeConnectivity koneksi;
  late NetworkCubit network;
  late AntreanPengirimanCubit cubit;

  setUp(() {
    repo = _FakeRepository();
    auth = FakeAuth();
    koneksi = FakeConnectivity();
    network = NetworkCubit(koneksi);
    cubit = AntreanPengirimanCubit(PengirimanUseCase(repo), auth, network);
  });

  tearDown(() async {
    await cubit.close();
    await network.close();
    await auth.close();
  });

  test('muat: antrean berisi langsung dikirim', () async {
    repo.isi = [_item('u1'), _item('u2')];

    await cubit.muat();

    expect(repo.jmlSinkron, 1);
    expect(cubit.state.ringkasan.menunggu, isEmpty);
    expect(cubit.state.sedangKirim, isFalse);
  });

  test('muat: antrean kosong tidak memicu kirim', () async {
    await cubit.muat();
    expect(repo.jmlSinkron, 0);
  });

  test('belum login: tidak kirim (hindari 401 → logout paksa)', () async {
    auth.ubah(const AuthUnauthenticated());
    repo.isi = [_item('u1')];

    await cubit.muat();

    expect(repo.jmlSinkron, 0);
    expect(cubit.state.ringkasan.menunggu, hasLength(1));
  });

  test('sedang mengirim: pemicu lain diabaikan', () async {
    repo.isi = [_item('u1')];
    repo.tahan = Completer();

    final pertama = cubit.kirim();
    await _tunggu();
    expect(cubit.state.sedangKirim, isTrue);
    await cubit.kirim();
    repo.tahan!.complete();
    await pertama;

    expect(repo.jmlSinkron, 1);
    expect(cubit.state.sedangKirim, isFalse);
  });

  test('HP kembali online → kirim otomatis', () async {
    repo.isi = [_item('u1')];

    koneksi.perubahan.add([ConnectivityResult.none]);
    await _tunggu();
    expect(repo.jmlSinkron, 0);

    koneksi.perubahan.add([ConnectivityResult.mobile]);
    await _tunggu();
    await _tunggu();

    expect(repo.jmlSinkron, 1);
  });

  test('aplikasi dibuka lagi → kirim otomatis', () async {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await _tunggu();
    expect(repo.jmlSinkron, 0);

    binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await _tunggu();

    expect(repo.jmlSinkron, 1);
  });

  test('perubahan antrean dari repository langsung tampil', () async {
    repo.perubahan.add(RingkasanAntreanEntity(menunggu: [_item('u9')]));
    await _tunggu();

    expect(cubit.state.ringkasan.menunggu.single.checkinUuid, 'u9');
  });

  test('hapus data gagal diteruskan ke repository', () async {
    await cubit.hapusGagal('u3');
    expect(repo.dihapus, ['u3']);
  });

  test('setelah ditutup: berhenti mendengar online & antrean', () async {
    await cubit.close();
    koneksi.perubahan.add([ConnectivityResult.wifi]);
    repo.perubahan.add(RingkasanAntreanEntity(menunggu: [_item('u1')]));
    await _tunggu();

    expect(repo.jmlSinkron, 0);
  });
}
