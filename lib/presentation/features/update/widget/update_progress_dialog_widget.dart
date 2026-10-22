// import 'dart:io';

// import 'package:mybapenda/presentation/features/update/cubit/update_progress_cubit.dart';
// import 'package:mybapenda/presentation/features/update/cubit/update_progress_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../shared/widgets/custom_modal_widget.dart';

// class UpdateProgressDialogWidget extends StatelessWidget {
//   final String downloadUrl;
//   final String version;

//   const UpdateProgressDialogWidget({
//     super.key,
//     required this.downloadUrl,
//     required this.version,
//   });

//   static void show(
//     BuildContext context, {
//     required String downloadUrl,
//     required String version,
//   }) {
//     if (Platform.isIOS) return;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => UpdateProgressDialogWidget(
//         downloadUrl: downloadUrl,
//         version: version,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) =>
//           UpdateProgressCubit(downloadUrl: downloadUrl, version: version)
//             ..start(),
//       child: const _UpdateProgressView(),
//     );
//   }
// }

// // =======================================================
// // =======================  UI ===========================
// // =======================================================

// class _UpdateProgressView extends StatelessWidget {
//   const _UpdateProgressView();

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<UpdateProgressCubit, UpdateProgressState>(
//       listener: (context, state) {
//         // ✅ INSTALL SELESAI → TUTUP DIALOG
//         if (state is UpdateCompleted) {
//           if (Navigator.canPop(context)) {
//             Navigator.pop(context);
//           }
//         }

//         // ❌ ERROR → TAMPILKAN MODAL ERROR
//         if (state is UpdateError) {
//           showConnectionErrorModal(
//             context,
//             onRetry: state.canRetry
//                 ? () {
//                     context.read<UpdateProgressCubit>().retry();
//                   }
//                 : null,
//             message:
//                 "Gagal mengunduh pembaruan. Pastikan koneksi internet Anda stabil, lalu coba lagi",
//           ).then((_) {
//             // Kalau user tutup modal TANPA retry → close dialog utama
//             if (context.mounted &&
//                 context.read<UpdateProgressCubit>().state is UpdateError) {
//               Navigator.pop(context);
//             }
//           });
//         }
//       },
//       child: PopScope(
//         canPop: false,
//         child: AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             vertical: 20,
//             horizontal: 24,
//           ),
//           content: BlocBuilder<UpdateProgressCubit, UpdateProgressState>(
//             builder: (context, state) {
//               double progress = 0.0;
//               String message = "Menyiapkan unduhan...";

//               if (state is UpdateDownloading) {
//                 progress = state.progress;
//                 message = state.message;
//               } else if (state is UpdateInstalling) {
//                 progress = 1.0;
//                 message = "Memverifikasi & Menginstal...";
//               }

//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.withValues(alpha: 0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.cloud_download_rounded,
//                       size: 48,
//                       color: Colors.blueAccent,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     "Update",
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     message,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                       height: 1.4,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: LinearProgressIndicator(
//                       value: progress,
//                       minHeight: 8,
//                       backgroundColor: Colors.grey[200],
//                       valueColor: const AlwaysStoppedAnimation<Color>(
//                         Colors.blue,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     "Harap Tunggu Hingga Proses Download Selesai.",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[400],
//                       height: 1.4,
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
