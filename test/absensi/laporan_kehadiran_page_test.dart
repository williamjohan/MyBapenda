import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/core/storage/app_preference.dart';
import 'package:bapendacore/core/storage/app_secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bapendacore/core/theme/theme_mode_cubit.dart';
import 'package:bapendacore/domain/entities/absensi/absen_entity.dart';
import 'package:bapendacore/domain/entities/absensi/riwayat_absensi_entity.dart';
import 'package:bapendacore/domain/entities/absensi/ringkasan_absensi_entity.dart';
import 'package:bapendacore/domain/repositories/absensi/absensi_repository.dart';
import 'package:bapendacore/domain/usecases/absensi/absensi_usecase.dart';
import 'package:bapendacore/presentation/features/laporan_kehadiran/cubit/laporan_cubit.dart';
import 'package:bapendacore/presentation/features/laporan_kehadiran/pages/laporan_kehadiran_page.dart';
import 'package:bapendacore/presentation/features/laporan_kehadiran/widgets/laporan_result_card.dart';
import 'package:bapendacore/core/theme/adaptive_theme_scope.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Repo implements AbsensiRepository {
  final List<(int, int)> requested = [];

  @override
  Future<Either<Failure, String>> downloadLaporanPdf({
    required int tahun,
    required int bulan,
    void Function(double? progress)? onProgress,
  }) async {
    requested.add((tahun, bulan));
    onProgress?.call(0.5);
    return Right('/docs/laporan_absensi/Kehadiran_1_$tahun$bulan.pdf');
  }

  @override
  Future<Either<Failure, AbsenResultEntity>> absen(AbsenParams params) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, RingkasanAbsensiEntity>> getRingkasan({
    DateTime? tanggal,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, RiwayatAbsensiPageResult>> getRiwayat({
    required int page,
    int pageSize = 20,
    int? tahun,
    int? bulan,
  }) => throw UnimplementedError();
}

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  setUp(() {
    // open_filex dipanggil setelah unduh sukses; balas "done" di test.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('open_file'), (_) async {
          return '{"type":0,"message":"done"}';
        });
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('pilih bulan lalu unduh (${mode.name})', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({'theme_mode': mode.name});
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      final repo = _Repo();

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
              BlocProvider(create: (_) => LaporanCubit(AbsensiUseCase(repo))),
            ],
            child: const AdaptiveThemeScope(child: LaporanKehadiranPage()),
          ),
        ),
      );
      await tester.pump();

      final now = DateTime.now();
      final bulanIni = DateFormat('MMMM', 'id_ID').format(now);
      expect(find.text(bulanIni), findsOneWidget);

      // Bulan Januari selalu bisa dipilih (tidak di masa depan).
      await tester.tap(find.text('Januari'));
      await tester.pump();
      final label = 'Januari ${now.year}';
      expect(find.text(label), findsOneWidget);

      await tester.tap(find.text('Unduh PDF $label'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(repo.requested.single, (now.year, 1));
      expect(find.byType(LaporanResultCard), findsOneWidget);
      expect(find.text('Kehadiran_1_${now.year}1.pdf'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('bulan setelah bulan berjalan tidak bisa dipilih', (
    tester,
  ) async {
    final now = DateTime.now();
    if (now.month == 12) return; // Desember: tidak ada bulan masa depan.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = AppPreferences(await SharedPreferences.getInstance());
    final repo = _Repo();

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
            BlocProvider(create: (_) => LaporanCubit(AbsensiUseCase(repo))),
          ],
          child: const AdaptiveThemeScope(child: LaporanKehadiranPage()),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Desember'));
    await tester.pump();

    expect(find.text('Desember ${now.year}'), findsNothing);
  });
}
