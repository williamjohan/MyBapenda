import 'package:bapendacore/domain/usecases/auth/auth_usecase.dart';
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
  final AuthUseCase authUseCase;

  HomeCubit({
    required this.updateService,
    required this.permissionService,
    required this.authUseCase,
  }) : super(const HomeState());

  Future<void> onPageOpened() async {
    if (isClosed) return;

    emit(state.copyWith(isCheckingUpdate: true));

    try {
      final profile = await authUseCase.getCurrentUserProfile();
      if (isClosed) return;

      final updateInfo = await updateService.getAvailableUpdate();
      if (isClosed) return;

      emit(
        state.copyWith(
          isCheckingUpdate: false,
          updateInfo: updateInfo,
          action: updateInfo != null ? HomeShowUpdateDialog(updateInfo) : null,
          userName: profile?.nama ?? 'Guest',
          userRole: profile?.jabatan ?? 'Bapenda Core',
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load home data', e, stackTrace);

      if (isClosed) return;

      emit(
        state.copyWith(
          isCheckingUpdate: false,
          userName: 'Guest',
          userRole: 'Bapenda Core',
        ),
      );
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
