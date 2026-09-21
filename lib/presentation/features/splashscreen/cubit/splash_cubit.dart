// lib/presentation/features/splashscreen/cubit/splash_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart'; // 🚀 IMPORT INJECTABLE
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_state.dart';

@injectable 
class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  void start() => _checkNavigation();

  Future<void> _checkNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Baca status first launch (berguna untuk nanti)
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    
    // Durasi splash screen (memberi waktu logo Bapenda untuk tampil penuh)
    await Future.delayed(const Duration(milliseconds: 2500));

    // =========================================================================
    // TODO: [ONBOARDING] AKTIFKAN KODE DI BAWAH JIKA KONTEN ONBOARDING SIAP
    // =========================================================================
    // Jika nanti desain dan aset onboarding Bapenda sudah selesai,
    // cukup hapus (uncomment) blok kode ini.
    // 
    // if (isFirstLaunch) {
    //   emit(SplashNavigateOnboarding());
    //   return;
    // }
    // =========================================================================

    // Bypass Onboarding (Langsung tembak ke Home)
    emit(SplashNavigateHome());
  }
}