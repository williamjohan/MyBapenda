import 'package:mybapenda/presentation/features/splashscreen/cubit/splash_cubit.dart';
import 'package:mybapenda/presentation/features/splashscreen/cubit/splash_state.dart';
import 'package:mybapenda/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_colors_new.dart';

const String _kLottieAsset = 'assets/lotties/my_bapenda_splash_orange.json';
const Color _kSplashBackground = AppThemeColors.brown;
const Color _kSplashBottom = AppThemeColors.brownDarkerBackground;

class SplashOrangeScreen extends StatefulWidget {
  const SplashOrangeScreen({super.key});

  @override
  State<SplashOrangeScreen> createState() => _SplashOrangeScreenState();
}

class _SplashOrangeScreenState extends State<SplashOrangeScreen>
    with SingleTickerProviderStateMixin {
  // Komposisi Lottie: 180 frame @ 60 fps (3 detik).
  // Frame 0-100 = intro, frame 100-180 = idle yang aman diulang.
  static const double _totalFrames = 180;
  static const double _loopStartFrame = 100;

  late final AnimationController _controller;

  String? _pendingRoute;
  bool _introDone = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // Gambar sampai ke belakang status bar & navigation bar.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SplashCubit>().start();
    });
  }

  Future<void> _run(LottieComposition composition) async {
    _controller.duration = composition.duration;
    try {
      await _controller.animateTo(1.0).orCancel;
      _introDone = true;
      _tryNavigate();

      while (mounted && !_navigated && _pendingRoute == null) {
        _controller.value = _loopStartFrame / _totalFrames;
        await _controller.animateTo(1.0).orCancel;
      }
      _tryNavigate();
    } on TickerCanceled {
      // Widget di-dispose saat animasi berjalan, abaikan.
    }
  }

  String? _routeFor(SplashState state) {
    if (state is SplashNavigateOnboarding) return AppRoutes.onboarding;
    if (state is SplashNavigateHome) return AppRoutes.home;
    if (state is SplashNavigateLogin) return AppRoutes.login;
    return null;
  }

  void _tryNavigate() {
    if (!mounted || _navigated || !_introDone || _pendingRoute == null) return;
    _navigated = true;
    context.go(_pendingRoute!);
  }

  Widget _fallback(BuildContext context, Object error, StackTrace? stack) {
    debugPrint('SPLASH LOTTIE ERROR: $error');
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _introDone = true;
      _tryNavigate();
    });
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        debugPrint('SPLASH LISTENER: ${state.runtimeType}');
        final route = _routeFor(state);
        if (route == null) return;
        _pendingRoute = route;
        _tryNavigate();
      },
      child: _SplashView(
        controller: _controller,
        onLoaded: _run,
        errorBuilder: _fallback,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SplashView extends StatelessWidget {
  final AnimationController controller;
  final void Function(LottieComposition) onLoaded;
  final ImageErrorWidgetBuilder? errorBuilder;

  const _SplashView({
    required this.controller,
    required this.onLoaded,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, 
        systemNavigationBarColor: _kSplashBottom, 
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: _kSplashBackground,
        body: SizedBox.expand(
          child: Lottie.asset(
            _kLottieAsset,
            controller: controller,
            fit: BoxFit.cover,
            onLoaded: onLoaded,
            errorBuilder: errorBuilder,
          ),
        ),
      ),
    );
  }
}