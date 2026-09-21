// lib/presentation/features/camera/widgets/camera_view.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors_new.dart'; // Sesuaikan path
import '../cubit/camera_cubit.dart';
import '../cubit/camera_state.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Daftarkan observer untuk mendeteksi aplikasi di-minimize / dibuka kembali
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<CameraCubit>();
    if (cubit.state.status == CameraStatus.capturing || 
        cubit.state.status == CameraStatus.reviewing) {
      return; // Jangan ganggu kamera jika sedang proses foto
    }

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      cubit.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      cubit.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraCubit, CameraState>(
      builder: (context, state) {
        final cubit = context.read<CameraCubit>();
        final controller = cubit.controller;

        // Safety check jika controller belum siap
        if (controller == null || !controller.value.isInitialized) {
          return const SizedBox.shrink();
        }

        final isCapturing = state.status == CameraStatus.capturing;

        return Stack(
          fit: StackFit.expand,
          children: [
            // ===============================================================
            // 1. LAYER BAWAH: LIVE PREVIEW KAMERA & GESTURE
            // ===============================================================
            GestureDetector(
              onScaleStart: (_) => cubit.onScaleStart(),
              onScaleUpdate: (details) => cubit.onScaleUpdate(details.scale),
              onTapDown: (details) {
                // Kalkulasi ukuran layar untuk titik fokus
                final size = MediaQuery.of(context).size;
                cubit.onTapToFocus(
                  tapPosition: details.localPosition,
                  previewSize: size,
                );
              },
              child: CameraPreview(controller),
            ),

            // ===============================================================
            // 2. LAYER OVERLAY: GRID/GUIDELINE (BEST PRACTICE INSPEKSI)
            // ===============================================================
            CustomPaint(
              painter: _GridGuidelinePainter(),
            ),

            // ===============================================================
            // 3. LAYER OVERLAY: FOCUS INDICATOR (BAPENDA ORANGE STYLE)
            // ===============================================================
            if (state.showFocus)
              Positioned(
                left: state.focusX - 30, // Geser setengah ukuran kotak (60/2)
                top: state.focusY - 30,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.5, end: 1.0), // Animasi membesar ke mengecil
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          // Warna oranye khas Bapenda
                          border: Border.all(color: AppThemeColors.gold, width: 2.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // ===============================================================
            // 4. LAYER KONTROL ATAS: TOMBOL BACK & FLASH
            // ===============================================================
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  _buildCircleButton(
                    icon: _getFlashIcon(cubit.currentFlashMode),
                    onTap: cubit.toggleFlashMode,
                  ),
                ],
              ),
            ),

            // ===============================================================
            // 5. LAYER KONTROL BAWAH: SHUTTER BUTTON (ORANGE STYLE)
            // ===============================================================
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: isCapturing ? null : () => cubit.capture(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCapturing ? Colors.grey : AppThemeColors.gold,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: isCapturing ? 60 : 66,
                        height: isCapturing ? 60 : 66,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCapturing ? Colors.grey.shade400 : AppThemeColors.gold,
                        ),
                        child: isCapturing
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Teks Bantuan di atas tombol shutter
            Positioned(
              bottom: 130,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Posisikan reklame di tengah",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Komponen pembantu untuk tombol melingkar (Back & Flash)
  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.black.withValues(alpha: 0.4), // Kaca transparan
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  IconData _getFlashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        return Icons.flash_off_rounded;
      case FlashMode.auto:
        return Icons.flash_auto_rounded;
      case FlashMode.always:
        return Icons.flash_on_rounded;
      case FlashMode.torch:
        return Icons.highlight_rounded;
    }
  }
}

// ===================================================================
// PAINTER: GRID GUIDELINE (Rule of Thirds)
// ===================================================================
class _GridGuidelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    // Gambar 2 garis vertikal
    final thirdWidth = size.width / 3;
    canvas.drawLine(Offset(thirdWidth, 0), Offset(thirdWidth, size.height), paint);
    canvas.drawLine(Offset(thirdWidth * 2, 0), Offset(thirdWidth * 2, size.height), paint);

    // Gambar 2 garis horizontal
    final thirdHeight = size.height / 3;
    canvas.drawLine(Offset(0, thirdHeight), Offset(size.width, thirdHeight), paint);
    canvas.drawLine(Offset(0, thirdHeight * 2), Offset(size.width, thirdHeight * 2), paint);

    // Gambar Crosshair kecil di tengah (Bapenda Orange)
    final centerPaint = Paint()
      ..color = AppThemeColors.gold.withValues(alpha: 0.7)
      ..strokeWidth = 1.5;
    
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    canvas.drawLine(Offset(centerX - 10, centerY), Offset(centerX + 10, centerY), centerPaint);
    canvas.drawLine(Offset(centerX, centerY - 10), Offset(centerX, centerY + 10), centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}