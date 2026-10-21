// import 'package:mybapenda/core/constants/app_colors.dart';
// import 'package:mybapenda/core/services/update_service.dart';
// import 'package:mybapenda/presentation/features/update/widget/update_progress_dialog_widget.dart';
// import 'package:flutter/material.dart';

// class UpdateAvailableDialog extends StatelessWidget {
//   final UpdateInfo info;

//   const UpdateAvailableDialog({super.key, required this.info});

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text("Update Tersedia v${info.version}"),
//       content: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text("Versi baru tersedia. Mohon update aplikasi."),
//             const SizedBox(height: 10),
//             const Text(
//               "Apa yang baru:",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Text(info.changelog),
//           ],
//         ),
//       ),
//       actions: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text(
//                 "Nanti",
//                 style: TextStyle(color: AppColors.primary),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 UpdateProgressDialogWidget.show(
//                   context,
//                   downloadUrl: info.downloadUrl,
//                   version: info.version,
//                 );
//               },
//               child: const Text(
//                 "Update\nSekarang",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: AppColors.primary),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
