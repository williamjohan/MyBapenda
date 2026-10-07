import 'package:bapendacore/core/storage/app_preference.dart';
import 'package:bapendacore/core/storage/app_secure_storage.dart';
import 'package:bapendacore/core/theme/theme_kit.dart';
import 'package:bapendacore/presentation/features/home/widgets/home_bapenda_core_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _secureKeyNip = 'SECURE_CURRENT_NIP';

Future<(ThemeModeCubit, SharedPreferences)> _cubit({
  Map<String, Object> prefs = const {},
  String? loggedInNip,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  FlutterSecureStorage.setMockInitialValues({
    if (loggedInNip != null) _secureKeyNip: loggedInNip,
  });
  final raw = await SharedPreferences.getInstance();
  final cubit = ThemeModeCubit(
    AppPreferences(raw),
    AppSecureStorage(const FlutterSecureStorage()),
  );
  return (cubit, raw);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeModeCubit per profil pengguna', () {
    test('default mengikuti sistem', () async {
      final (cubit, _) = await _cubit();
      await cubit.syncWithCurrentUser();
      expect(cubit.state, ThemeMode.system);
      expect(cubit.userKey, isNull);
    });

    test('pilihan disimpan ke key milik NIP yang login', () async {
      final (cubit, raw) = await _cubit(loggedInNip: '199001');
      await cubit.syncWithCurrentUser();
      await cubit.setMode(ThemeMode.dark);

      expect(raw.getString('theme_mode_199001'), 'dark');
      expect(raw.getString('theme_mode'), isNull); // tamu tidak tersentuh
    });

    test('tiap pegawai punya tema sendiri di HP yang sama', () async {
      final (cubit, raw) = await _cubit(
        prefs: {'theme_mode_A': 'dark', 'theme_mode_B': 'light'},
        loggedInNip: 'A',
      );
      await cubit.syncWithCurrentUser();
      expect(cubit.state, ThemeMode.dark);

      // Logout A, login B.
      await const FlutterSecureStorage().write(key: _secureKeyNip, value: 'B');
      await cubit.syncWithCurrentUser();
      expect(cubit.state, ThemeMode.light);

      // Logout → kembali ke preferensi tamu.
      await const FlutterSecureStorage().delete(key: _secureKeyNip);
      await cubit.syncWithCurrentUser();
      expect(cubit.state, ThemeMode.system);
      expect(raw.getString('theme_mode_A'), 'dark'); // tetap tersimpan
    });

    test('user baru mewarisi pilihan tamu', () async {
      final (cubit, _) = await _cubit(
        prefs: {'theme_mode': 'dark'},
        loggedInNip: 'BARU',
      );
      await cubit.syncWithCurrentUser();
      expect(cubit.state, ThemeMode.dark);
    });
  });

  test('AppThemeUtils.resolveIsDark', () {
    expect(AppThemeUtils.resolveIsDark(ThemeMode.dark, Brightness.light), true);
    expect(
      AppThemeUtils.resolveIsDark(ThemeMode.light, Brightness.dark),
      false,
    );
    expect(
      AppThemeUtils.resolveIsDark(ThemeMode.system, Brightness.dark),
      true,
    );
  });

  testWidgets('ikon di header Home berpindah terang ↔ gelap', (tester) async {
    final (cubit, _) = await _cubit(prefs: {'theme_mode': 'light'});

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(
          home: AdaptiveThemeScope(
            child: Scaffold(
              body: HomeBapendaCoreHeader(userName: 'A', userRole: 'B'),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.dark_mode_rounded));
    await tester.pumpAndSettle();

    expect(cubit.state, ThemeMode.dark);
    final context = tester.element(find.byType(HomeBapendaCoreHeader));
    expect(context.isDarkMode, isTrue);
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.light_mode_rounded));
    await tester.pumpAndSettle();
    expect(cubit.state, ThemeMode.light);
    expect(tester.takeException(), isNull);
  });
}
