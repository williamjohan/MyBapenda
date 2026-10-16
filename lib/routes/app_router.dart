import 'dart:async';
import 'package:bapendacore/domain/entities/va_qris/payment_session_entity.dart';
import 'package:bapendacore/domain/entities/va_qris/tax_billing_entity.dart';
import 'package:bapendacore/domain/usecases/auth/auth_usecase.dart';
import 'package:bapendacore/domain/usecases/survey_permohonan/survey_permohonan_usecase.dart';
import 'package:bapendacore/presentation/features/balai_rw/cubit/balai_rw_form_cubit.dart';
import 'package:bapendacore/presentation/features/balai_rw/cubit/balai_rw_hub_cubit.dart';
import 'package:bapendacore/presentation/features/balai_rw/screens/balai_rw_absen_page.dart';
import 'package:bapendacore/presentation/features/balai_rw/screens/balai_rw_laporan_page.dart';
import 'package:bapendacore/presentation/features/balai_rw/screens/balai_rw_page.dart';
import 'package:bapendacore/presentation/features/cek_reklame/screens/history_cek_reklame/history_screen.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_data/survey_data_cubit.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_info/survey_info_cubit.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_list/survey_list_cubit.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_submit/survey_submit_cubit.dart';
import 'package:bapendacore/presentation/features/survey_baru/screens/survey_data_page.dart';
import 'package:bapendacore/presentation/features/survey_baru/screens/survey_foto_page.dart';
import 'package:bapendacore/presentation/features/survey_baru/screens/survey_info_page.dart';
import 'package:bapendacore/presentation/features/survey_baru/screens/survey_permohonan_baru_page.dart';
import 'package:bapendacore/presentation/features/survey_baru/screens/survey_review_page.dart';
import 'package:bapendacore/presentation/features/survey_baru/screens/survey_sisi_page.dart';
import 'package:bapendacore/presentation/shared/master_data/presentation/cubit/master_data_cubit.dart';
import 'package:bapendacore/presentation/shared/master_data/domain/usecases/master_data_usecase.dart';
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
import '../presentation/features/profile/cubit/profile_cubit.dart';
import '../presentation/features/profile/pages/profile_page.dart';
import '../presentation/features/profile/cubit/ubah_kontak_cubit.dart';
import '../presentation/features/profile/pages/ubah_kontak_page.dart';
import '../domain/entities/profile/jenis_kontak.dart';
import '../presentation/features/my_task/pages/my_task_detail_page.dart';
import '../presentation/features/my_task/pages/my_task_success_page.dart';
import '../presentation/features/my_task/pages/my_task_work_page.dart';
import '../presentation/features/pengiriman/cubit/daftar_tugas/daftar_tugas_cubit.dart';
import '../presentation/features/pengiriman/cubit/detail_berkas/detail_berkas_cubit.dart';
import '../presentation/features/pengiriman/cubit/lacak/lacak_cubit.dart';
import '../presentation/features/pengiriman/pages/daftar_tugas_page.dart';
import '../presentation/features/pengiriman/pages/detail_berkas_page.dart';
import '../presentation/features/pengiriman/pages/lacak_page.dart';
import '../presentation/features/pengiriman/pages/pantau_page.dart';
import '../domain/entities/pengiriman/berkas_entity.dart';
import '../domain/entities/pengiriman/pengiriman_payload_entity.dart';
import '../presentation/features/pengiriman/cubit/aksi/aksi_cubit.dart';
import '../presentation/features/pengiriman/pages/aksi/checkin_page.dart';
import '../presentation/features/pengiriman/pages/aksi/gagal_page.dart';
import '../presentation/features/pengiriman/pages/aksi/scan_berkas_page.dart';
import '../presentation/features/pengiriman/pages/aksi/serah_page.dart';
import '../presentation/features/pengiriman/pages/antrean_page.dart';
import '../presentation/features/pengiriman/cubit/pantau/pantau_cubit.dart';
import '../presentation/features/splashscreen/cubit/splash_cubit.dart';
import '../presentation/features/splashscreen/pages/splash_page.dart';
import '../presentation/features/onboarding/pages/onboarding_page.dart';
import '../presentation/features/auth/pages/login_page.dart';
import '../presentation/features/auth/cubit/lupa_password_cubit.dart';
import '../presentation/features/auth/pages/lupa_password_page.dart';
import '../presentation/features/auth/cubit/reset_password_cubit.dart';
import '../presentation/features/auth/pages/reset_password_page.dart';
import '../presentation/features/camera/cubit/camera_cubit.dart';
import '../presentation/features/camera/pages/camera_page.dart';
import '../presentation/features/va_qris/cubit/va_qris_cubit.dart';
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

  /// Lokasi deep link yang dibuka sebelum login; dituju setelah login.
  static String? _tujuanTertunda;

  /// Fallback halaman aksi pengiriman bila `extra` hilang (restore).
  static Widget _daftarTugas() => BlocProvider(
    create: (_) => getIt<DaftarTugasCubit>()..load(),
    child: const AdaptiveThemeScope(child: DaftarTugasPage()),
  );

  static const List<String> _publicRoutes = [
    AppRoutes.splashscreen,
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.lupaPassword,
  ];

  static Widget _vaQrisNopPage() => BlocProvider(
    create: (_) => getIt<VaQrisCubit>()..init(),
    child: const AdaptiveThemeScope(child: VaQrisNopPage()),
  );

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

      // Login pakai reset key: wajib ganti kata sandi dulu.
      if (authState is AuthNeedsPasswordReset) {
        return location == AppRoutes.resetPassword
            ? null
            : AppRoutes.resetPassword;
      }

      final isAuthenticated = authState is AuthAuthenticated;
      final isPublicRoute = _publicRoutes.contains(location);

      if (!isAuthenticated && !isPublicRoute) {
        // Deep link lacak saat belum login (atau sesi belum dicek):
        // simpan, lanjutkan setelah login.
        if (location.startsWith('/lacak/') ||
            location.startsWith('${AppRoutes.home}/lacak/')) {
          _tujuanTertunda = state.uri.toString();
        }
        return AppRoutes.login;
      }

      final tujuan = _tujuanTertunda;
      if (isAuthenticated && tujuan != null) {
        _tujuanTertunda = null;
        return tujuan;
      }

      if (isAuthenticated &&
          (location == AppRoutes.login ||
              location == AppRoutes.onboarding ||
              location == AppRoutes.resetPassword)) {
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
        path: AppRoutes.lupaPassword,
        name: AppRoutes.lupaPassword,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<LupaPasswordCubit>(),
          child: const LupaPasswordPage(),
        ),
      ),

      GoRoute(
        path: AppRoutes.resetPassword,
        name: AppRoutes.resetPassword,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<ResetPasswordCubit>(),
          child: const ResetPasswordPage(),
        ),
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
        routes: [
          // Tujuan deep link lacak: di bawah home supaya tombol kembali
          // berakhir di Home.
          GoRoute(
            path: 'lacak/:kode',
            builder: (context, state) => BlocProvider(
              create: (_) =>
                  getIt<LacakCubit>()..lacak(state.pathParameters['kode']!),
              child: const AdaptiveThemeScope(child: LacakPage()),
            ),
          ),
        ],
      ),

      // App Link QR surat (`/lacak/{noResi}`) → lacak di bawah Home.
      GoRoute(
        path: AppRoutes.lacakDeepLink,
        redirect: (context, state) =>
            '${AppRoutes.home}/lacak/'
            '${Uri.encodeComponent(state.pathParameters['kode']!)}',
      ),

      //  CEK REKLAME
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
        path: AppRoutes.profile,
        name: AppRoutes.profile,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<ProfileCubit>()..load(),
          child: const AdaptiveThemeScope(child: ProfilePage()),
        ),
      ),

      GoRoute(
        path: AppRoutes.profileKontak,
        name: AppRoutes.profileKontak,
        builder: (context, state) {
          // extra hilang saat deep link / restore -> default email kosong.
          final extra = state.extra;
          final args = extra is ({JenisKontak kontak, String nilaiSekarang})
              ? extra
              : (kontak: JenisKontak.email, nilaiSekarang: '');
          return BlocProvider(
            create: (_) => getIt<UbahKontakCubit>()
              ..mulai(kontak: args.kontak, nilaiSekarang: args.nilaiSekarang),
            child: const AdaptiveThemeScope(child: UbahKontakPage()),
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
        builder: (context, state) => BlocProvider<BalaiRwHubCubit>(
          create: (_) => getIt<BalaiRwHubCubit>()..load(),
          child: const BalaiRwPage(),
        ),
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
                    Future<String?> Function(Map<String, dynamic>)? onSubmit,
                  });
          return BalaiRwAbsenPage(
            type: a.type,
            penugasan: a.penugasan,
            initial: a.initial,
            readOnly: a.readOnly,
            onSubmit: a.onSubmit,
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
                    Future<String?> Function(Map<String, String>)? onSubmit,
                  });
          return BlocProvider<BalaiRwFormCubit>(
            create: (_) => getIt<BalaiRwFormCubit>()..load(),
            child: BalaiRwLaporanPage(
              penugasan: a.penugasan,
              initial: a.initial,
              readOnly: a.readOnly,
              onSubmit: a.onSubmit,
            ),
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
        builder: (context, state) => BlocProvider(
          create: (_) =>
              SurveyListCubit(useCase: getIt<SurveyPermohonanUseCase>())
                ..load(),
          child: const SurveyPermohonanBaruPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.surveyInfo,
        name: AppRoutes.surveyInfo,
        builder: (context, state) {
          final args =
              state.extra
                  as ({
                    String nomor,
                    String key,
                    List<Map<String, dynamic>> sisiList,
                  });

          return MultiBlocProvider(
            providers: [
              BlocProvider<MasterDataCubit>.value(
                value: getIt<MasterDataCubit>(),
              ),
              BlocProvider<SurveyInfoCubit>(
                create: (_) => SurveyInfoCubit(
                  nomorPelayanan: args.nomor,
                  masterUseCase: getIt<MasterDataUseCase>(),
                  authUseCase: getIt<AuthUseCase>(),
                ),
              ),
            ],
            child: SurveyInfoPage(
              nomorPelayanan: args.nomor,
              surveyKey: args.key,
              sisiList: args.sisiList,
            ),
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

          return BlocProvider<SurveySubmitCubit>(
            create: (_) =>
                SurveySubmitCubit(useCase: getIt<SurveyPermohonanUseCase>()),
            child: SurveyReviewPage(
              nomorPelayanan: args.nomor,
              sisiList: args.sisiList,
              results: args.results,
              info: args.info,
            ),
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

          return MultiBlocProvider(
            providers: [
              BlocProvider<MasterDataCubit>.value(
                value: getIt<MasterDataCubit>(),
              ),
              BlocProvider<SurveyDataCubit>(
                create: (_) =>
                    SurveyDataCubit(sisi: args.sisi, initial: args.initial),
              ),
            ],
            child: SurveyDataPage(sisi: args.sisi, initial: args.initial),
          );
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

      GoRoute(
        path: AppRoutes.nop,
        name: AppRoutes.nop,
        builder: (context, state) => _vaQrisNopPage(),
      ),

      GoRoute(
        path: AppRoutes.billing,
        name: AppRoutes.billing,
        builder: (context, state) {
          final billing = state.extra;
          return billing is TaxBillingEntity
              ? BlocProvider(
                  create: (_) => getIt<VaQrisCubit>()..loadBilling(billing),
                  child: const AdaptiveThemeScope(child: VaQrisBillingPage()),
                )
              : _vaQrisNopPage();
        },
      ),

      GoRoute(
        path: AppRoutes.qris,
        name: AppRoutes.qris,
        builder: (context, state) {
          final session = state.extra;
          return session is PaymentSessionEntity
              ? BlocProvider(
                  create: (_) => getIt<VaQrisCubit>()..startSession(session),
                  child: AdaptiveThemeScope(
                    child: QrisPaymentPage(session: session),
                  ),
                )
              : _vaQrisNopPage();
        },
      ),

      GoRoute(
        path: AppRoutes.va,
        name: AppRoutes.va,
        builder: (context, state) {
          final session = state.extra;
          return session is PaymentSessionEntity
              ? BlocProvider(
                  create: (_) => getIt<VaQrisCubit>()..startSession(session),
                  child: AdaptiveThemeScope(
                    child: VaPaymentPage(session: session),
                  ),
                )
              : _vaQrisNopPage();
        },
      ),

      GoRoute(
        path: AppRoutes.success,
        name: AppRoutes.success,
        builder: (context, state) {
          final session = state.extra;
          return session is PaymentSessionEntity
              ? AdaptiveThemeScope(child: PaymentSuccessPage(session: session))
              : _vaQrisNopPage();
        },
      ),

      //  PENGIRIMAN SURAT
      GoRoute(
        path: AppRoutes.pengiriman,
        name: AppRoutes.pengiriman,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<DaftarTugasCubit>()..load(),
          child: const AdaptiveThemeScope(child: DaftarTugasPage()),
        ),
      ),
      GoRoute(
        path: AppRoutes.pengirimanDetail,
        name: AppRoutes.pengirimanDetail,
        builder: (context, state) {
          final extra = state.extra;
          // extra hilang saat restore: arahkan ke daftar Pantau.
          if (extra is! String) {
            return BlocProvider(
              create: (_) => getIt<PantauCubit>()..load(),
              child: const AdaptiveThemeScope(child: PantauPage()),
            );
          }
          return BlocProvider(
            create: (_) => getIt<DetailBerkasCubit>()..load(extra),
            child: AdaptiveThemeScope(child: DetailBerkasPage(noResi: extra)),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.pengirimanLacak,
        name: AppRoutes.pengirimanLacak,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<PantauCubit>()..load(),
          child: const AdaptiveThemeScope(child: PantauPage()),
        ),
      ),
      GoRoute(
        path: AppRoutes.pengirimanLacakDetail,
        name: AppRoutes.pengirimanLacakDetail,
        builder: (context, state) {
          final extra = state.extra;
          // extra hilang saat restore: kembali ke daftar Pantau.
          if (extra is! String) {
            return BlocProvider(
              create: (_) => getIt<PantauCubit>()..load(),
              child: const AdaptiveThemeScope(child: PantauPage()),
            );
          }
          return BlocProvider(
            create: (_) => getIt<LacakCubit>()..lacak(extra),
            child: const AdaptiveThemeScope(child: LacakPage()),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.pengirimanScan,
        name: AppRoutes.pengirimanScan,
        builder: (context, state) {
          final extra = state.extra;
          final arg = extra is ({ModeScanBerkas mode, List<String> awal})
              ? extra
              : (mode: ModeScanBerkas.ambil, awal: const <String>[]);
          return BlocProvider(
            create: (_) => getIt<AksiCubit>()..init(),
            child: AdaptiveThemeScope(
              child: ScanBerkasPage(mode: arg.mode, awal: arg.awal),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.pengirimanCheckin,
        name: AppRoutes.pengirimanCheckin,
        builder: (context, state) {
          final extra = state.extra;
          // extra hilang saat restore: kembali ke daftar tugas.
          if (extra is! ({String noResi, JenisCheckin jenis})) {
            return _daftarTugas();
          }
          return BlocProvider(
            create: (_) => getIt<AksiCubit>()..init(),
            child: AdaptiveThemeScope(
              child: CheckinPage(noResi: extra.noResi, jenis: extra.jenis),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.pengirimanSerah,
        name: AppRoutes.pengirimanSerah,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! BerkasEntity) return _daftarTugas();
          return BlocProvider(
            create: (_) => getIt<AksiCubit>()..init(butuhMaster: true),
            child: AdaptiveThemeScope(child: SerahPage(berkas: extra)),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.pengirimanGagal,
        name: AppRoutes.pengirimanGagal,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! String) return _daftarTugas();
          return BlocProvider(
            create: (_) => getIt<AksiCubit>()..init(butuhMaster: true),
            child: AdaptiveThemeScope(child: GagalPage(noResi: extra)),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.pengirimanAntrean,
        name: AppRoutes.pengirimanAntrean,
        // AntreanPengirimanCubit app-global (disediakan di main.dart).
        builder: (context, state) =>
            const AdaptiveThemeScope(child: AntreanPage()),
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
