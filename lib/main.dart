import 'package:mybapenda/core/constants/app_colors_new.dart';
import 'package:mybapenda/core/services/notifikasi/notifikasi_service.dart';
import 'package:mybapenda/core/utils/app_system_bar_scope.dart';
import 'package:mybapenda/core/utils/file_cache_utils.dart';
import 'package:mybapenda/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:mybapenda/presentation/features/auth/cubit/auth_state.dart';
import 'package:mybapenda/presentation/features/pengiriman/cubit/antrean/antrean_pengiriman_cubit.dart';
import 'package:mybapenda/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/di/injection.dart';
import 'core/theme/theme_mode_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID');
  await configureDependencies();
  await FileCacheHelper.clearCache();

  // Notifikasi petugas (SignalR di foreground service, tanpa Firebase).
  // Ikuti status login SEBELUM checkSession: listener di MyApp terpasang
  // setelah build pertama dan bisa melewatkan AuthAuthenticated awal.
  final notifikasi = getIt<NotifikasiService>();
  await notifikasi.siapkan();
  final authCubit = getIt<AuthCubit>();
  authCubit.stream.listen((state) {
    if (state is AuthAuthenticated) {
      notifikasi.mulai();
    } else if (state is AuthUnauthenticated ||
        state is AuthNeedsPasswordReset) {
      notifikasi.berhenti();
    }
  });
  authCubit.checkSession();

  final themeCubit = getIt<ThemeModeCubit>();
  await themeCubit.syncWithCurrentUser();

  // Antrean offline Pengiriman Surat: kirim ulang otomatis (online/resume).
  final antreanCubit = getIt<AntreanPengirimanCubit>()..muat();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<ThemeModeCubit>.value(value: themeCubit),
        BlocProvider<AntreanPengirimanCubit>.value(value: antreanCubit),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, curr) =>
          curr is! AuthLoading && prev.runtimeType != curr.runtimeType,
      listener: (context, _) {
        context.read<ThemeModeCubit>().syncWithCurrentUser();
        // Antrean disimpan per NIP: muat ulang milik akun yang aktif.
        context.read<AntreanPengirimanCubit>().muat();
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        title: 'MyBapenda',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppThemeColors.primary),
          fontFamily: 'Poppins',
          useMaterial3: true,
        ),
        builder: (context, child) {
          return AppSystemBarScope(child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }
}
