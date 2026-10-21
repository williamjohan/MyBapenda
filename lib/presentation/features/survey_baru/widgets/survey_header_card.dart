import 'package:mybapenda/core/constants/app_colors_new.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_history/history_format.dart';
import 'package:mybapenda/presentation/shared/widgets/info_row.dart';
import 'package:flutter/material.dart';

class SurveyHeaderCard extends StatelessWidget {
  final Map<String, dynamic> sisi;
  final bool initiallyExpanded;

  const SurveyHeaderCard({
    super.key,
    required this.sisi,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final h = sisi['header'];
    if (h is! Map) return const SizedBox.shrink();

    String v(String k) {
      final x = h[k];
      return (x == null || '$x'.trim().isEmpty) ? '-' : '$x';
    }

    final returned = h['dikembalikan'] == true;
    final ket = h['ketPengembalian'] as String?;
    final tgl = h['tglPengembalian'];

    final card = Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          shape: const Border(),
          collapsedShape: const Border(),
          leading: const Icon(
            Icons.assignment_outlined,
            size: 20,
            color: AppThemeColors.primary,
          ),
          title: const Text(
            'Informasi Permohonan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2933),
            ),
          ),
          subtitle: Text(
            v('noPelayanan'),
            style: const TextStyle(fontSize: 12, color: Color(0xFF7B8794)),
          ),
          children: [
            const Divider(height: 1, color: Color(0xFFEEF0F3)),
            const SizedBox(height: 10),
            InfoRow(label: 'No. Pelayanan', value: v('noPelayanan')),
            InfoRow(label: 'NPWPD', value: v('npwpd')),
            InfoRow(label: 'Kategori Penyelenggaraan', value: v('kategori')),
            InfoRow(label: 'Status Permohonan', value: v('statusPermohonan')),
            InfoRow(label: 'Jenis Reklame', value: v('jenisReklameNama')),
            InfoRow(
              label: 'Lokasi Penyelenggaraan',
              value: v('lokPenyelenggaraan'),
            ),
            InfoRow(label: 'Tgl Mulai Berlaku', value: v('tglMulai')),
            InfoRow(label: 'Tgl Selesai Berlaku', value: v('tglSelesai')),
          ],
        ),
      ),
    );

    if (!returned) return card;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppThemeColors.dangerSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppThemeColors.danger.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.assignment_return_outlined,
                size: 18,
                color: AppThemeColors.danger,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dikembalikan dari Penilaian',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppThemeColors.danger,
                      ),
                    ),
                    if (ket != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        ket,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: Color(0xFF3E4C59),
                        ),
                      ),
                    ],
                    if (tgl is DateTime) ...[
                      const SizedBox(height: 3),
                      Text(
                        HistoryFmt.tanggalJam(tgl),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7B8794),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        card,
      ],
    );
  }
}
