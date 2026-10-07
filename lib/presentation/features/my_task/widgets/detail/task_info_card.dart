import 'package:bapendacore/core/utils/app_formatters_utils.dart';
import 'package:bapendacore/core/utils/date_format_id.dart';
import 'package:bapendacore/domain/entities/my_task/task_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../../utils/task_deadline_label.dart';

/// Rincian lengkap tugas. Properti khusus jenis tugas ([TaskEntity
/// .extraAttributes]) ikut tampil otomatis di bagian bawah.
class TaskInfoCard extends StatelessWidget {
  const TaskInfoCard({super.key, required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('Wajib pajak', task.taxpayerName),
      ('NOP', AppFormatters.nop(task.nop)),
      ('Jenis pajak', task.taxType),
      ('Objek pajak', task.objectName),
      ('Alamat', task.address),
      (
        'Ditugaskan',
        '${formatTanggalId(task.assignedAt)}, ${formatJamId(task.assignedAt)}',
      ),
      ('Batas waktu', taskDeadlineDateTime(task)),
      ...task.extraAttributes.entries.map((e) => (e.key, e.value)),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi tugas',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppThemeColors.titleText,
            ),
          ),
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
