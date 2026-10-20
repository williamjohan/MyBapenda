import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bapendacore/core/constants/design_system/tokens/app_palette.dart';
import 'package:bapendacore/core/di/injection.dart';
import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/core/network/network_cubit.dart';
import 'package:bapendacore/core/storage/app_preference.dart';
import 'package:bapendacore/core/storage/app_secure_storage.dart';
import 'package:bapendacore/core/theme/adaptive_theme_scope.dart';
import 'package:bapendacore/core/theme/theme_mode_cubit.dart';
import 'package:bapendacore/domain/entities/pengiriman/antrean_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/berkas_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/jejak_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/lacak_entity.dart';
import 'package:bapendacore/domain/repositories/pengiriman/i_pengiriman_repository.dart';
import 'package:bapendacore/domain/usecases/pengiriman/pengiriman_usecase.dart';
import 'package:bapendacore/presentation/features/pengiriman/cubit/antrean/antrean_pengiriman_cubit.dart';
import 'package:bapendacore/presentation/features/pengiriman/cubit/daftar_tugas/daftar_tugas_cubit.dart';
import 'package:bapendacore/presentation/features/pengiriman/cubit/detail_berkas/detail_berkas_cubit.dart';
import 'package:bapendacore/presentation/features/pengiriman/cubit/lacak/lacak_cubit.dart';
import 'package:bapendacore/presentation/features/pengiriman/cubit/pantau/pantau_cubit.dart';
import 'package:bapendacore/presentation/features/pengiriman/pages/antrean_page.dart';
import 'package:bapendacore/presentation/features/pengiriman/pages/daftar_tugas_page.dart';
import 'package:bapendacore/presentation/features/pengiriman/pages/detail_berkas_page.dart';
import 'package:bapendacore/presentation/features/pengiriman/pages/lacak_page.dart';
import 'package:bapendacore/presentation/features/pengiriman/pages/pantau_page.dart';
import 'package:bapendacore/presentation/features/pengiriman/widgets/daftar_tugas/berkas_card.dart';
import 'package:bapendacore/presentation/features/pengiriman/widgets/lacak/peta_lacak.dart';
import 'package:bapendacore/presentation/features/pengiriman/widgets/pantau/pantau_berkas_card.dart';
import 'package:bapendacore/presentation/shared/widgets/bapenda_image.dart';
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:bapendacore/routes/app_routes.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/pengiriman_fakes.dart';
import 'helpers/platform_fakes.dart';

/// Repository palsu yang langsung menjawab (tanpa jaringan).
class _Repo implements IPengirimanRepository {
  List<BerkasEntity> daftar = const [];
  DateTime? tglCache;
  List<AntreanPengirimanEntity> menunggu = const [];
  List<AntreanPengirimanEntity> gagal = const [];
  var jmlSinkron = 0;
  final dihapus = <String>[];
  BerkasDetailEntity? detail;
  LacakResultEntity? lacak;
  final perubahan = StreamController<RingkasanAntreanEntity>.broadcast();

  /// Diisi = baca daftar/detail gagal dengan pesan ini.
  String? galat;
  var jmlDaftar = 0;
  var jmlDetail = 0;

  @override
  Future<HasilDaftar> getDaftar() async {
    jmlDaftar++;
    return galat != null
        ? Left(ServerFailure(galat))
        : Right(HasilBacaEntity(daftar, tglCache: tglCache));
  }

  @override
  Future<HasilDetail> getDetail(String noResi) async {
    jmlDetail++;
    return galat != null || detail == null
        ? Left(ServerFailure(galat ?? 'Gagal memuat detail.'))
        : Right(HasilBacaEntity(detail!, tglCache: tglCache));
  }

  /// Jalur jalan dari Routes API; null = belum aktif (peta hanya titik).
  List<TitikRute>? rute;
  final ruteDiminta = <List<TitikRute>>[];

  @override
  Future<Either<Failure, List<TitikRute>>> getRute(
    List<TitikRute> titik,
  ) async {
    ruteDiminta.add(titik);
    return rute == null
        ? const Left(ServerFailure('Routes API diblokir'))
        : Right(rute!);
  }

  @override
  Future<HasilLacak> getLacak(String kode) async => lacak == null
      ? const Left(ServerFailure('Berkas tidak ditemukan.'))
      : Right(lacak!);

  @override
  Stream<RingkasanAntreanEntity> get perubahanAntrean => perubahan.stream;

  @override
  Future<RingkasanAntreanEntity> bacaAntrean() async =>
      RingkasanAntreanEntity(menunggu: menunggu, gagal: gagal);

  @override
  Future<void> sinkronkan() async => jmlSinkron++;

  @override
  Future<void> hapusGagal(String checkinUuid) async {
    dihapus.add(checkinUuid);
    gagal = [
      for (final a in gagal)
        if (a.checkinUuid != checkinUuid) a,
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Pasang [halaman] di GoRouter; rute tujuan navigasi diganti teks penanda.
Future<_Repo> _pump(
  WidgetTester tester,
  Widget Function(PengirimanUseCase useCase) halaman, {
  required _Repo repo,
  ThemeMode mode = ThemeMode.light,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({'theme_mode': mode.name});
  final prefs = AppPreferences(await SharedPreferences.getInstance());
  final useCase = PengirimanUseCase(repo);
  final auth = FakeAuth();
  final network = NetworkCubit(FakeConnectivity());
  addTearDown(() async {
    await network.close();
    await auth.close();
  });

  /// Halaman tujuan palsu: tampilkan nama + extra, "selesai" = pop(true).
  Widget penanda(String nama, GoRouterState s) => Scaffold(
    body: Column(
      children: [
        Text('$nama:${s.extra}'),
        Builder(
          builder: (c) => TextButton(
            onPressed: () => c.pop(true),
            child: const Text('selesai'),
          ),
        ),
      ],
    ),
  );

  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => halaman(useCase)),
      for (final (path, nama) in [
        (AppRoutes.pengirimanScan, 'scan'),
        (AppRoutes.pengirimanCheckin, 'checkin'),
        (AppRoutes.pengirimanSerah, 'serah'),
        (AppRoutes.pengirimanGagal, 'gagal'),
      ])
        GoRoute(path: path, builder: (_, s) => penanda(nama, s)),
      GoRoute(
        path: AppRoutes.pengirimanDetail,
        builder: (_, s) => penanda('detail', s),
      ),
      GoRoute(
        path: AppRoutes.pengirimanAntrean,
        builder: (_, _) => _scope(const AntreanPage()),
      ),
      GoRoute(
        path: AppRoutes.pengirimanLacakDetail,
        builder: (_, s) => penanda('lacak', s),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ThemeModeCubit(
            prefs,
            AppSecureStorage(const FlutterSecureStorage()),
          ),
        ),
        BlocProvider(
          create: (_) => AntreanPengirimanCubit(useCase, auth, network)..muat(),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  return repo;
}

Widget _scope(Widget child) => AdaptiveThemeScope(child: child);

/// Satu usapan pendek (< lebar layar 360) = pindah satu tab.
Future<void> _geserKeKiri(WidgetTester tester) async {
  await tester.fling(find.byType(TabBarView), const Offset(-200, 0), 1000);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  final daftar = [
    berkas(noResi: 'HMB1', namaWp: 'Toko Maju'),
    berkas(
      noResi: 'TGR2',
      namaWp: 'CV Sentosa',
      status: StatusBerkas.dalamPerjalanan,
      aksi: const [AksiBerkas.tiba],
    ),
    berkas(
      noResi: 'SKB3',
      namaWp: 'PT Gagal',
      status: StatusBerkas.gagalAntar,
      aksi: const [AksiBerkas.kembalikan],
    ),
  ];

  group('Pengiriman Surat', () {
    Widget page(PengirimanUseCase u) => BlocProvider(
      create: (_) => DaftarTugasCubit(u)..load(),
      child: _scope(const DaftarTugasPage()),
    );

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('tab tanpa Selesai, geser untuk pindah tab (${mode.name})', (
        tester,
      ) async {
        await _pump(tester, page, repo: _Repo()..daftar = daftar, mode: mode);

        expect(find.text('Untuk Diambil'), findsOneWidget);
        expect(find.text('Diantar'), findsOneWidget);
        expect(find.text('Gagal/Kembali'), findsOneWidget);
        expect(find.text('Selesai'), findsNothing);

        // Tab pertama: hanya berkas Ditugaskan.
        expect(find.text('HMB1'), findsOneWidget);
        expect(find.text('TGR2'), findsNothing);

        await _geserKeKiri(tester);
        expect(find.text('TGR2'), findsOneWidget);
        expect(find.text('HMB1'), findsNothing);

        await _geserKeKiri(tester);
        expect(find.text('SKB3'), findsOneWidget);

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
        expect(
          scaffold.backgroundColor,
          mode == ThemeMode.dark
              ? AppPalette.dark.background
              : AppPalette.light.background,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('ketuk tab juga pindah halaman', (tester) async {
      await _pump(tester, page, repo: _Repo()..daftar = daftar);

      // Di layar 360dp tab ketiga di luar layar: geser bar tab dulu.
      await tester.ensureVisible(find.text('Gagal/Kembali'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gagal/Kembali'));
      await tester.pumpAndSettle();

      expect(find.text('SKB3'), findsOneWidget);
    });

    testWidgets('ketuk kartu → buka detail berkas', (tester) async {
      await _pump(tester, page, repo: _Repo()..daftar = daftar);

      await tester.tap(find.byType(BerkasCard).first);
      await tester.pumpAndSettle();

      expect(find.text('detail:HMB1'), findsOneWidget);
    });

    testWidgets('berkas yang sudah diterima tidak tampil di daftar tugas', (
      tester,
    ) async {
      await _pump(
        tester,
        page,
        repo: _Repo()
          ..daftar = [
            berkas(
              noResi: 'HMB5',
              status: StatusBerkas.diterima,
              aksi: const [],
            ),
            daftar[1],
          ],
      );

      await _geserKeKiri(tester);

      expect(find.text('TGR2'), findsOneWidget);
      expect(find.text('HMB5'), findsNothing);
    });

    testWidgets('tab kosong menampilkan pesan', (tester) async {
      await _pump(tester, page, repo: _Repo()..daftar = [daftar.first]);

      await _geserKeKiri(tester);

      expect(find.text('Belum ada berkas di tab ini.'), findsOneWidget);
    });
  });

  group('Pantau Surat Pengiriman', () {
    Widget page(PengirimanUseCase u) => BlocProvider(
      create: (_) => PantauCubit(u)..load(),
      child: _scope(const PantauPage()),
    );

    testWidgets('semua berkas tampil, geser ke Belum Diambil', (tester) async {
      await _pump(tester, page, repo: _Repo()..daftar = daftar);

      expect(find.byType(PantauBerkasCard), findsNWidgets(3));

      await _geserKeKiri(tester);

      expect(find.byType(PantauBerkasCard), findsOneWidget);
      expect(find.text('Toko Maju'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tab Tiba di Tujuan: berkas yang sudah sampai di WP', (
      tester,
    ) async {
      await _pump(
        tester,
        page,
        repo: _Repo()
          ..daftar = [
            ...daftar,
            berkas(
              noResi: 'HMB4',
              namaWp: 'UD Sampai',
              status: StatusBerkas.tiba,
              aksi: const [AksiBerkas.serah, AksiBerkas.gagal],
            ),
          ],
      );

      await tester.ensureVisible(find.text('Tiba di Tujuan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tiba di Tujuan'));
      await tester.pumpAndSettle();

      expect(find.byType(PantauBerkasCard), findsOneWidget);
      expect(find.text('UD Sampai'), findsOneWidget);
      // Sedang Diantar tidak lagi memuat berkas yang sudah tiba.
      await tester.fling(find.byType(TabBarView), const Offset(200, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('UD Sampai'), findsNothing);
      expect(find.text('CV Sentosa'), findsOneWidget);
    });

    testWidgets('tab Diterima & Semua memuat berkas yang sudah diterima', (
      tester,
    ) async {
      await _pump(
        tester,
        page,
        repo: _Repo()
          ..daftar = [
            ...daftar,
            berkas(
              noResi: 'HMB5',
              namaWp: 'PT Terima',
              status: StatusBerkas.diterima,
              aksi: const [],
            ),
          ],
      );

      // Semua: berkas aktif + yang diterima (paling bawah, gulir dulu).
      await tester.scrollUntilVisible(
        find.text('PT Terima'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('PT Terima'), findsOneWidget);
      await tester.drag(find.byType(TabBarView), const Offset(0, 2000));
      await tester.pumpAndSettle();

      final tab = find.descendant(
        of: find.byType(TabBar),
        matching: find.text('Diterima'),
      );
      await tester.ensureVisible(tab);
      await tester.pumpAndSettle();
      await tester.tap(tab);
      await tester.pumpAndSettle();

      expect(find.byType(PantauBerkasCard), findsOneWidget);
      expect(find.text('PT Terima'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no resi di luar daftar → tawarkan lacak langsung', (
      tester,
    ) async {
      await _pump(tester, page, repo: _Repo()..daftar = daftar);

      await tester.enterText(find.byType(TextField), 'SKB999');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.byType(PantauBerkasCard), findsNothing);
      await tester.tap(find.text('Lacak "SKB999"'));
      await tester.pumpAndSettle();

      expect(find.text('lacak:SKB999'), findsOneWidget);
    });

    testWidgets('ketuk kartu → lacak berkas', (tester) async {
      await _pump(tester, page, repo: _Repo()..daftar = daftar);

      await tester.tap(find.byType(PantauBerkasCard).first);
      await tester.pumpAndSettle();

      expect(find.text('lacak:HMB1'), findsOneWidget);
    });
  });

  group('Detail Berkas', () {
    Widget page(PengirimanUseCase u) => BlocProvider(
      create: (_) => DetailBerkasCubit(u)..load('TGR2'),
      child: _scope(const DetailBerkasPage(noResi: 'TGR2')),
    );

    testWidgets('setelah Tiba: tombol Serah Terima & Gagal Antar', (
      tester,
    ) async {
      await _pump(
        tester,
        page,
        repo: _Repo()
          ..detail = BerkasDetailEntity(
            berkas: berkas(
              noResi: 'TGR2',
              status: StatusBerkas.tiba,
              aksi: const [AksiBerkas.serah, AksiBerkas.gagal],
            ),
          ),
      );

      expect(find.text('Serah Terima'), findsOneWidget);
      expect(find.text('Gagal Antar'), findsOneWidget);
      expect(find.text('Tiba di Tujuan'), findsOneWidget); // judul status
      expect(find.text('RIWAYAT PERJALANAN'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sudah diterima: tanpa tombol aksi', (tester) async {
      await _pump(
        tester,
        page,
        repo: _Repo()
          ..detail = BerkasDetailEntity(
            berkas: berkas(
              noResi: 'TGR2',
              status: StatusBerkas.diterima,
              aksi: const [],
            ),
            namaPenerima: 'Budi',
          ),
      );

      expect(find.text('Serah Terima'), findsNothing);
      expect(find.text('Gagal Antar'), findsNothing);
      expect(find.textContaining('Surat diterima oleh Budi'), findsOneWidget);
    });
  });

  group('Lacak Berkas', () {
    Widget page(PengirimanUseCase u) => BlocProvider(
      create: (_) => LacakCubit(u)..lacak('TGR2'),
      child: _scope(const LacakPage()),
    );

    BerkasDetailEntity tugas() => BerkasDetailEntity(
      berkas: berkas(
        noResi: 'TGR2',
        namaWp: 'CV Sentosa',
        status: StatusBerkas.dalamPerjalanan,
      ),
    );

    testWidgets('tugas saya: tombol buka detail tugas di bawah', (
      tester,
    ) async {
      await _pump(
        tester,
        page,
        repo: _Repo()
          ..lacak = LacakResultEntity(
            noResi: 'TGR2',
            tugasSaya: true,
            tugas: tugas(),
          ),
      );

      // Tanpa koordinat: tanpa peta, alamat tujuan tampil.
      expect(find.byType(PetaLacak), findsNothing);
      expect(find.text('Jl. Pemuda 1'), findsOneWidget);
      expect(find.text('RIWAYAT PERJALANAN'), findsOneWidget);

      await tester.tap(find.text('Tugas Anda · Buka Detail Tugas'));
      await tester.pumpAndSettle();

      expect(find.text('detail:TGR2'), findsOneWidget);
    });

    testWidgets('bukan tugas saya: tanpa tombol tugas', (tester) async {
      await _pump(
        tester,
        page,
        repo: _Repo()
          ..lacak = LacakResultEntity(noResi: 'TGR2', tugas: tugas()),
      );

      expect(find.text('Tugas Anda · Buka Detail Tugas'), findsNothing);
    });

    testWidgets('tidak ditemukan: pesan + coba lagi', (tester) async {
      await _pump(tester, page, repo: _Repo());

      expect(find.text('Berkas tidak ditemukan.'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
    });
  });

  group('Antrean & offline', () {
    AntreanPengirimanEntity item(
      String uuid,
      JenisAksiAntrean jenis, {
      int coba = 0,
      String? pesan,
      bool diabaikan = false,
    }) => AntreanPengirimanEntity(
      checkinUuid: uuid,
      jenis: jenis,
      noResi: const ['TGR2'],
      tglDibuat: DateTime(2026, 10, 15, 9, 30),
      jmlCoba: coba,
      pesan: pesan,
      diabaikan: diabaikan,
    );

    testWidgets('indikator di header → halaman Belum Terkirim', (tester) async {
      final repo = _Repo()
        ..daftar = daftar
        ..menunggu = [
          item('u1', JenisAksiAntrean.tiba, coba: 2, pesan: 'Timeout'),
        ]
        ..gagal = [
          item('u2', JenisAksiAntrean.serah, diabaikan: true),
          item('u3', JenisAksiAntrean.gagal, pesan: 'Berkas sudah diterima'),
        ];
      await _pump(
        tester,
        (u) => BlocProvider(
          create: (_) => DaftarTugasCubit(u)..load(),
          child: _scope(const DaftarTugasPage()),
        ),
        repo: repo,
      );

      await tester.tap(find.byTooltip('3 belum terkirim'));
      await tester.pumpAndSettle();

      expect(find.text('MENUNGGU DIKIRIM (1)'), findsOneWidget);
      expect(find.text('Percobaan 2x · Timeout'), findsOneWidget);
      expect(find.text('PERLU DICEK (2)'), findsOneWidget);
      expect(
        find.text('Tersimpan sebagai jejak, status berkas tidak berubah.'),
        findsOneWidget,
      );
      expect(find.text('Berkas sudah diterima'), findsOneWidget);

      final sebelum = repo.jmlSinkron;
      await tester.tap(find.text('Kirim Sekarang'));
      await tester.pumpAndSettle();
      expect(repo.jmlSinkron, sebelum + 1);

      await tester.tap(find.byTooltip('Tandai sudah dicek').first);
      await tester.pumpAndSettle();
      expect(repo.dihapus, ['u2']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('antrean kosong: semua terkirim', (tester) async {
      await _pump(tester, (_) => _scope(const AntreanPage()), repo: _Repo());

      expect(find.text('Semua data sudah terkirim.'), findsOneWidget);
      expect(find.text('Kirim Sekarang'), findsNothing);
    });

    testWidgets('data offline: pita tanpa sinyal + jam data', (tester) async {
      await _pump(
        tester,
        (u) => BlocProvider(
          create: (_) => PantauCubit(u)..load(),
          child: _scope(const PantauPage()),
        ),
        repo: _Repo()
          ..daftar = daftar
          ..tglCache = DateTime(2026, 10, 15, 7, 5),
      );

      expect(
        find.text('Tanpa sinyal · data terakhir 15/10 07:05'),
        findsOneWidget,
      );
    });
  });

  group('Lacak lengkap (monitoring): peta & riwayat', () {
    Widget page(PengirimanUseCase u) => BlocProvider(
      create: (_) => LacakCubit(u)..lacak('TGR2'),
      child: _scope(const LacakPage()),
    );

    JejakEntity j(
      StatusBerkas s,
      int jam, {
      double? lat,
      double? lng,
      List<FotoJejakEntity> foto = const [],
      int jumlahFoto = 0,
      bool diabaikan = false,
      bool perluReview = false,
      bool flagAkurasi = false,
      bool flagWaktu = false,
      bool belumTerkirim = false,
      double? jarak,
      String? keterangan,
    }) => JejakEntity(
      status: s,
      statusNama: s.label,
      sumber: 'Petugas',
      namaPetugas: 'Najib',
      tglCheckin: DateTime(2026, 10, 15, jam),
      latitude: lat,
      longitude: lng,
      akurasi: flagAkurasi ? 85 : 8,
      jarakKeTujuan: jarak,
      keterangan: keterangan,
      foto: foto,
      jumlahFoto: jumlahFoto,
      diabaikan: diabaikan,
      perluReview: perluReview,
      flagAkurasi: flagAkurasi,
      flagWaktu: flagWaktu,
      belumTerkirim: belumTerkirim,
    );

    LacakResultEntity hasil() => LacakResultEntity(
      noResi: 'TGR2',
      aksesMonitoring: true,
      monitoring: MonitoringBerkasEntity(
        noResi: 'TGR2',
        jenis: JenisSurat.teguran,
        jenisNama: 'Teguran',
        namaWp: 'CV Sentosa',
        alamatWp: 'Jl. Pemuda 1',
        status: StatusBerkas.tiba,
        statusNama: 'Tiba di Tujuan',
        namaPetugas: 'Najib',
        nipPetugas: '1990',
        jumlahGagal: 1,
        maksPercobaan: 3,
        tglBatasSla: DateTime(2026, 10, 20),
        perluReview: true,
        tindakan: 'Cek foto',
        jejak: [
          j(StatusBerkas.diterima, 14, belumTerkirim: true),
          j(
            StatusBerkas.tiba,
            13,
            lat: -7.30,
            lng: 112.78,
            jarak: 1500,
            keterangan: 'Depan pagar',
            foto: const [
              FotoJejakEntity(key: 'k1', jenisFoto: 'Lokasi'),
              FotoJejakEntity(key: 'k2'),
            ],
            flagAkurasi: true,
            flagWaktu: true,
            perluReview: true,
          ),
          j(StatusBerkas.gagalAntar, 11, lat: -7.29, lng: 112.77, jarak: 40),
          j(
            StatusBerkas.dalamPerjalanan,
            10,
            lat: -7.27,
            lng: 112.75,
            jumlahFoto: 1,
            diabaikan: true,
          ),
          j(StatusBerkas.diambil, 9),
        ],
      ),
      tugas: const BerkasDetailEntity(
        berkas: BerkasEntity(
          noResi: 'TGR2',
          jenis: JenisSurat.teguran,
          jenisNama: 'Teguran',
          namaWp: 'CV Sentosa',
          alamatTujuan: 'Jl. Pemuda 1',
          status: StatusBerkas.tiba,
          statusNama: 'Tiba di Tujuan',
          latTujuan: -7.301,
          longTujuan: 112.781,
        ),
      ),
    );

    /// Ikon pin digambar ke PNG: tiap pin butuh beberapa operasi engine
    /// (toImage, toByteData), masing-masing selesai di event loop sungguhan
    /// lalu lanjut di zona tes saat di-pump.
    Future<void> tungguPin(WidgetTester tester) async {
      for (var i = 0; i < 30; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();
    }

    testWidgets('peta: pin per check-in + tujuan, rute jalan, buka rute', (
      tester,
    ) async {
      final p = pasangPlatformPalsu(addTearDown);
      const jalan = [
        TitikRute(-7.27, 112.75),
        TitikRute(-7.275, 112.755),
        TitikRute(-7.29, 112.77),
        TitikRute(-7.30, 112.78),
        TitikRute(-7.301, 112.781),
      ];
      final repo = _Repo()
        ..lacak = hasil()
        ..rute = jalan;
      await _pump(tester, page, repo: repo);
      await tungguPin(tester);

      expect(find.byType(PetaLacak), findsOneWidget);
      // 3 check-in berkoordinat + alamat tujuan.
      expect(p.peta.marker, hasLength(4));
      // Rute diminta lewat titik urut waktu → ke tujuan.
      expect(repo.ruteDiminta.single, const [
        TitikRute(-7.27, 112.75),
        TitikRute(-7.29, 112.77),
        TitikRute(-7.30, 112.78),
        TitikRute(-7.301, 112.781),
      ]);
      // Garis mengikuti jalur jalan, bukan garis lurus antar pin.
      expect(p.peta.polyline.single.points, hasLength(jalan.length));
      for (final l in [
        'Posisi petugas',
        'Tiba / diterima',
        'Gagal antar',
        'Alamat tujuan',
      ]) {
        expect(find.text(l), findsOneWidget);
      }
      // Header ringkas: nama WP tampil, alamat diganti peta.
      expect(find.text('CV Sentosa'), findsOneWidget);

      await tester.tap(find.byTooltip('Tampilkan semua titik'));
      await tester.pump();
      expect(p.peta.kamera, isNotEmpty);

      await tester.tap(find.text('Buka Rute'));
      await tester.pump();
      final url = Uri.parse(p.url.dibuka.single);
      expect(url.path, '/maps/dir/');
      expect(url.queryParameters['origin'], '-7.27,112.75');
      expect(url.queryParameters['destination'], '-7.301,112.781');

      p.url.berhasil = false;
      await tester.tap(find.text('Buka Rute'));
      await tester.pumpAndSettle();
      expect(find.text('Tidak bisa membuka aplikasi peta'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Routes API belum aktif: hanya titik, tanpa garis lurus', (
      tester,
    ) async {
      final p = pasangPlatformPalsu(addTearDown);
      await _pump(tester, page, repo: _Repo()..lacak = hasil());
      await tungguPin(tester);

      expect(p.peta.marker, hasLength(4));
      expect(p.peta.polyline, isEmpty);
      // Tombol tetap membuka rute lengkap di Google Maps (tanpa API key).
      expect(find.text('Buka Rute'), findsOneWidget);
    });

    testWidgets('riwayat: penanda, foto, lokasi check-in', (tester) async {
      final p = pasangPlatformPalsu(addTearDown);
      getIt.registerSingleton<Dio>(Dio()..httpClientAdapter = _GambarAdapter());
      addTearDown(() => getIt.unregister<Dio>());
      await _pump(tester, page, repo: _Repo()..lacak = hasil());
      await tungguPin(tester);

      final gulir = find.byType(Scrollable).first;
      Future<void> lihat(Finder f) async {
        await tester.scrollUntilVisible(f, 150, scrollable: gulir);
        await tester.pumpAndSettle();
      }

      await lihat(find.text('Belum terkirim'));
      await lihat(find.text('Depan pagar'));
      expect(find.text('Akurasi ±85 m'), findsOneWidget);
      expect(find.text('Waktu HP janggal'), findsOneWidget);
      expect(find.text('Perlu review'), findsOneWidget);
      expect(find.textContaining('±1.5 km dari tujuan'), findsOneWidget);

      await lihat(find.text('Status tidak berubah'));
      expect(find.text('1 foto terlampir'), findsOneWidget);
      expect(find.textContaining('±40 m dari tujuan'), findsOneWidget);

      final lokasi = find.text('Lihat lokasi check-in').first;
      await lihat(lokasi);
      await tester.tap(lokasi);
      await tester.pumpAndSettle();
      expect(p.url.dibuka, isNotEmpty);

      // Seksi info monitoring.
      await lihat(find.text('Cek foto'));
      expect(find.text('1 gagal dari maks 3'), findsOneWidget);

      // Foto jejak: layar penuh, geser antar foto.
      final foto = find.byType(BapendaImage).first;
      await tester.scrollUntilVisible(foto, -150, scrollable: gulir);
      await tester.pumpAndSettle();
      await tester.tap(foto);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Lokasi  ·  1/2'), findsOneWidget);
      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('2/2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('muat ulang dengan jejak baru: pin diperbarui', (tester) async {
      final p = pasangPlatformPalsu(addTearDown);
      final repo = _Repo()..lacak = hasil();
      await _pump(tester, page, repo: repo);
      await tungguPin(tester);

      repo.lacak = LacakResultEntity(
        noResi: 'TGR2',
        monitoring: MonitoringBerkasEntity(
          noResi: 'TGR2',
          jenis: JenisSurat.teguran,
          jenisNama: 'Teguran',
          namaWp: 'CV Sentosa',
          status: StatusBerkas.dalamPerjalanan,
          statusNama: 'Dalam Perjalanan',
          jejak: [j(StatusBerkas.dalamPerjalanan, 15, lat: -7.2, lng: 112.7)],
        ),
      );
      tester.element(find.byType(LacakPage)).read<LacakCubit>().refresh();
      await tungguPin(tester);

      expect(p.peta.marker, hasLength(1));
      expect(find.text('Tiba / diterima'), findsNothing);
    });
  });

  group('Tombol aksi Detail Berkas → halaman aksi → muat ulang', () {
    Widget page(PengirimanUseCase u) => BlocProvider(
      create: (_) => DetailBerkasCubit(u)..load('TGR2'),
      child: _scope(const DetailBerkasPage(noResi: 'TGR2')),
    );

    for (final (status, aksi, tombol, tujuan) in [
      (StatusBerkas.ditugaskan, [AksiBerkas.ambil], 'Ambil Surat', 'scan:'),
      (
        StatusBerkas.dalamPerjalanan,
        [AksiBerkas.tiba, AksiBerkas.perjalanan, AksiBerkas.gagal],
        'Update Posisi',
        'checkin:',
      ),
      (
        StatusBerkas.dalamPerjalanan,
        [AksiBerkas.tiba, AksiBerkas.perjalanan, AksiBerkas.gagal],
        'Tiba di Tujuan',
        'checkin:',
      ),
      (
        StatusBerkas.tiba,
        [AksiBerkas.serah, AksiBerkas.gagal],
        'Serah Terima',
        'serah:',
      ),
      (StatusBerkas.tiba, [AksiBerkas.gagal], 'Gagal Antar', 'gagal:TGR2'),
      (StatusBerkas.gagalAntar, [AksiBerkas.kembalikan], 'Kembalikan', 'scan:'),
    ]) {
      testWidgets('$tombol → $tujuan', (tester) async {
        final repo = await _pump(
          tester,
          page,
          repo: _Repo()
            ..detail = BerkasDetailEntity(
              berkas: berkas(noResi: 'TGR2', status: status, aksi: aksi),
            ),
        );
        final muat = repo.jmlDetail;

        await tester.tap(find.widgetWithText(Button, tombol));
        await tester.pumpAndSettle();
        expect(find.textContaining(tujuan), findsOneWidget);

        await tester.tap(find.text('selesai'));
        await tester.pumpAndSettle();
        // Aksi berhasil → detail dimuat ulang (tombol ikut berganti).
        expect(repo.jmlDetail, muat + 1);
      });
    }

    testWidgets('gagal memuat: pesan + coba lagi', (tester) async {
      final repo = await _pump(tester, page, repo: _Repo()..galat = 'Putus');

      expect(find.text('Putus'), findsOneWidget);
      repo
        ..galat = null
        ..detail = BerkasDetailEntity(berkas: berkas(noResi: 'TGR2'));
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();

      expect(find.text('Ambil Surat'), findsOneWidget);
    });

    testWidgets('refresh gagal saat data ada: snackbar, data tetap', (
      tester,
    ) async {
      final repo = await _pump(
        tester,
        page,
        repo: _Repo()
          ..detail = BerkasDetailEntity(berkas: berkas(noResi: 'TGR2'))
          ..tglCache = DateTime(2026, 10, 15, 6, 30),
      );
      expect(
        find.text('Tanpa sinyal · data terakhir 15/10 06:30'),
        findsOneWidget,
      );

      repo.galat = 'Server sibuk';
      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.text('Server sibuk'), findsOneWidget);
      expect(find.text('Ambil Surat'), findsOneWidget);
    });
  });

  group('Pengiriman Surat: scan, kembali, gagal, kartu', () {
    Widget page(PengirimanUseCase u) => BlocProvider(
      create: (_) => DaftarTugasCubit(u)..load(),
      child: _scope(const DaftarTugasPage()),
    );

    testWidgets('Scan Ambil & Kembalikan → muat ulang setelah selesai', (
      tester,
    ) async {
      final repo = await _pump(tester, page, repo: _Repo()..daftar = daftar);

      for (final (tombol, mode) in [
        (find.text('Scan Ambil'), 'ambil'),
        (find.byTooltip('Kembalikan surat ke kantor'), 'kembalikan'),
      ]) {
        final muat = repo.jmlDaftar;
        await tester.tap(tombol);
        await tester.pumpAndSettle();
        expect(find.textContaining(mode), findsOneWidget);
        await tester.tap(find.text('selesai'));
        await tester.pumpAndSettle();
        expect(repo.jmlDaftar, muat + 1);
      }
    });

    testWidgets('kembali dari detail → daftar dimuat ulang', (tester) async {
      final repo = await _pump(tester, page, repo: _Repo()..daftar = daftar);
      final muat = repo.jmlDaftar;

      await tester.tap(find.byType(BerkasCard).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('selesai'));
      await tester.pumpAndSettle();

      expect(repo.jmlDaftar, muat + 1);
    });

    testWidgets('gagal memuat & pencarian tanpa hasil', (tester) async {
      final repo = await _pump(tester, page, repo: _Repo()..galat = 'Putus');

      expect(find.text('Putus'), findsOneWidget);
      repo
        ..galat = null
        ..daftar = daftar;
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();
      expect(find.text('HMB1'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text('"zzz" tidak ditemukan di tab ini.'), findsOneWidget);
    });

    testWidgets('kartu: kembalikan ke kantor, percobaan, antrean, SLA', (
      tester,
    ) async {
      BerkasEntity b(
        String resi,
        StatusBerkas s, {
        bool kembali = false,
        int percobaan = 0,
        int antre = 0,
        DateTime? sla,
      }) => BerkasEntity(
        noResi: resi,
        jenis: JenisSurat.himbauan,
        jenisNama: 'Himbauan',
        namaWp: 'WP $resi',
        alamatTujuan: 'Jl. $resi',
        status: s,
        statusNama: s.label,
        perluDikembalikan: kembali,
        percobaanKe: percobaan,
        antreanTertunda: antre,
        tglBatasSla: sla,
      );

      await _pump(
        tester,
        page,
        repo: _Repo()
          ..daftar = [
            b(
              'D1',
              StatusBerkas.dalamPerjalanan,
              percobaan: 3,
              antre: 1,
              sla: DateTime.now().add(const Duration(days: 2)),
            ),
            b('G1', StatusBerkas.dibatalkan, kembali: true),
            b('G2', StatusBerkas.gagalAntar, kembali: true),
          ],
      );

      await _geserKeKiri(tester);
      expect(find.text('Percobaan ke-3'), findsOneWidget);
      expect(find.text('Belum terkirim'), findsOneWidget);
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);

      await _geserKeKiri(tester);
      expect(find.text('Dibatalkan, kembalikan ke kantor'), findsOneWidget);
      expect(find.text('Kembalikan berkas ke kantor'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

/// Balasan Dio untuk foto jejak: PNG 1×1.
class _GambarAdapter implements HttpClientAdapter {
  static final _png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
  );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromBytes(_png, 200);

  @override
  void close({bool force = false}) {}
}
