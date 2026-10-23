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
import '../../data/datasources/cek_reklame/survey_history_remote_datasource.dart'
    as _i870;
import '../../data/datasources/cek_reklame/survey_remote_datasource.dart'
    as _i215;
import '../../data/datasources/my_task/my_task_remote_datasource.dart' as _i615;
import '../../data/datasources/notifikasi/notifikasi_remote_datasource.dart'
    as _i710;
import '../../data/datasources/pengiriman/pengiriman_remote_datasource.dart'
    as _i294;
import '../../data/datasources/pengiriman/rute_remote_datasource.dart' as _i569;
import '../../data/datasources/profile/profile_remote_datasource.dart' as _i49;
import '../../data/datasources/va_qris/va_qris_local_datasource.dart' as _i537;
import '../../data/datasources/va_qris/va_qris_remote_datasource.dart' as _i705;
import '../../data/repositories/absensi/absensi_repository_impl.dart' as _i242;
import '../../data/repositories/auth/auth_repository_impl.dart' as _i24;
import '../../data/repositories/balai_rw/balai_rw_repository_impl.dart'
    as _i518;
import '../../data/repositories/cek_reklame/cek_reklame_repository_impl.dart'
    as _i470;
import '../../data/repositories/cek_reklame/history_repository_impl.dart'
    as _i535;
import '../../data/repositories/cek_reklame/survey_history_repository_impl.dart'
    as _i319;
import '../../data/repositories/cek_reklame/survey_permohonan_repository_impl.dart'
    as _i874;
import '../../data/repositories/geocoding/geocoding_repository_impl.dart'
    as _i793;
import '../../data/repositories/my_task/my_task_repository_impl.dart' as _i539;
import '../../data/repositories/notifikasi/notifikasi_repository_impl.dart'
    as _i535;
import '../../data/repositories/pengiriman/pengiriman_repository_impl.dart'
    as _i673;
import '../../data/repositories/profile/profile_repository_impl.dart' as _i770;
import '../../data/repositories/va_qris/va_qris_repository_impl.dart' as _i562;
import '../../domain/repositories/absensi/absensi_repository.dart' as _i173;
import '../../domain/repositories/auth/auth_repository.dart' as _i660;
import '../../domain/repositories/balai_rw/i_balai_rw_repository.dart' as _i899;
import '../../domain/repositories/cek_reklame/i_cek_reklame_repository.dart'
    as _i127;
import '../../domain/repositories/geocoding/geocoding_repository.dart' as _i904;
import '../../domain/repositories/history/history_repository.dart' as _i169;
import '../../domain/repositories/my_task/i_my_task_repository.dart' as _i728;
import '../../domain/repositories/notifikasi/i_notifikasi_repository.dart'
    as _i563;
import '../../domain/repositories/pengiriman/i_pengiriman_repository.dart'
    as _i969;
import '../../domain/repositories/profile/i_profile_repository.dart' as _i640;
import '../../domain/repositories/survey_permohonan/i_survey_history_remote_repository.dart'
    as _i101;
import '../../domain/repositories/survey_permohonan/i_survey_permohonan_repository.dart'
    as _i114;
import '../../domain/repositories/va_qris/i_va_qris_repository.dart' as _i956;
import '../../domain/usecases/absensi/absensi_usecase.dart' as _i248;
import '../../domain/usecases/auth/auth_usecase.dart' as _i826;
import '../../domain/usecases/balai_rw/balai_rw_usecase.dart' as _i266;
import '../../domain/usecases/history/history_usecase.dart' as _i1023;
import '../../domain/usecases/my_task/my_task_usecase.dart' as _i781;
import '../../domain/usecases/notifikasi/notifikasi_usecase.dart' as _i813;
import '../../domain/usecases/pengiriman/pengiriman_usecase.dart' as _i578;
import '../../domain/usecases/profile/profile_usecase.dart' as _i839;
import '../../domain/usecases/survey_permohonan/survey_history_usecase.dart'
    as _i446;
import '../../domain/usecases/survey_permohonan/survey_permohonan_usecase.dart'
    as _i11;
import '../../domain/usecases/va_qris/va_qris_usecase.dart' as _i930;
import '../../presentation/features/absensi/cubit/absen/absen_cubit.dart'
    as _i1039;
import '../../presentation/features/absensi/cubit/absensi/absensi_cubit.dart'
    as _i662;
import '../../presentation/features/auth/cubit/auth_cubit.dart' as _i224;
import '../../presentation/features/auth/cubit/lupa_password_cubit.dart'
    as _i405;
import '../../presentation/features/auth/cubit/reset_password_cubit.dart'
    as _i216;
import '../../presentation/features/balai_rw/cubit/balai_rw_form_cubit.dart'
    as _i720;
import '../../presentation/features/balai_rw/cubit/balai_rw_hub_cubit.dart'
    as _i149;
import '../../presentation/features/camera/cubit/camera_cubit.dart' as _i755;
import '../../presentation/features/cek_reklame/cubit/history_cek_reklame/history_cubit.dart'
    as _i475;
import '../../presentation/features/cek_reklame/cubit/survey_permohonan_baru/survey_summary_cubit.dart'
    as _i686;
import '../../presentation/features/home/cubit/home_cubit.dart' as _i900;
import '../../presentation/features/laporan_kehadiran/cubit/laporan_cubit.dart'
    as _i233;
import '../../presentation/features/notifikasi/cubit/notifikasi_badge_cubit.dart'
    as _i176;
import '../../presentation/features/notifikasi/cubit/notifikasi_cubit.dart'
    as _i333;
import '../../presentation/features/pengiriman/cubit/aksi/aksi_cubit.dart'
    as _i572;
import '../../presentation/features/pengiriman/cubit/antrean/antrean_pengiriman_cubit.dart'
    as _i627;
import '../../presentation/features/pengiriman/cubit/daftar_tugas/daftar_tugas_cubit.dart'
    as _i379;
import '../../presentation/features/pengiriman/cubit/detail_berkas/detail_berkas_cubit.dart'
    as _i374;
import '../../presentation/features/pengiriman/cubit/lacak/lacak_cubit.dart'
    as _i554;
import '../../presentation/features/pengiriman/cubit/pantau/pantau_cubit.dart'
    as _i493;
import '../../presentation/features/pengiriman/utils/pengiriman_foto.dart'
    as _i798;
import '../../presentation/features/profile/cubit/profile_cubit.dart' as _i239;
import '../../presentation/features/profile/cubit/ubah_kontak_cubit.dart'
    as _i406;
import '../../presentation/features/splashscreen/cubit/splash_cubit.dart'
    as _i679;
import '../../presentation/features/survey_baru/cubit/survey_info/survey_info_cubit.dart'
    as _i188;
import '../../presentation/features/survey_baru/cubit/survey_lokasi/survey_lokasi_cubit.dart'
    as _i5;
import '../../presentation/features/survey_baru/cubit/survey_map/survey_map_cubit.dart'
    as _i197;
import '../../presentation/features/va_qris/cubit/tax_object_search_cubit.dart'
    as _i410;
import '../../presentation/features/va_qris/cubit/va_qris_cubit.dart' as _i197;
import '../../presentation/shared/master_data/data/datasources/master_local_datasource.dart'
    as _i30;
import '../../presentation/shared/master_data/data/datasources/master_remote_datasource.dart'
    as _i615;
import '../../presentation/shared/master_data/data/repositories/master_repository_impl.dart'
    as _i21;
import '../../presentation/shared/master_data/domain/repositories/i_master_repository.dart'
    as _i1023;
import '../../presentation/shared/master_data/domain/usecases/master_data_usecase.dart'
    as _i60;
import '../../presentation/shared/master_data/presentation/cubit/master_data_cubit.dart'
    as _i801;
import '../network/dio_auth_interceptor.dart' as _i817;
import '../network/hmac_kantor_interceptor.dart' as _i370;
import '../network/network_cubit.dart' as _i11;
import '../services/app_integrity_service.dart' as _i30;
import '../services/device_identity_service.dart' as _i218;
import '../services/geo_location/geo_location_service_impl.dart' as _i247;
import '../services/geo_location/i_geo_location_service.dart' as _i778;
import '../services/map_service.dart' as _i569;
import '../services/network_service.dart' as _i463;
import '../services/notifikasi/notifikasi_service.dart' as _i870;
import '../services/notifikasi/notifikasi_sinyal.dart' as _i147;
import '../services/permission/i_permission_service.dart' as _i164;
import '../services/permission/permission_service_impl.dart' as _i1018;
import '../services/update_service.dart' as _i919;
import '../services/update_version_service.dart' as _i438;
import '../storage/app_preference.dart' as _i594;
import '../storage/app_secure_storage.dart' as _i233;
import '../storage/pengiriman_cache_storage.dart' as _i148;
import '../storage/pengiriman_queue_storage.dart' as _i877;
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
    gh.lazySingleton<_i147.NotifikasiSinyal>(() => _i147.NotifikasiSinyal());
    gh.lazySingleton<_i438.UpdateVersionService>(
        () => _i438.UpdateVersionService());
    gh.lazySingleton<_i798.PengirimanFoto>(() => _i798.PengirimanFoto());
    gh.lazySingleton<_i594.AppPreferences>(
        () => _i594.AppPreferences(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i148.PengirimanCacheStorage>(
        () => _i148.PengirimanCacheStorage(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i877.PengirimanQueueStorage>(
        () => _i877.PengirimanQueueStorage(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i569.IRuteRemoteDataSource>(
        () => _i569.RuteRemoteDataSourceImpl());
    gh.lazySingleton<_i904.IGeocodingRepository>(
        () => _i793.GeocodingRepositoryImpl());
    gh.lazySingleton<_i164.IPermissionService>(
        () => _i1018.PermissionServiceImpl());
    gh.lazySingleton<_i233.AppSecureStorage>(
        () => _i233.AppSecureStorage(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i30.AppIntegrityService>(
        () => _i30.AppIntegrityServiceImpl());
    gh.lazySingleton<_i218.DeviceIdentityService>(
        () => _i218.DeviceIdentityServiceImpl(gh<_i233.AppSecureStorage>()));
    gh.lazySingleton<_i30.IMasterLocalDataSource>(
        () => _i30.MasterLocalDataSourceImpl(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i947.ThemeModeCubit>(() => _i947.ThemeModeCubit(
          gh<_i594.AppPreferences>(),
          gh<_i233.AppSecureStorage>(),
        ));
    gh.lazySingleton<_i11.NetworkCubit>(
        () => _i11.NetworkCubit(gh<_i895.Connectivity>()));
    gh.lazySingleton<_i778.IGeoLocationService>(
        () => _i247.GeoLocationServiceImpl(gh<_i164.IPermissionService>()));
    gh.lazySingleton<_i817.DioAuthInterceptor>(
        () => _i817.DioAuthInterceptor(gh<_i233.AppSecureStorage>()));
    gh.lazySingleton<_i370.HmacKantorInterceptor>(
        () => _i370.HmacKantorInterceptor(gh<_i30.AppIntegrityService>()));
    gh.lazySingleton<_i537.IVaQrisLocalDataSource>(
        () => _i537.VaQrisLocalDataSourceImpl(
              gh<_i460.SharedPreferences>(),
              gh<_i233.AppSecureStorage>(),
            ));
    gh.factory<_i197.SurveyMapCubit>(
        () => _i197.SurveyMapCubit(gh<_i778.IGeoLocationService>()));
    gh.lazySingleton<_i361.Dio>(() => registerModule.getDio(
          gh<_i817.DioAuthInterceptor>(),
          gh<_i370.HmacKantorInterceptor>(),
        ));
    gh.factory<_i5.SurveyLokasiCubit>(() => _i5.SurveyLokasiCubit(
          gh<_i778.IGeoLocationService>(),
          gh<_i164.IPermissionService>(),
          gh<_i904.IGeocodingRepository>(),
        ));
    gh.lazySingleton<_i705.IVaQrisRemoteDataSource>(
        () => _i705.VaQrisRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i615.IMyTaskRemoteDataSource>(
        () => _i615.MyTaskRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i710.INotifikasiRemoteDataSource>(
        () => _i710.NotifikasiRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i753.AbsensiRemoteDataSource>(
        () => _i753.AbsensiRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i49.IProfileRemoteDataSource>(
        () => _i49.ProfileRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i451.HistoryRemoteDataSource>(
        () => _i451.HistoryRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i215.ISurveyPermohonanRemoteDataSource>(
        () => _i215.SurveyPermohonanRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i615.IMasterRemoteDataSource>(
        () => _i615.MasterRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i728.IMyTaskRepository>(
        () => _i539.MyTaskRepositoryImpl(gh<_i615.IMyTaskRemoteDataSource>()));
    gh.lazySingleton<_i173.AbsensiRepository>(() => _i242.AbsensiRepositoryImpl(
          gh<_i753.AbsensiRemoteDataSource>(),
          gh<_i218.DeviceIdentityService>(),
          gh<_i233.AppSecureStorage>(),
        ));
    gh.lazySingleton<_i294.IPengirimanRemoteDataSource>(
        () => _i294.PengirimanRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i766.ICekReklameRemoteDataSource>(
        () => _i766.CekReklameRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i919.UpdateService>(() => _i919.UpdateService(
          gh<_i361.Dio>(),
          gh<_i438.UpdateVersionService>(),
        ));
    gh.lazySingleton<_i870.ISurveyHistoryRemoteDataSource>(
        () => _i870.SurveyHistoryRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i563.INotifikasiRepository>(
        () => _i535.NotifikasiRepositoryImpl(
              gh<_i710.INotifikasiRemoteDataSource>(),
              gh<_i147.NotifikasiSinyal>(),
            ));
    gh.lazySingleton<_i101.ISurveyHistoryRepository>(() =>
        _i319.SurveyHistoryRepositoryImpl(
            gh<_i870.ISurveyHistoryRemoteDataSource>()));
    gh.lazySingleton<_i127.CekReklameRepository>(() =>
        _i470.CekReklameRepositoryImpl(
            gh<_i766.ICekReklameRemoteDataSource>()));
    gh.lazySingleton<_i956.IVaQrisRepository>(() => _i562.VaQrisRepositoryImpl(
          gh<_i705.IVaQrisRemoteDataSource>(),
          gh<_i537.IVaQrisLocalDataSource>(),
        ));
    gh.lazySingleton<_i1023.IMasterRepository>(() => _i21.MasterRepositoryImpl(
          gh<_i615.IMasterRemoteDataSource>(),
          gh<_i30.IMasterLocalDataSource>(),
        ));
    gh.lazySingleton<_i348.IBalaiRwRemoteDataSource>(
        () => _i348.BalaiRwRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i60.AuthRemoteDataSource>(
        () => _i60.AuthRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.factory<_i755.CameraCubit>(() => _i755.CameraCubit(
          gh<_i164.IPermissionService>(),
          gh<_i904.IGeocodingRepository>(),
          gh<_i127.CekReklameRepository>(),
        ));
    gh.lazySingleton<_i114.ISurveyPermohonanRepository>(() =>
        _i874.SurveyPermohonanRepositoryImpl(
            gh<_i215.ISurveyPermohonanRemoteDataSource>()));
    gh.lazySingleton<_i813.NotifikasiUseCase>(
        () => _i813.NotifikasiUseCase(gh<_i563.INotifikasiRepository>()));
    gh.lazySingleton<_i969.IPengirimanRepository>(
        () => _i673.PengirimanRepositoryImpl(
              gh<_i294.IPengirimanRemoteDataSource>(),
              gh<_i877.PengirimanQueueStorage>(),
              gh<_i148.PengirimanCacheStorage>(),
              gh<_i233.AppSecureStorage>(),
              gh<_i569.IRuteRemoteDataSource>(),
            ));
    gh.lazySingleton<_i169.HistoryRepository>(
        () => _i535.HistoryRepositoryImpl(gh<_i451.HistoryRemoteDataSource>()));
    gh.lazySingleton<_i60.MasterDataUseCase>(
        () => _i60.MasterDataUseCase(gh<_i1023.IMasterRepository>()));
    gh.lazySingleton<_i446.SurveyHistoryUseCase>(
        () => _i446.SurveyHistoryUseCase(gh<_i101.ISurveyHistoryRepository>()));
    gh.lazySingleton<_i248.AbsensiUseCase>(
        () => _i248.AbsensiUseCase(gh<_i173.AbsensiRepository>()));
    gh.lazySingleton<_i870.NotifikasiService>(() => _i870.NotifikasiService(
          gh<_i147.NotifikasiSinyal>(),
          gh<_i813.NotifikasiUseCase>(),
        ));
    gh.lazySingleton<_i11.SurveyPermohonanUseCase>(() =>
        _i11.SurveyPermohonanUseCase(gh<_i114.ISurveyPermohonanRepository>()));
    gh.lazySingleton<_i660.IAuthRepository>(() => _i24.AuthRepositoryImpl(
          gh<_i60.AuthRemoteDataSource>(),
          gh<_i233.AppSecureStorage>(),
        ));
    gh.lazySingleton<_i781.MyTaskUseCase>(
        () => _i781.MyTaskUseCase(gh<_i728.IMyTaskRepository>()));
    gh.lazySingleton<_i640.IProfileRepository>(
        () => _i770.ProfileRepositoryImpl(gh<_i49.IProfileRemoteDataSource>()));
    gh.lazySingleton<_i578.PengirimanUseCase>(
        () => _i578.PengirimanUseCase(gh<_i969.IPengirimanRepository>()));
    gh.lazySingleton<_i1023.HistoryUseCase>(
        () => _i1023.HistoryUseCase(gh<_i169.HistoryRepository>()));
    gh.factory<_i333.NotifikasiCubit>(
        () => _i333.NotifikasiCubit(gh<_i813.NotifikasiUseCase>()));
    gh.factory<_i572.AksiCubit>(() => _i572.AksiCubit(
          gh<_i578.PengirimanUseCase>(),
          gh<_i778.IGeoLocationService>(),
          gh<_i164.IPermissionService>(),
          gh<_i798.PengirimanFoto>(),
        ));
    gh.lazySingleton<_i930.VaQrisUseCase>(
        () => _i930.VaQrisUseCase(gh<_i956.IVaQrisRepository>()));
    gh.factory<_i1039.AbsenCubit>(() => _i1039.AbsenCubit(
          gh<_i248.AbsensiUseCase>(),
          gh<_i778.IGeoLocationService>(),
          gh<_i164.IPermissionService>(),
        ));
    gh.lazySingleton<_i826.AuthUseCase>(
        () => _i826.AuthUseCase(gh<_i660.IAuthRepository>()));
    gh.lazySingleton<_i899.IBalaiRwRepository>(() =>
        _i518.BalaiRwRepositoryImpl(gh<_i348.IBalaiRwRemoteDataSource>()));
    gh.factory<_i686.SurveySummaryCubit>(
        () => _i686.SurveySummaryCubit(gh<_i11.SurveyPermohonanUseCase>()));
    gh.factory<_i410.TaxObjectSearchCubit>(
        () => _i410.TaxObjectSearchCubit(gh<_i930.VaQrisUseCase>()));
    gh.factory<_i197.VaQrisCubit>(
        () => _i197.VaQrisCubit(gh<_i930.VaQrisUseCase>()));
    gh.lazySingleton<_i801.MasterDataCubit>(
        () => _i801.MasterDataCubit(gh<_i60.MasterDataUseCase>()));
    gh.lazySingleton<_i839.ProfileUseCase>(
        () => _i839.ProfileUseCase(gh<_i640.IProfileRepository>()));
    gh.factory<_i475.HistoryCubit>(
        () => _i475.HistoryCubit(gh<_i1023.HistoryUseCase>()));
    gh.lazySingleton<_i224.AuthCubit>(
        () => _i224.AuthCubit(authUseCase: gh<_i826.AuthUseCase>()));
    gh.factory<_i176.NotifikasiBadgeCubit>(
        () => _i176.NotifikasiBadgeCubit(gh<_i813.NotifikasiUseCase>()));
    gh.factory<_i406.UbahKontakCubit>(
        () => _i406.UbahKontakCubit(gh<_i839.ProfileUseCase>()));
    gh.factory<_i900.HomeCubit>(() => _i900.HomeCubit(
          updateService: gh<_i919.UpdateService>(),
          permissionService: gh<_i164.IPermissionService>(),
          authUseCase: gh<_i826.AuthUseCase>(),
        ));
    gh.factory<_i662.AbsensiCubit>(
        () => _i662.AbsensiCubit(gh<_i248.AbsensiUseCase>()));
    gh.factory<_i233.LaporanCubit>(
        () => _i233.LaporanCubit(gh<_i248.AbsensiUseCase>()));
    gh.factory<_i379.DaftarTugasCubit>(
        () => _i379.DaftarTugasCubit(gh<_i578.PengirimanUseCase>()));
    gh.factory<_i374.DetailBerkasCubit>(
        () => _i374.DetailBerkasCubit(gh<_i578.PengirimanUseCase>()));
    gh.factory<_i554.LacakCubit>(
        () => _i554.LacakCubit(gh<_i578.PengirimanUseCase>()));
    gh.factory<_i493.PantauCubit>(
        () => _i493.PantauCubit(gh<_i578.PengirimanUseCase>()));
    gh.lazySingleton<_i266.BalaiRwUseCase>(
        () => _i266.BalaiRwUseCase(gh<_i899.IBalaiRwRepository>()));
    gh.factory<_i405.LupaPasswordCubit>(
        () => _i405.LupaPasswordCubit(gh<_i826.AuthUseCase>()));
    gh.factory<_i216.ResetPasswordCubit>(
        () => _i216.ResetPasswordCubit(gh<_i826.AuthUseCase>()));
    gh.factoryParam<_i188.SurveyInfoCubit, String, dynamic>((
      nomorPelayanan,
      _,
    ) =>
        _i188.SurveyInfoCubit(
          nomorPelayanan: nomorPelayanan,
          geolocationService: gh<_i778.IGeoLocationService>(),
          masterDataUseCase: gh<_i60.MasterDataUseCase>(),
          authUseCase: gh<_i826.AuthUseCase>(),
        ));
    gh.lazySingleton<_i627.AntreanPengirimanCubit>(
        () => _i627.AntreanPengirimanCubit(
              gh<_i578.PengirimanUseCase>(),
              gh<_i224.AuthCubit>(),
              gh<_i11.NetworkCubit>(),
            ));
    gh.factory<_i239.ProfileCubit>(() => _i239.ProfileCubit(
          gh<_i826.AuthUseCase>(),
          gh<_i839.ProfileUseCase>(),
        ));
    gh.factory<_i720.BalaiRwFormCubit>(
        () => _i720.BalaiRwFormCubit(gh<_i266.BalaiRwUseCase>()));
    gh.factory<_i149.BalaiRwHubCubit>(
        () => _i149.BalaiRwHubCubit(gh<_i266.BalaiRwUseCase>()));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
