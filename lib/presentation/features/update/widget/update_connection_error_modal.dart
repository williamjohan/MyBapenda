import 'package:mybapenda/presentation/shared/widgets/custom_modal_widget.dart';
import 'package:flutter/material.dart';

Future<void> showUpdateConnectionErrorModal(
  BuildContext context, {
  VoidCallback? onRetry,
}) {
  return showAppModal(
    context: context,
    isDismissible: true,
    topIcon: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.wifi_off_rounded, size: 40, color: Colors.red),
    ),
    content: Column(
      // Pastikan konten rapi
      children: [
        const Text(
          "Koneksi Terputus",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Gagal mengunduh pembaruan. Pastikan koneksi internet Anda stabil, lalu coba lagi.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    ),
    primaryButton: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        if (context.mounted) {
          Navigator.of(context).maybePop();
        }
        if (onRetry != null) {
          onRetry();
        }
      },
      child: const Text("Coba Lagi"),
    ),
    showCloseButton: false,
  );
}
