// lib/presentation/features/camera/widgets/camera_review_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors_new.dart'; // Sesuaikan path
import '../cubit/camera_cubit.dart';
import '../cubit/camera_state.dart';

class CameraReviewView extends StatelessWidget {
  const CameraReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraCubit, CameraState>(
      builder: (context, state) {
        final file = state.originalFile;
        final isSubmitting = state.status == CameraStatus.submitting;

        if (file == null) return const SizedBox.shrink();

        return Stack(
          children: [
            // 1. BACKGROUND: Gambar Penuh
            Positioned.fill(
              child: Image.file(
                File(file.path),
                fit: BoxFit.cover,
              ),
            ),
            
            // Overlay hitam tipis agar teks alamat terbaca
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),

            // 2. HEADER: Tombol Back / Foto Ulang
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: Material(
                color: Colors.black.withValues(alpha: 0.5),
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: isSubmitting ? null : () => context.read<CameraCubit>().retakePhoto(),
                ),
              ),
            ),

            // 3. BOTTOM SHEET: Data Lokasi & Tombol Submit
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informasi Error (Jika upload gagal)
                    if (state.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppThemeColors.dangerSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppThemeColors.danger, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: const TextStyle(
                                  color: AppThemeColors.danger,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Text(
                      'Lokasi Ditemukan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Box Alamat
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: AppThemeColors.gold, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: state.address == null
                                ? Row(
                                    children: [
                                      SizedBox(
                                        width: 16, height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2, 
                                          color: AppThemeColors.gold,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text("Mencari alamat...", style: TextStyle(fontSize: 13)),
                                    ],
                                  )
                                : Text(
                                    state.address!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: Colors.black87,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Tombol Submit
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (isSubmitting || state.address == null)
                            ? null
                            : () => context.read<CameraCubit>().submitLaporan(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemeColors.primary, // Cokelat/Gold Bapenda
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                'Kirim Laporan',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Tombol Retake (Hanya muncul jika belum loading)
                    if (!isSubmitting)
                      Center(
                        child: TextButton(
                          onPressed: () => context.read<CameraCubit>().retakePhoto(),
                          child: const Text(
                            'Foto Ulang',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}