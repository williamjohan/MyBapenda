import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'camera_state.freezed.dart';

enum CameraStatus {
  initial,
  permissionDenied,
  permissionPermanentlyDenied,
  loading,
  ready,
  capturing,
  reviewing, // Layar beralih ke CameraReviewPage
  submitting, // Proses upload ke API
  success,
  error,
}

@freezed
class CameraState with _$CameraState {
  const factory CameraState({
    @Default(CameraStatus.initial) CameraStatus status,
    
    // Data Capture & API
    File? originalFile,
    File? compressedFile,
    String? latitude,
    String? longitude,
    String? address,
    String? errorMessage,
    
    // Data UI (Fokus Kamera)
    @Default(false) bool showFocus,
    @Default(0.0) double focusX,
    @Default(0.0) double focusY,
  }) = _CameraState;
}