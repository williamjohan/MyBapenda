import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/entities/cek_reklames/survey_permohonan_baru/simpan_survey_hasil_entity.dart';
import '../../../../routes/app_routes.dart';

/// Tampilkan hasil `simpan-survey`.
///
/// - Submit: survey sudah masuk penilaian, kembali ke dashboard (daftar
///   task dimuat ulang saat dibuka, task ini sudah hilang).
/// - Draft: tetap di halaman; tampilkan isian yang masih kurang.
Future<void> tampilkanHasilSimpanSurvey(
  BuildContext context,
  SimpanSurveyHasilEntity hasil,
) async {
  if (hasil.terkirim) {
    final messenger = ScaffoldMessenger.of(context);
    context.goNamed(AppRoutes.reklameDashboard);
    messenger.showSnackBar(
      const SnackBar(content: Text('Survey berhasil dikirim ke penilaian.')),
    );
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.save_outlined),
      title: const Text('Draft survey tersimpan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasil.kurangLengkap.isEmpty)
              Text(
                hasil.message.isEmpty
                    ? 'Survey belum dikirim ke penilaian.'
                    : hasil.message,
              )
            else ...[
              const Text(
                'Survey belum dikirim ke penilaian. Lengkapi isian berikut '
                'lalu kirim lagi:',
              ),
              const SizedBox(height: 10),
              for (final k in hasil.kurangLengkap)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(child: Text(k)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Mengerti'),
        ),
      ],
    ),
  );
}
