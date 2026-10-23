import 'package:mybapenda/domain/entities/my_task/my_task_detail_entity.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../../utils/task_deadline_label.dart';

/// Rincian lengkap tugas: gabungan data detail dari server dan data dari daftar.
class TaskInfoCard extends StatelessWidget {
  const TaskInfoCard({super.key, required this.task, required this.detail});

  final MyTaskEntity task;
  final MyTaskDetailEntity detail; // [BARU] dari /api/mytask/headerdetail

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('Wajib pajak', detail.namaWp),
      ('NPWPD', task.npwpd), // [UBAH] dulu NOP
      ('No. referensi', detail.noReferensi),
      ('No. pelayanan', detail.nomorPelayanan),
      ('Jenis pajak', detail.jenisPajak),
      ('Objek pajak', detail.jenisObjek),
      ('Alamat objek', detail.alamatObjek),
      ('Alamat WP', task.alamatWp),
      if (task.tglSurat != null)
        ('Tanggal surat', taskDateLabel(task.tglSurat)),
      ('Ditugaskan', taskDateLabel(detail.taskAssign)),
      ('Batas waktu', taskDateLabel(detail.expAssign)),
    ];

    return _InfoContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoTitle(),
          const SizedBox(height: 8),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, color: AppThemeColors.veryLightBorder),
            _InfoRow(label: rows[i].$1, value: rows[i].$2),
          ],
        ],
      ),
    );
  }
}

class TaskInfoSkeleton extends StatelessWidget {
  const TaskInfoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoTitle(),
          const SizedBox(height: 8),
          for (var i = 0; i < 7; i++)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  _Bar(width: 80),
                  SizedBox(width: 24),
                  Expanded(child: _Bar()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class TaskInfoError extends StatelessWidget {
  const TaskInfoError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _InfoContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoTitle(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 18,
                color: AppThemeColors.danger,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppThemeColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba lagi'),
            style: TextButton.styleFrom(foregroundColor: AppThemeColors.gold),
          ),
        ],
      ),
    );
  }
}

class _InfoContainer extends StatelessWidget {
  const _InfoContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.subtleBorder),
      ),
      child: child,
    );
  }
}

class _InfoTitle extends StatelessWidget {
  const _InfoTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Informasi tugas',
      style: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w800,
        color: AppThemeColors.titleText,
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: AppThemeColors.shimmer,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
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
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
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
