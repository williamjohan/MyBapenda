// lib/presentation/features/camera/cubit/camera_cubit.dart
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/enums/app_permission_enum.dart';
import '../../../../core/services/permission/i_permission_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/app_image_compress_utils.dart';
import '../../../../data/models/cek_reklame/cek_reklame_model.dart';
import '../../../../domain/entities/coordinate_entity.dart';
import '../../../../domain/repositories/cek_reklame/i_cek_reklame_repository.dart';
import '../../../../domain/repositories/geocoding/geocoding_repository.dart';
import 'camera_state.dart';

@injectable
class CameraCubit extends Cubit<CameraState> {
  final IPermissionService permissionService;
  final GeocodingRepository geocodingRepository;
  final CekReklameRepository cekReklameRepository;

  CameraController? _controller;
  FlashMode _currentFlashMode = FlashMode.off;
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  bool _isInitializing = false;

  CameraCubit(
    this.permissionService,
    this.geocodingRepository,
    this.cekReklameRepository,
  ) : super(const CameraState());

  // Ekspos controller & pengaturan agar UI (CameraPreview) bisa mengaksesnya
  CameraController? get controller => _controller;
  FlashMode get currentFlashMode => _currentFlashMode;
  double get currentZoom => _currentZoom;

  // ===============================================================
  // 1. ENTRY POINT & INITIALIZATION
  // ===============================================================
  Future<void> start() async {
    if (_isInitializing || isClosed) return;
    _isInitializing = true;
    emit(state.copyWith(status: CameraStatus.loading));

    try {
      // 1. Cek Permission via Service
      final camStatus = await permissionService.requestPermission(AppPermissionType.camera);
      final locStatus = await permissionService.requestPermission(AppPermissionType.location);

      if (camStatus == AppPermissionStatus.permanentlyDenied || 
          locStatus == AppPermissionStatus.permanentlyDenied) {
        emit(state.copyWith(status: CameraStatus.permissionPermanentlyDenied));
        return;
      } else if (camStatus != AppPermissionStatus.granted || 
                 locStatus != AppPermissionStatus.granted) {
        emit(state.copyWith(status: CameraStatus.permissionDenied));
        return;
      }

      // 2. Cek GPS Hardware Menyala
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(state.copyWith(
          status: CameraStatus.error,
          errorMessage: "GPS perangkat Anda belum diaktifkan.",
        ));
        return;
      }

      await _initCamera();
    } catch (e, s) {
      AppLogger.error('Kamera gagal disiapkan', e, s);
      if (!isClosed) {
        emit(state.copyWith(
          status: CameraStatus.error, 
          errorMessage: 'Gagal mempersiapkan kamera.',
        ));
      }
    } finally {
      _isInitializing = false;
    }
  }

  // ===============================================================
  // 2. CAPTURE & PROCESS (BACKGROUND COMPRESSION + GEOCODING)
  // ===============================================================
  Future<void> capture() async {
    if (isClosed || _controller == null || !_controller!.value.isInitialized) return;
    if (state.status == CameraStatus.capturing) return;

    HapticFeedback.mediumImpact();
    emit(state.copyWith(status: CameraStatus.capturing));

    try {
      // 1. Ambil Gambar
      final xFile = await _controller!.takePicture();
      if (isClosed) return;
      
      final rawFile = File(xFile.path);

      // 2. Beralih langsung ke mode Reviewing (UI Kamera ditutup/bergeser)
      emit(state.copyWith(
        status: CameraStatus.reviewing,
        originalFile: rawFile,
        errorMessage: null,
      ));

      AppLogger.info('Memulai kompresi & pencarian GPS paralel...');

      // 3. Jalankan Kompresi & GPS secara Paralel agar menghemat waktu
      final compressTask = AppImageCompressUtils.compressAndConvert(rawFile);
      final gpsTask = Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // Akurasi tinggi untuk Bapenda
      ).timeout(const Duration(seconds: 12));

      final results = await Future.wait([compressTask, gpsTask]);
      final compressedFile = results[0] as File?;
      final position = results[1] as Position;

      if (isClosed) return;

      emit(state.copyWith(
        compressedFile: compressedFile ?? rawFile,
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
      ));

      // 4. Reverse Geocoding (Cari Alamat)
      final geoResult = await geocodingRepository.getAddressFromCoordinate(
        CoordinateEntity(latitude: position.latitude, longitude: position.longitude),
      );

      if (isClosed) return;

      geoResult.fold(
        (failure) => emit(state.copyWith(address: "Alamat tidak ditemukan")),
        (address) => emit(state.copyWith(address: address)),
      );

    } catch (e, s) {
      AppLogger.error('Gagal Capture/Geocoding', e, s);
      if (isClosed) return;
      emit(state.copyWith(
        status: CameraStatus.reviewing, // Tetap di layar review
        errorMessage: 'Gagal mendapatkan lokasi GPS akurat. Mohon ulangi pengambilan gambar.',
      ));
    }
  }

  // ===============================================================
  // 3. SUBMIT LAPORAN
  // ===============================================================
  Future<void> submitLaporan() async {
    if (isClosed || state.compressedFile == null || state.latitude == null) return;
    
    emit(state.copyWith(status: CameraStatus.submitting));

   final payload = CekReklameUploadRequest(
      file: state.compressedFile!,
      latitude: state.latitude!,
      longitude: state.longitude!,
      alamat: state.address ?? 'Tidak diketahui',
    );

  final result = await cekReklameRepository.uploadReklame(payload);

    if (isClosed) return;

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: CameraStatus.reviewing,
          errorMessage: failure.message,
        ));
      },
      (_) {
        emit(state.copyWith(status: CameraStatus.success));
      },
    );
  }
  
  // Metode untuk tombol "Foto Ulang" di layar Review
  Future<void> retakePhoto() async {
    // Reset state kembali ke kamera siap
    emit(const CameraState(status: CameraStatus.ready));
    
    // Resume preview jika sebelumnya di-pause oleh hardware
    try {
      await _controller?.resumePreview();
    } catch (_) {}
  }

  // ===============================================================
  // 4. HARDWARE CONTROLS (ZOOM, FOCUS, LIFECYCLE)
  // ===============================================================
  Future<void> _initCamera() async {
    final oldController = _controller;
    _controller = null;
    if (oldController != null) await oldController.dispose();

    final cameras = await availableCameras();
    if (cameras.isEmpty) throw Exception("Kamera tidak ditemukan");

    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final newController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.jpeg : ImageFormatGroup.bgra8888,
    );

    _controller = newController;
    await _controller!.initialize();

    try { await _controller!.setFlashMode(_currentFlashMode); } catch (_) {}
    try { await _controller!.setFocusMode(FocusMode.auto); } catch (_) {}
    try {
      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
    } catch (_) {
      _minZoom = 1.0; _maxZoom = 1.0;
    }

    if (!isClosed) emit(state.copyWith(status: CameraStatus.ready));
  }

  void onScaleStart() { _baseZoom = _currentZoom; }

  Future<void> onScaleUpdate(double scale) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final newZoom = (_baseZoom * scale).clamp(_minZoom, _maxZoom);
    try {
      await _controller!.setZoomLevel(newZoom);
      _currentZoom = newZoom;
    } catch (_) {}
  }

  Future<void> onTapToFocus({required Offset tapPosition, required Size previewSize}) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final x = tapPosition.dx / previewSize.width;
    final y = tapPosition.dy / previewSize.height;

    try {
      await _controller!.setFocusPoint(Offset(x, y));
      await _controller!.setExposurePoint(Offset(x, y));

      emit(state.copyWith(showFocus: true, focusX: tapPosition.dx, focusY: tapPosition.dy));
      await Future.delayed(const Duration(milliseconds: 600));
      if (!isClosed) emit(state.copyWith(showFocus: false));
    } catch (_) {}
  }

  Future<void> toggleFlashMode() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    FlashMode newMode = _currentFlashMode == FlashMode.off ? FlashMode.auto : 
                       (_currentFlashMode == FlashMode.auto ? FlashMode.always : FlashMode.off);
    try {
      await _controller!.setFlashMode(newMode);
      _currentFlashMode = newMode;
      // Triggers UI rebuild to update flash icon
      emit(state.copyWith()); 
    } catch (_) {}
  }

  Future<void> onAppPaused() async {
    await _controller?.dispose();
    _controller = null;
    emit(state.copyWith(status: CameraStatus.loading));
  }

  Future<void> onAppResumed() async {
    if (_controller != null && _controller!.value.isInitialized) return;
    await _initCamera();
  }

  Future<void> openSettings() async { await openAppSettings(); }

  @override
  Future<void> close() {
    final controllerToDispose = _controller;
    _controller = null;
    controllerToDispose?.dispose();
    return super.close();
  }
}