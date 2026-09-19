import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  void start() => _checkNavigation();

  Future<void> _checkNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    await Future.delayed(const Duration(seconds: 3));
    emit(isFirstLaunch ? SplashNavigateOnboarding() : SplashNavigateHome());
  }
}