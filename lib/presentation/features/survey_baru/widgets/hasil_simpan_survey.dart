import 'package:bapendacore/core/constants/app_colors_new.dart';
import 'package:bapendacore/presentation/shared/widgets/mb_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/entities/cek_reklames/survey_permohonan_baru/simpan_survey_hasil_entity.dart';
import '../../../../routes/app_routes.dart';

Future<void> tampilkanHasilSimpanSurvey(
  BuildContext context,
  SimpanSurveyHasilEntity hasil,
) async {
  if (hasil.terkirim) {
    await BapendaDialog.showSuccess(
      context,
      title: 'Survey Terkirim',
      message: 'Survey berhasil dikirim ke penilaian.',
      primaryLabel: 'Ke Dashboard',
      primaryIcon: Icons.arrow_forward_rounded,
      autoCloseAfter: const Duration(seconds: 5),
      barrierDismissible: false,
    );
    if (!context.mounted) return;
    context.goNamed(AppRoutes.reklameDashboard);
    return;
  }

  await BapendaDialog.show<bool>(
    context,
    tone: BapendaDialogTone.warning,
    icon: Icons.save_outlined,
    title: 'Draft Survey Tersimpan',
    message: hasil.kurangLengkap.isEmpty
        ? (hasil.message.isEmpty
              ? 'Survey belum dikirim ke penilaian.'
              : hasil.message)
        : 'Survey belum dikirim ke penilaian. Lengkapi isian berikut lalu '
              'kirim lagi:',
    content: hasil.kurangLengkap.isEmpty
        ? null
        : _DaftarKekurangan(items: hasil.kurangLengkap),
    actions: const [
      BapendaDialogAction<bool>.primary(label: 'Mengerti', result: true),
    ],
  );
}

/// [BARU] Daftar isian yang masih kurang (menggantikan baris "•  " manual).
class _DaftarKekurangan extends StatelessWidget {
  final List<String> items;

  const _DaftarKekurangan({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.warningSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.circle,
                      size: 5,
                      color: AppThemeColors.gold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      items[i],
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: AppThemeColors.titleText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
