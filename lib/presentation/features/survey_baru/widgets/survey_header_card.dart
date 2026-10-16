import 'package:bapendacore/presentation/shared/widgets/info_row.dart';
import 'package:bapendacore/core/constants/design_system/tokens/app_palette.dart';
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
        color: context.palette.surface,
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
          leading: Icon(
            Icons.assignment_outlined,
            size: 20,
            color: context.palette.accent,
          ),
          title: Text(
            'Informasi Permohonan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.palette.textPrimary,
            ),
          ),
          subtitle: Text(
            v('noPelayanan'),
            style: TextStyle(
              fontSize: 12,
              color: context.palette.textSecondary,
            ),
          ),
          children: [
            Divider(height: 1, color: context.palette.border),
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
