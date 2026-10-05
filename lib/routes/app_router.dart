import 'dart:async';
import 'package:bapendacore/presentation/features/cek_reklame/screens/history_cek_reklame/history_screen.dart';
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/di/injection.dart';
import '../presentation/features/auth/cubit/auth_cubit.dart';
import '../presentation/features/auth/cubit/auth_state.dart';
import '../presentation/features/cek_reklame/screens/cek_reklame_dashboard_screen.dart';
import '../presentation/features/cek_reklame/screens/ambil_gambar_reklame/reklame_result_screen.dart';
import '../presentation/features/home/cubit/home_cubit.dart';
import '../presentation/features/home/pages/home_page.dart';
import '../presentation/features/splashscreen/cubit/splash_cubit.dart';
import '../presentation/features/splashscreen/pages/splash_page.dart';
import '../presentation/features/onboarding/pages/onboarding_page.dart';
import '../presentation/features/auth/pages/login_page.dart';
import '../presentation/features/camera/cubit/camera_cubit.dart';
import '../presentation/features/camera/pages/camera_page.dart';

import 'app_routes.dart';

class AppRouter {
  // Cegah instansiasi
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static const List<String> _publicRoutes = [
    AppRoutes.splashscreen,
    AppRoutes.onboarding,
    AppRoutes.login,
  ];

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,

    observers: kDebugMode ? [ChuckerFlutter.navigatorObserver] : [],

    initialLocation: AppRoutes.splashscreen,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: GoRouterRefreshStream(getIt<AuthCubit>().stream),

    redirect: (context, state) {
      final authState = getIt<AuthCubit>().state;
      final location = state.matchedLocation;

      if (location == AppRoutes.splashscreen) return null;

      final isAuthenticated = authState is AuthAuthenticated;
      final isPublicRoute = _publicRoutes.contains(location);

      if (!isAuthenticated && !isPublicRoute) {
        return AppRoutes.login;
      }

      if (isAuthenticated &&
          (location == AppRoutes.login || location == AppRoutes.onboarding)) {
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.splashscreen,
        name: AppRoutes.splashscreen,
        builder: (context, state) => BlocProvider(
          create: (_) => SplashCubit()..start(),
          child: const SplashScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),

      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.home,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider<HomeCubit>(
              create: (_) => getIt<HomeCubit>()..onPageOpened(),
              child: const HomePage(),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      GoRoute(
        path: AppRoutes.reklameDashboard,
        name: AppRoutes.reklameDashboard,
        builder: (context, state) => const ReklameDashboardPage(),
      ),

      // 🚀 ROUTE BARU: CAMERA PAGE
      GoRoute(
        path: AppRoutes.camera,
        name: AppRoutes.camera,
        builder: (context, state) {
          return BlocProvider<CameraCubit>(
            // .start() langsung dipanggil saat halaman dibuka untuk cek GPS & Permission
            create: (_) => getIt<CameraCubit>()..start(), 
            child: const CameraPage(),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.history,
        name: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
      ),

      // GoRoute(
      //   path: AppRoutes.detail,
      //   name: AppRoutes.detail,
      //   builder: (context, state) {
      //     final billboard = state.extra as BillboardEntity;
      //     return BillboardDetailScreen(billboard: billboard);
      //   },
      // ),

      GoRoute(
        path: AppRoutes.results,
        name: AppRoutes.results,
        builder: (context, state) {
          // Tangkap extra data (alamat) jika ada
          final address = state.extra as String?;
          return ReklameResultPage(address: address);
        },
      ),
      
    ],
  );
}

/// Jembatanin Stream (state Cubit) jadi Listenable yang dibutuhin
/// GoRouter's `refreshListenable`.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}