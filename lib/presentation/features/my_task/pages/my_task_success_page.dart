import 'package:bapendacore/core/utils/app_formatters_utils.dart';
import 'package:bapendacore/domain/entities/my_task/task_entity.dart';
import 'package:bapendacore/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors_new.dart';
import '../../va_qris/widgets/common/va_qris_primary_button.dart';

/// Layar setelah hasil tugas terkirim.
///
/// TODO(tech-debt): status akhir (mis. menunggu verifikasi supervisor) belum
/// ada di alur bisnis. Saat ini langsung dianggap selesai.
class MyTaskSuccessPage extends StatelessWidget {
  const MyTaskSuccessPage({super.key, required this.task});

  final TaskEntity task;

  void _backToDashboard(BuildContext context) {
    // go (bukan pop) agar dashboard dimuat ulang dan tugas tampil di "Selesai".
    context.go(AppRoutes.myTask);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToDashboard(context);
      },
      child: Scaffold(
        backgroundColor: AppThemeColors.defaultBackground,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            color: AppThemeColors.successSoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            size: 56,
                            color: AppThemeColors.success,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Tugas terkirim',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppThemeColors.titleText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Hasil pengerjaan sudah diterima. Supervisor dapat melihatnya melalui Back Office.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.4,
                            color: AppThemeColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppThemeColors.defaultSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppThemeColors.subtleBorder),
                          ),
                          child: Column(
                            children: [
                              _Row(label: 'Jenis tugas', value: task.type.label),
                              _Row(label: 'Nomor tugas', value: task.taskNumber),
                              _Row(label: 'Wajib pajak', value: task.taxpayerName),
                              _Row(label: 'NOP', value: AppFormatters.nop(task.nop)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: VaQrisPrimaryButton(
                  label: 'Kembali ke My Task',
                  onPressed: () => _backToDashboard(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppThemeColors.secondaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppThemeColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
