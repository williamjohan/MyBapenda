import 'package:bapendacore/core/constants/app_colors_new.dart';
import 'package:bapendacore/presentation/shared/widgets/info_row.dart';
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

    return Container(
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
  }
}
