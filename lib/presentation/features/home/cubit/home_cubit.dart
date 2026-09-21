import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/permission/i_permission_service.dart';
import '../../../../core/services/update_service.dart';
import '../../../../core/utils/app_logger.dart';
import 'home_state.dart';
import 'home_action.dart';

@injectable // WAJIB @injectable, BUKAN @lazySingleton
class HomeCubit extends Cubit<HomeState> {
  final UpdateService updateService;
  final IPermissionService permissionService;
  

  HomeCubit({
    required this.updateService,
    required this.permissionService,
  }) : super(const HomeState());

  Future<void> onPageOpened() async {
    if (isClosed) return;
    emit(state.copyWith(isCheckingUpdate: true));
    
    try {
      // --- AREA MOCK PROFIL (Nanti diganti dengan fetch dari Hive/Prefs) ---
      await Future.delayed(const Duration(milliseconds: 500)); 
      if (isClosed) return; // Proteksi setelah await
      
      const mockUserName = 'William Saliba';
      const mockUserRole = 'Divisi IT';
      // --------------------------------------------------------------------

      final updateInfo = await updateService.getAvailableUpdate();
      if (isClosed) return;
      
      emit(
        state.copyWith(
          isCheckingUpdate: false,
          updateInfo: updateInfo,
          action: updateInfo != null ? HomeShowUpdateDialog(updateInfo) : null,
          userName: mockUserName,
          userRole: mockUserRole,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load home data', e, stackTrace);
      
      if (isClosed) return;
      emit(state.copyWith(
        isCheckingUpdate: false,
        userName: 'Guest',
        userRole: 'Bapenda Core',
      ));
    }
  }


  void onManualCheckUpdate() {
    if (isClosed) return;
    
    final info = state.updateInfo;
    if (info != null) {
      emit(state.copyWith(action: HomeShowUpdateDialog(info)));
    }
  }

  void clearAction() {
    if (isClosed) return;
    emit(state.copyWith(action: null));
  }
}