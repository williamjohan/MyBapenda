import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/core/services/geo_location_service.dart';
import 'package:bapendacore/domain/entities/absensi/absen_entity.dart';
import 'package:bapendacore/domain/entities/absensi/riwayat_absensi_entity.dart';
import 'package:bapendacore/domain/entities/absensi/ringkasan_absensi_entity.dart';
import 'package:bapendacore/domain/repositories/absensi/absensi_repository.dart';
import 'package:bapendacore/domain/usecases/absensi/absensi_usecase.dart';
import 'package:bapendacore/presentation/features/absensi/cubit/absen/absen_cubit.dart';
import 'package:bapendacore/presentation/features/absensi/cubit/absensi/absensi_cubit.dart';
import 'package:bapendacore/core/constants/design_system/tokens/app_palette.dart';
import 'package:bapendacore/core/storage/app_preference.dart';
import 'package:bapendacore/core/storage/app_secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bapendacore/core/theme/theme_mode_cubit.dart';
import 'package:bapendacore/core/theme/adaptive_theme_scope.dart';
import 'package:bapendacore/presentation/shared/widgets/theme_toggle_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bapendacore/presentation/features/absensi/pages/absensi_page.dart';
import 'package:bapendacore/presentation/features/absensi/widgets/riwayat_day_group.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

RiwayatAbsensiEntity _scan(
  DateTime t, {
  bool valid = true,
  SumberAbsensi sumber = SumberAbsensi.online,
}) => RiwayatAbsensiEntity(
  tglPresensi: t,
  jenisDevice: sumber == SumberAbsensi.sync ? 2 : 1,
  namaDevice: sumber == SumberAbsensi.sync ? null : 'Ponsel 24069PC21G',
  sumber: sumber,
  isValid: valid,
  namaLokasi: 'Kantor Bapenda Jimerto',
);

class _Repo implements AbsensiRepository {
  @override
  Future<Either<Failure, RingkasanAbsensiEntity>> getRingkasan({
    DateTime? tanggal,
  }) async => Right(
    RingkasanAbsensiEntity(
      nip: '3506192511010005',
      nama: 'Mochammad Miftachun Najib',
      tanggal: DateTime(2026, 10, 2),
      masuk: DateTime(2026, 10, 2, 6, 10, 22),
      jamMasukJadwal: '07:30',
      jamPulangJadwal: '16:30',
    ),
  );

  @override
  Future<Either<Failure, RiwayatAbsensiPageResult>> getRiwayat({
    required int page,
    int pageSize = 20,
    int? tahun,
    int? bulan,
  }) async => Right(
    RiwayatAbsensiPageResult(
      page: page,
      pageSize: pageSize,
      total: 5,
      items: [
        _scan(DateTime(2026, 10, 2, 16, 45, 10)),
        _scan(DateTime(2026, 10, 2, 17, 0), valid: false), // ditolak
        _scan(DateTime(2026, 10, 2, 7, 33, 1)),
        _scan(DateTime(2026, 10, 2, 6, 10, 22), sumber: SumberAbsensi.sync),
        _scan(DateTime(2026, 10, 1, 7, 20)),
      ],
    ),
  );

  int absenCount = 0;

  @override
  Future<Either<Failure, AbsenResultEntity>> absen(AbsenParams params) async {
    absenCount++;
    return Right(
      AbsenResultEntity(
        message: 'Absen pulang tercatat',
        tglPresensi: DateTime(2026, 10, 2, 16, 50),
        jenis: JenisAbsen.pulang,
        ringkasan: RingkasanAbsensiEntity(
          nip: '1',
          nama: 'Mochammad Miftachun Najib',
          tanggal: DateTime(2026, 10, 2),
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, String>> downloadLaporanPdf({
    required int tahun,
    required int bulan,
    void Function(double? progress)? onProgress,
  }) => throw UnimplementedError();
}

class _Location implements GeoLocationService {
  @override
  Future<GeoPosition> getCurrentPosition() async => const GeoPosition(
    latitude: -7.25,
    longitude: 112.74,
    akurasiMeter: 8,
    isMocked: false,
  );
  @override
  Future<void> openAppSettings() async {}
  @override
  Future<void> openLocationSettings() async {}
}

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  Future<_Repo> pumpPage(WidgetTester tester, ThemeMode mode) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({'theme_mode': mode.name});
    final prefs = AppPreferences(await SharedPreferences.getInstance());
    final repo = _Repo();
    final useCase = AbsensiUseCase(repo);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => ThemeModeCubit(
                prefs,
                AppSecureStorage(const FlutterSecureStorage()),
              ),
            ),
            BlocProvider(create: (_) => AbsensiCubit(useCase)..load()),
            BlocProvider(create: (_) => AbsenCubit(useCase, _Location())),
          ],
          child: const AdaptiveThemeScope(child: AbsensiPage()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    return repo;
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('scan pertama = MASUK, terakhir = PULANG (${mode.name})', (
      tester,
    ) async {
      await pumpPage(tester, mode);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(
        scaffold.backgroundColor,
        mode == ThemeMode.dark
            ? AppPalette.dark.background
            : AppPalette.light.background,
      );

      expect(find.textContaining('Mochammad Miftachun'), findsOneWidget);
      // Hero: paling awal 06:10:22 & paling akhir 16:45:10 (scan ditolak diabaikan).
      expect(find.text('06:10:22'), findsNWidgets(2)); // hero + timeline
      expect(find.text('16:45:10'), findsNWidgets(2));
      expect(find.text('--:--:--'), findsNothing);
      // Telat 06:10 vs 07:30 → tidak telat; pulang 16:45 vs 16:30 → tidak cepat.
      expect(find.textContaining('Telat'), findsNothing);

      expect(find.text('Tahan untuk absen pulang'), findsOneWidget);
      expect(find.byType(ThemeToggleButton), findsOneWidget);

      // Tombol absen menempel di bawah layar (bukan di area hero atas).
      final screenHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final tombol = tester.getCenter(find.byIcon(Icons.fingerprint_rounded));
      expect(tombol.dy, greaterThan(screenHeight * 0.75));
      expect(find.text('Jadwal 07:30 – 16:30'), findsOneWidget);

      // Riwayat di bawah lipatan: scroll dulu agar sliver dibangun.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pump();
      expect(find.text('Hari ini'), findsOneWidget);
      expect(find.text('Masuk'), findsWidgets);
      expect(find.text('Pulang'), findsOneWidget);
      expect(find.text('Ditolak'), findsOneWidget);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pump();
      expect(find.text('Kemarin'), findsOneWidget);
      expect(find.byType(RiwayatTimelineTile), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tap singkat tidak mengirim absen', (tester) async {
    final repo = await pumpPage(tester, ThemeMode.light);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.fingerprint_rounded)),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Terus tahan…'), findsOneWidget);
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 400));

    expect(repo.absenCount, 0);
    expect(find.text('Tahan untuk absen pulang'), findsOneWidget);
  });

  testWidgets('tahan sampai penuh mengirim absen tanpa PIN/biometrik', (
    tester,
  ) async {
    final repo = await pumpPage(tester, ThemeMode.dark);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.fingerprint_rounded)),
    );
    for (var i = 0; i < 18; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repo.absenCount, 1);
    expect(find.text('Absen pulang tercatat'), findsOneWidget);
  });
}
