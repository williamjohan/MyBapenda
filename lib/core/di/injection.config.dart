// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../data/datasources/absensi/absensi_remote_datasource.dart' as _i753;
import '../../data/datasources/auth/auth_remote_datasource.dart' as _i60;
import '../../data/datasources/balai_rw/balai_rw_remote_datasource.dart'
    as _i348;
import '../../data/datasources/cek_reklame/cek_reklame_remote_datasource.dart'
    as _i766;
import '../../data/datasources/cek_reklame/history_remote_datasource.dart'
    as _i451;
import '../../data/datasources/cek_reklame/survey_remote_datasource.dart'
    as _i215;
import '../../data/repositories/absensi/absensi_repository_impl.dart' as _i242;
import '../../data/repositories/auth/auth_repository_impl.dart' as _i24;
import '../../data/repositories/balai_rw/balai_rw_repository_impl.dart'
    as _i518;
import '../../data/repositories/cek_reklame/cek_reklame_repository_impl.dart'
    as _i470;
import '../../data/repositories/cek_reklame/history_repository_impl.dart'
    as _i535;
import '../../data/repositories/cek_reklame/survey_permohonan_repository_impl.dart'
    as _i874;
import '../../data/repositories/geocoding/geocoding_repository_impl.dart'
    as _i793;
import '../../domain/repositories/absensi/absensi_repository.dart' as _i173;
import '../../domain/repositories/auth/auth_repository.dart' as _i660;
import '../../domain/repositories/balai_rw/i_balai_rw_repository.dart' as _i899;
import '../../domain/repositories/cek_reklame/i_cek_reklame_repository.dart'
    as _i127;
import '../../domain/repositories/geocoding/geocoding_repository.dart' as _i904;
import '../../domain/repositories/history/history_repository.dart' as _i169;
import '../../domain/repositories/survey_permohonan/i_survey_permohonan_repository.dart'
    as _i114;
import '../../domain/usecases/absensi/absensi_usecase.dart' as _i248;
import '../../domain/usecases/auth/auth_usecase.dart' as _i826;
import '../../domain/usecases/balai_rw/balai_rw_usecase.dart' as _i266;
import '../../domain/usecases/history/history_usecase.dart' as _i1023;
import '../../domain/usecases/survey_permohonan/survey_permohonan_usecase.dart'
    as _i11;
import '../../presentation/features/absensi/cubit/absen/absen_cubit.dart'
    as _i1039;
import '../../presentation/features/absensi/cubit/absensi/absensi_cubit.dart'
    as _i662;
import '../../presentation/features/auth/cubit/auth_cubit.dart' as _i224;
import '../../presentation/features/balai_rw/cubit/balai_rw_form_cubit.dart'
    as _i720;
import '../../presentation/features/balai_rw/cubit/balai_rw_hub_cubit.dart'
    as _i149;
import '../../presentation/features/camera/cubit/camera_cubit.dart' as _i755;
import '../../presentation/features/cek_reklame/cubit/history_cek_reklame/history_cubit.dart'
    as _i475;
import '../../presentation/features/home/cubit/home_cubit.dart' as _i900;
import '../../presentation/features/laporan_kehadiran/cubit/laporan_cubit.dart'
    as _i233;
import '../../presentation/features/splashscreen/cubit/splash_cubit.dart'
    as _i679;
import '../network/dio_auth_interceptor.dart' as _i817;
import '../network/hmac_kantor_interceptor.dart' as _i370;
import '../network/network_cubit.dart' as _i11;
import '../services/app_integrity_service.dart' as _i30;
import '../services/device_identity_service.dart' as _i218;
import '../services/geo_location_service.dart' as _i869;
import '../services/map_service.dart' as _i569;
import '../services/network_service.dart' as _i463;
import '../services/permission/i_permission_service.dart' as _i164;
import '../services/permission/permission_service_impl.dart' as _i1018;
import '../services/update_service.dart' as _i919;
import '../services/update_version_service.dart' as _i438;
import '../storage/app_preference.dart' as _i594;
import '../storage/app_secure_storage.dart' as _i233;
import '../theme/theme_mode_cubit.dart' as _i947;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.factory<_i679.SplashCubit>(() => _i679.SplashCubit());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
        () => registerModule.secureStorage);
    gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i569.MapService>(() => _i569.MapService());
    gh.lazySingleton<_i463.NetworkService>(() => _i463.NetworkService());
    gh.lazySingleton<_i438.UpdateVersionService>(
        () => _i438.UpdateVersionService());
    gh.lazySingleton<_i164.IPermissionService>(
        () => _i1018.PermissionServiceImpl());
    gh.lazySingleton<_i594.AppPreferences>(
        () => _i594.AppPreferences(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i869.GeoLocationService>(
        () => _i869.GeoLocationServiceImpl());
    gh.lazySingleton<_i30.AppIntegrityService>(
        () => _i30.AppIntegrityServiceImpl());
    gh.lazySingleton<_i233.AppSecureStorage>(
        () => _i233.AppSecureStorage(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i218.DeviceIdentityService>(
        () => _i218.DeviceIdentityServiceImpl(gh<_i233.AppSecureStorage>()));
    gh.lazySingleton<_i904.GeocodingRepository>(
        () => _i793.GeocodingRepositoryImpl());
    gh.lazySingleton<_i11.NetworkCubit>(
        () => _i11.NetworkCubit(gh<_i895.Connectivity>()));
    gh.lazySingleton<_i370.HmacKantorInterceptor>(
        () => _i370.HmacKantorInterceptor(gh<_i30.AppIntegrityService>()));
    gh.lazySingleton<_i947.ThemeModeCubit>(() => _i947.ThemeModeCubit(
          gh<_i594.AppPreferences>(),
          gh<_i233.AppSecureStorage>(),
        ));
    gh.lazySingleton<_i817.DioAuthInterceptor>(
        () => _i817.DioAuthInterceptor(gh<_i233.AppSecureStorage>()));
    gh.lazySingleton<_i361.Dio>(() => registerModule.getDio(
          gh<_i817.DioAuthInterceptor>(),
          gh<_i370.HmacKantorInterceptor>(),
        ));
    gh.lazySingleton<_i753.AbsensiRemoteDataSource>(
        () => _i753.AbsensiRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i451.HistoryRemoteDataSource>(
        () => _i451.HistoryRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i60.AuthRemoteDataSource>(
        () => _i60.AuthRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i766.ICekReklameRemoteDataSource>(
        () => _i766.CekReklameRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i348.IBalaiRwRemoteDataSource>(
        () => _i348.BalaiRwRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i919.UpdateService>(() => _i919.UpdateService(
          gh<_i361.Dio>(),
          gh<_i438.UpdateVersionService>(),
        ));
    gh.lazySingleton<_i173.AbsensiRepository>(() => _i242.AbsensiRepositoryImpl(
          gh<_i753.AbsensiRemoteDataSource>(),
          gh<_i218.DeviceIdentityService>(),
          gh<_i233.AppSecureStorage>(),
        ));
    gh.lazySingleton<_i899.IBalaiRwRepository>(() =>
        _i518.BalaiRwRepositoryImpl(gh<_i348.IBalaiRwRemoteDataSource>()));
    gh.lazySingleton<_i127.CekReklameRepository>(() =>
        _i470.CekReklameRepositoryImpl(
            gh<_i766.ICekReklameRemoteDataSource>()));
    gh.lazySingleton<_i169.HistoryRepository>(
        () => _i535.HistoryRepositoryImpl(gh<_i451.HistoryRemoteDataSource>()));
    gh.lazySingleton<_i660.AuthRepository>(() => _i24.AuthRepositoryImpl(
          gh<_i60.AuthRemoteDataSource>(),
          gh<_i233.AppSecureStorage>(),
        ));
    gh.lazySingleton<_i215.ISurveyPermohonanRemoteDataSource>(
        () => _i215.SurveyPermohonanRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.factory<_i755.CameraCubit>(() => _i755.CameraCubit(
          gh<_i164.IPermissionService>(),
          gh<_i904.GeocodingRepository>(),
          gh<_i127.CekReklameRepository>(),
        ));
    gh.lazySingleton<_i826.AuthUseCase>(
        () => _i826.AuthUseCase(gh<_i660.AuthRepository>()));
    gh.lazySingleton<_i248.AbsensiUseCase>(
        () => _i248.AbsensiUseCase(gh<_i173.AbsensiRepository>()));
    gh.lazySingleton<_i266.BalaiRwUseCase>(
        () => _i266.BalaiRwUseCase(gh<_i899.IBalaiRwRepository>()));
    gh.lazySingleton<_i114.ISurveyPermohonanRepository>(() =>
        _i874.SurveyPermohonanRepositoryImpl(
            gh<_i215.ISurveyPermohonanRemoteDataSource>()));
    gh.lazySingleton<_i1023.HistoryUseCase>(
        () => _i1023.HistoryUseCase(gh<_i169.HistoryRepository>()));
    gh.factory<_i900.HomeCubit>(() => _i900.HomeCubit(
          updateService: gh<_i919.UpdateService>(),
          permissionService: gh<_i164.IPermissionService>(),
          authUseCase: gh<_i826.AuthUseCase>(),
        ));
    gh.factory<_i662.AbsensiCubit>(
        () => _i662.AbsensiCubit(gh<_i248.AbsensiUseCase>()));
    gh.factory<_i233.LaporanCubit>(
        () => _i233.LaporanCubit(gh<_i248.AbsensiUseCase>()));
    gh.lazySingleton<_i11.SurveyPermohonanUseCase>(() =>
        _i11.SurveyPermohonanUseCase(gh<_i114.ISurveyPermohonanRepository>()));
    gh.lazySingleton<_i224.AuthCubit>(
        () => _i224.AuthCubit(authUseCase: gh<_i826.AuthUseCase>()));
    gh.factory<_i720.BalaiRwFormCubit>(
        () => _i720.BalaiRwFormCubit(gh<_i266.BalaiRwUseCase>()));
    gh.factory<_i149.BalaiRwHubCubit>(
        () => _i149.BalaiRwHubCubit(gh<_i266.BalaiRwUseCase>()));
    gh.factory<_i1039.AbsenCubit>(() => _i1039.AbsenCubit(
          gh<_i248.AbsensiUseCase>(),
          gh<_i869.GeoLocationService>(),
        ));
    gh.factory<_i475.HistoryCubit>(
        () => _i475.HistoryCubit(gh<_i1023.HistoryUseCase>()));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
