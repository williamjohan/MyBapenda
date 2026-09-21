// lib/presentation/features/camera/pages/camera_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_routes.dart';
import '../cubit/camera_cubit.dart';
import '../cubit/camera_state.dart';
import '../widgets/camera_error_view.dart';
import '../widgets/camera_review_view.dart';
import '../widgets/camera_view.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Layar kamera identik dengan background hitam, jadi status bar harus putih
      value: SystemUiOverlayStyle.light, 
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocConsumer<CameraCubit, CameraState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            // Jika status sukses, langsung arahkan ke halaman Check Result
            if (state.status == CameraStatus.success) {
              // Jika Anda butuh melempar data ke layar sukses, gunakan ekstra
              context.pushReplacement(
                AppRoutes.results, 
                extra: state.address, 
              );
            }
          },
          buildWhen: (previous, current) => previous.status != current.status,
          builder: (context, state) {
            // 🚀 RENDER UI BERDASARKAN STATUS
            switch (state.status) {
              case CameraStatus.initial:
              case CameraStatus.loading:
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );

              case CameraStatus.permissionDenied:
              case CameraStatus.permissionPermanentlyDenied:
              case CameraStatus.error:
                return CameraErrorView(
                  message: state.errorMessage ?? 'Gagal mengakses kamera atau lokasi.',
                  onRetry: () => context.read<CameraCubit>().start(),
                );

              case CameraStatus.ready:
              case CameraStatus.capturing:
                // Menampilkan Live Preview Kamera native
                return const CameraView();

              case CameraStatus.reviewing:
              case CameraStatus.submitting:
                // Menampilkan foto yang sudah dijepret + Alamat + Tombol Submit
                return const CameraReviewView();

              case CameraStatus.success:
                // Return kosong karena UI sedang bertransisi ke halaman Result
                return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}