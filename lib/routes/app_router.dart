import 'dart:async';
import 'package:bapendacore/domain/entities/va_qris/payment_session_entity.dart';
import 'package:bapendacore/domain/entities/va_qris/tax_billing_entity.dart';
import 'package:bapendacore/presentation/features/balai_rw/screens/balai_rw_absen_page.dart';
import 'package:bapendacore/presentation/features/balai_rw/screens/balai_rw_laporan_page.dart';
import 'package:bapendacore/presentation/features/balai_rw/screens/balai_rw_page.dart';
import 'package:bapendacore/presentation/features/cek_reklame/screens/history_cek_reklame/history_screen.dart';
import 'package:bapendacore/presentation/features/survey_baru/screens/survey_data_page.dart';
import 'package:bapendacore/presentation/features/survey_baru/screens/survey_foto_page.dart';
import 'package:bapendacore/presentation/features/survey_baru/screens/survey_info_page.dart';
import 'package:bapendacore/presentation/features/survey_baru/screens/survey_permohonan_baru_page.dart';
import 'package:bapendacore/presentation/features/survey_baru/screens/survey_review_page.dart';
import 'package:bapendacore/presentation/features/survey_baru/screens/survey_sisi_page.dart';
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/di/injection.dart';
import '../domain/entities/my_task/task_entity.dart';
import '../presentation/features/absensi/cubit/absen/absen_cubit.dart';
import '../presentation/features/absensi/cubit/absensi/absensi_cubit.dart';
import '../presentation/features/absensi/pages/absensi_page.dart';
import '../presentation/features/laporan_kehadiran/cubit/laporan_cubit.dart';
import '../presentation/features/laporan_kehadiran/pages/laporan_kehadiran_page.dart';
import '../core/theme/theme_kit.dart';
import '../presentation/features/auth/cubit/auth_cubit.dart';
import '../presentation/features/auth/cubit/auth_state.dart';
import '../presentation/features/cek_reklame/screens/cek_reklame_dashboard_screen.dart';
import '../presentation/features/cek_reklame/screens/ambil_gambar_reklame/reklame_result_screen.dart';
import '../presentation/features/home/cubit/home_cubit.dart';
import '../presentation/features/home/pages/home_page.dart';
import '../presentation/features/my_task/pages/my_task_dashboard_page.dart';
import '../presentation/features/my_task/pages/my_task_detail_page.dart';
import '../presentation/features/my_task/pages/my_task_success_page.dart';
import '../presentation/features/my_task/pages/my_task_work_page.dart';
import '../presentation/features/splashscreen/cubit/splash_cubit.dart';
import '../presentation/features/splashscreen/pages/splash_page.dart';
import '../presentation/features/onboarding/pages/onboarding_page.dart';
import '../presentation/features/auth/pages/login_page.dart';
import '../presentation/features/camera/cubit/camera_cubit.dart';
import '../presentation/features/camera/pages/camera_page.dart';
import '../presentation/features/va_qris/pages/payment_success_page.dart';
import '../presentation/features/va_qris/pages/qris_payment_page.dart';
import '../presentation/features/va_qris/pages/va_payment_page.dart';
import '../presentation/features/va_qris/pages/va_qris_billing_page.dart';
import '../presentation/features/va_qris/pages/va_qris_nop_page.dart';

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
              child: const AdaptiveThemeScope(child: HomePage()),
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

      //  CAMERA PAGE
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

      //  ABSENSI PEGAWAI
      GoRoute(
        path: AppRoutes.absensi,
        name: AppRoutes.absensi,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<AbsensiCubit>()..load()),
            BlocProvider(create: (_) => getIt<AbsenCubit>()),
          ],
          child: const AdaptiveThemeScope(child: AbsensiPage()),
        ),
      ),

      GoRoute(
        path: AppRoutes.laporanKehadiran,
        name: AppRoutes.laporanKehadiran,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<LaporanCubit>(),
          child: const AdaptiveThemeScope(child: LaporanKehadiranPage()),
        ),
      ),

      GoRoute(
        path: AppRoutes.balaiRw,
        name: AppRoutes.balaiRw,
        builder: (context, state) => const BalaiRwPage(),
      ),

      GoRoute(
        path: AppRoutes.balaiRwAbsen,
        name: AppRoutes.balaiRwAbsen,
        builder: (context, state) {
          final a =
              state.extra
                  as ({
                    BalaiRwAbsenType type,
                    Map<String, dynamic> penugasan,
                    Map<String, dynamic>? initial,
                    bool readOnly,
                  });
          return BalaiRwAbsenPage(
            type: a.type,
            penugasan: a.penugasan,
            initial: a.initial,
            readOnly: a.readOnly,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.balaiRwLaporan,
        name: AppRoutes.balaiRwLaporan,
        builder: (context, state) {
          final a =
              state.extra
                  as ({
                    Map<String, dynamic> penugasan,
                    Map<String, dynamic>? initial,
                    bool readOnly,
                  });
          return BalaiRwLaporanPage(
            penugasan: a.penugasan,
            initial: a.initial,
            readOnly: a.readOnly,
          );
        },
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
        path: AppRoutes.surveyPermohonanBaru,
        name: AppRoutes.surveyPermohonanBaru,
        builder: (context, state) => const SurveyPermohonanBaruPage(),
      ),
      GoRoute(
        path: AppRoutes.surveyInfo,
        name: AppRoutes.surveyInfo,
        builder: (context, state) {
          final args =
              state.extra
                  as ({String nomor, List<Map<String, dynamic>> sisiList});
          return SurveyInfoPage(
            nomorPelayanan: args.nomor,
            sisiList: args.sisiList,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.surveySisi,
        name: AppRoutes.surveySisi,
        builder: (context, state) {
          final args =
              state.extra
                  as ({
                    String nomor,
                    List<Map<String, dynamic>> sisiList,
                    Map<String, dynamic> info,
                  });
          return SurveySisiPage(
            nomorPelayanan: args.nomor,
            sisiList: args.sisiList,
            info: args.info,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.surveyReview,
        name: AppRoutes.surveyReview,
        builder: (context, state) {
          final args =
              state.extra
                  as ({
                    String nomor,
                    List<Map<String, dynamic>> sisiList,
                    Map<int, SurveyResult> results,
                    Map<String, dynamic> info,
                  });
          return SurveyReviewPage(
            nomorPelayanan: args.nomor,
            sisiList: args.sisiList,
            results: args.results,
            info: args.info,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.surveyFoto,
        name: AppRoutes.surveyFoto,
        builder: (context, state) {
          final args =
              state.extra
                  as ({Map<String, dynamic> sisi, SurveyResult? result});
          return SurveyFotoPage(sisi: args.sisi, initialResult: args.result);
        },
      ),
      GoRoute(
        path: AppRoutes.surveyData,
        name: AppRoutes.surveyData,
        builder: (context, state) {
          final args =
              state.extra
                  as ({
                    Map<String, dynamic> sisi,
                    Map<String, dynamic>? initial,
                  });
          return SurveyDataPage(sisi: args.sisi, initial: args.initial);
        },
      ),

      GoRoute(
        path: AppRoutes.results,
        name: AppRoutes.results,
        builder: (context, state) {
          // Tangkap extra data (alamat) jika ada
          final address = state.extra as String?;
          return ReklameResultPage(address: address);
        },
      ),

      // ======================================================
      // VA & QRIS
      // TODO(tech-debt): `extra` hilang saat deep link / restore state.
      // Setelah VaQrisCubit ada, kirim NOP/id saja lalu muat dari state.
      // Jika extra tidak sesuai, kembali ke layar input NOP.
      // ======================================================
      GoRoute(
        path: AppRoutes.nop,
        name: AppRoutes.nop,
        builder: (context, state) => const VaQrisNopPage(),
      ),

      GoRoute(
        path: AppRoutes.billing,
        name: AppRoutes.billing,
        builder: (context, state) {
          final billing = state.extra;
          return billing is TaxBillingEntity
              ? VaQrisBillingPage(billing: billing)
              : const VaQrisNopPage();
        },
      ),

      GoRoute(
        path: AppRoutes.qris,
        name: AppRoutes.qris,
        builder: (context, state) {
          final session = state.extra;
          return session is PaymentSessionEntity
              ? QrisPaymentPage(session: session)
              : const VaQrisNopPage();
        },
      ),

      GoRoute(
        path: AppRoutes.va,
        name: AppRoutes.va,
        builder: (context, state) {
          final session = state.extra;
          return session is PaymentSessionEntity
              ? VaPaymentPage(session: session)
              : const VaQrisNopPage();
        },
      ),

      GoRoute(
        path: AppRoutes.success,
        name: AppRoutes.success,
        builder: (context, state) {
          final session = state.extra;
          return session is PaymentSessionEntity
              ? PaymentSuccessPage(session: session)
              : const VaQrisNopPage();
        },
      ),

       GoRoute(
        path: AppRoutes.myTask,
        name: AppRoutes.myTask,
        builder: (context, state) => const MyTaskDashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.myTaskDetail,
        name: AppRoutes.myTaskDetail,
        builder: (context, state) {
          final task = state.extra;
          return task is TaskEntity
              ? MyTaskDetailPage(task: task)
              : const MyTaskDashboardPage();
        },
      ),
      GoRoute(
        path: AppRoutes.myTaskWork,
        name: AppRoutes.myTaskWork,
        builder: (context, state) {
          final task = state.extra;
          return task is TaskEntity
              ? MyTaskWorkPage(task: task)
              : const MyTaskDashboardPage();
        },
      ),
      GoRoute(
        path: AppRoutes.myTaskSuccess,
        name: AppRoutes.myTaskSuccess,
        builder: (context, state) {
          final task = state.extra;
          return task is TaskEntity
              ? MyTaskSuccessPage(task: task)
              : const MyTaskDashboardPage();
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
