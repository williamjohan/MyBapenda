// lib/presentation/features/home/bloc/home_action.dart
import 'package:mybapenda/core/services/update_service.dart';

sealed class HomeAction {
  const HomeAction();
}

class HomeShowUpdateDialog extends HomeAction {
  final UpdateInfo updateInfo;
  const HomeShowUpdateDialog(this.updateInfo);
}

class HomeNavigateToCamera extends HomeAction {
  const HomeNavigateToCamera();
}

class HomeShowPermissionDenied extends HomeAction {
  const HomeShowPermissionDenied();
}

class HomeShowGpsDisabled extends HomeAction {
  const HomeShowGpsDisabled();
}

class HomeShowPermissionPermanentlyDenied extends HomeAction {
  const HomeShowPermissionPermanentlyDenied();
}
