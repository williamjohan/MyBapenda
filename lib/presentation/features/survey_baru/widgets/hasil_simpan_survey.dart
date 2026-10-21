import 'package:bapendacore/core/constants/app_colors_new.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/entities/cek_reklames/survey_permohonan_baru/simpan_survey_hasil_entity.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/widgets/mb_dialog.dart';
import '../utils/survey_lokasi_ui_helper.dart';

/// Tampilkan hasil `simpan-survey`.
///
/// - Submit: survey sudah masuk penilaian, kembali ke dashboard setelah
///   dialog ditutup (daftar task dimuat ulang, task ini sudah hilang).
/// - Draft: tetap di halaman; tampilkan isian yang masih kurang.
Future<void> tampilkanHasilSimpanSurvey(
  BuildContext context,
  SimpanSurveyHasilEntity hasil,
) async {
  if (hasil.terkirim) {
    final router = GoRouter.of(context);
    await BapendaDialog.alert(
      context,
      title: 'Survey Terkirim',
      message:
          'Hasil survey sudah masuk ke penilaian. Terima kasih, survey '
          'lapangan untuk permohonan ini selesai.',
      tone: BapendaDialogTone.success,
      icon: Icons.task_alt_rounded,
      buttonLabel: 'Kembali ke Dashboard',
      dismissible: false,
    );
    router.goNamed(AppRoutes.reklameDashboard);
    return;
  }

  final kurang = hasil.kurangLengkap;
  await BapendaDialog.alert(
    context,
    title: 'Draft Tersimpan',
    message: kurang.isEmpty
        ? (hasil.message.isEmpty
              ? 'Survey disimpan sebagai draft dan belum dikirim ke '
                    'penilaian.'
              : hasil.message)
        : 'Survey disimpan sebagai draft dan belum dikirim ke penilaian. '
              'Lengkapi isian berikut lalu kirim lagi.',
    tone: BapendaDialogTone.info,
    icon: Icons.bookmark_added_rounded,
    buttonLabel: 'Lanjutkan Mengisi',
    content: kurang.isEmpty ? null : _DaftarKurang(items: kurang),
  );
}

/// Tampilkan penolakan `simpan-survey` apa adanya. Penolakan jarak titik
/// reklame ("sisi ke-N lebih dari X m dari lokasi petugas") memberi tombol
/// pindahkan pin: return N bila dipilih, selain itu null.
Future<int?> tampilkanGagalSimpanSurvey(
  BuildContext context,
  String pesan,
) async {
  final sisi = SurveyLokasiUiHelper.sisiDiLuarRadius(pesan);
  if (sisi == null) {
    await BapendaDialog.alert(
      context,
      title: 'Survey Belum Tersimpan',
      message: pesan,
      tone: BapendaDialogTone.danger,
      icon: Icons.error_outline_rounded,
      buttonLabel: 'Tutup',
    );
    return null;
  }
  final pindah = await BapendaDialog.confirm(
    context,
    title: 'Titik Reklame Terlalu Jauh',
    message: pesan,
    tone: BapendaDialogTone.danger,
    icon: Icons.wrong_location_rounded,
    confirmLabel: 'Pindahkan Pin',
    cancelLabel: 'Tutup',
  );
  return pindah ? sisi : null;
}

/// Daftar isian yang masih kurang (dari server), bisa di-scroll bila panjang.
class _DaftarKurang extends StatelessWidget {
  final List<String> items;

  const _DaftarKurang({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: AppThemeColors.warningSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppThemeColors.warning.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Text(
              '${items.length} isian belum lengkap',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.titleText,
              ),
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.radio_button_unchecked_rounded,
                      size: 14,
                      color: AppThemeColors.warning,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      items[i],
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: AppThemeColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
