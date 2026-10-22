import 'dart:async';
import 'package:mybapenda/core/services/map_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mybapenda/core/services/network_service.dart';
import 'nearby_state.dart';

class NearbyCubit extends Cubit<NearbyState> {
  final MapService mapService;
  final NetworkService networkService;
  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;
  StreamSubscription<bool>? _networkSubscription;
  NearbyCubit({required this.mapService, required this.networkService})
    : super(const NearbyState());

  // Method Init yang dipanggil saat Widget tampil
  Future<void> initLocation() async {
    // Hindari reset loading jika data sudah ada (biar gak flicker)
    if (state.status == NearbyStatus.active) return;

    // Gunakan copyWith agar map lama tidak hilang mendadak (opsional, tapi lebih smooth)
    emit(state.copyWith(status: NearbyStatus.loading));

    // LEVEL 1: Cek Permission
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      emit(state.copyWith(status: NearbyStatus.permissionDenied));
      return;
    }

    // LEVEL 2: Cek Service GPS
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(state.copyWith(status: NearbyStatus.serviceDisabled));
      return;
    }

    // LEVEL 3: Cek Internet 👈 (INI YANG KURANG TADI)
    final isConnected = await networkService.isConnected();
    if (!isConnected) {
      emit(state.copyWith(status: NearbyStatus.noInternet));
      // Kita tetap lanjut _startTracking di bawah,
      // Supaya listener internet aktif. Jika nanti internet nyala, otomatis reload.
    }

    // 3. Mulai Tracking
    _startTracking();
  }

  void _startTracking() async {
    // A. Listener Status GPS (On/Off)
    await _serviceStatusSubscription?.cancel();
    _serviceStatusSubscription = Geolocator.getServiceStatusStream().listen((
      status,
    ) {
      if (status == ServiceStatus.disabled) {
        emit(state.copyWith(status: NearbyStatus.serviceDisabled));
      } else if (status == ServiceStatus.enabled) {
        initLocation();
      }
    });

    // B. Listener Status Internet (On/Off) 👈 LOGIC BARU
    await _networkSubscription?.cancel();
    _networkSubscription = networkService.onConnectivityChanged.listen((
      isConnected,
    ) {
      if (!isConnected) {
        // Internet Mati -> Emit NoInternet
        emit(state.copyWith(status: NearbyStatus.noInternet));
      } else {
        // Internet Nyala Kembali -> Cek apakah kita perlu reload?
        // Jika status sekarang noInternet atau error, coba init ulang
        if (state.status == NearbyStatus.noInternet ||
            state.status == NearbyStatus.error) {
          initLocation();
        }
      }
    });

    try {
      // C. Logic Ambil Lokasi (Sama seperti sebelumnya)
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && state.status != NearbyStatus.noInternet) {
        _updateState(lastKnown);
      }

      final current = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // Hanya update state aktif jika internet ada
      if (await networkService.isConnected()) {
        _updateState(current);
      }

      await _locationSubscription?.cancel();
      _locationSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              distanceFilter: 50,
            ),
          ).listen((position) async {
            // Cek internet lagi sebelum update map (double check)
            if (await networkService.isConnected()) {
              _updateState(position);
            }
          }, onError: (_) => emit(state.copyWith(status: NearbyStatus.error)));
    } catch (e) {
      // Jangan timpa status jika itu sebenarnya masalah internet/gps
      if (state.status != NearbyStatus.noInternet &&
          state.status != NearbyStatus.serviceDisabled) {
        emit(state.copyWith(status: NearbyStatus.error));
      }
    }
  }

  void _updateState(Position position) {
    if (isClosed) return;
    final mapUrl = mapService.generateStaticMapUrl(
      lat: position.latitude,
      long: position.longitude,
    );

    emit(
      NearbyState(
        status: NearbyStatus.active,
        currentPosition: position,
        mapImageUrl: mapUrl,
      ),
    );
  }

  // Dipanggil kalau user pencet tombol "Aktifkan GPS" lalu balik ke app
  void retry() {
    initLocation();
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _serviceStatusSubscription?.cancel();
    _networkSubscription?.cancel();
    return super.close();
  }
}
