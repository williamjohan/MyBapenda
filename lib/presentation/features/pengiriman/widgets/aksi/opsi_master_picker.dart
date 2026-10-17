import 'package:flutter/material.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../../domain/entities/pengiriman/master_pengiriman_entity.dart';
import '../../../../shared/widgets/section_label.dart';

/// Pilihan tunggal dari master (alasan gagal, hubungan penerima) berupa
/// daftar chip, dengan status memuat / gagal muat.
class OpsiMasterPicker extends StatelessWidget {
  final String label;
  final List<OpsiMasterEntity>? opsi;
  final bool gagalMuat;
  final VoidCallback onMuatUlang;
  final OpsiMasterEntity? terpilih;
  final ValueChanged<OpsiMasterEntity> onPilih;

  const OpsiMasterPicker({
    super.key,
    required this.label,
    required this.opsi,
    required this.gagalMuat,
    required this.onMuatUlang,
    required this.terpilih,
    required this.onPilih,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final daftar = opsi;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label *',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (daftar == null && gagalMuat)
          SurfaceCard(
            padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Gagal memuat pilihan.',
                    style: TextStyle(color: palette.statusGagal, fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: onMuatUlang,
                  child: const Text('Muat ulang'),
                ),
              ],
            ),
          )
        else if (daftar == null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: palette.accent,
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in daftar)
                ChoiceChip(
                  label: Text(o.nama),
                  selected: terpilih?.id == o.id,
                  onSelected: (_) => onPilih(o),
                  showCheckmark: false,
                  backgroundColor: palette.surface,
                  selectedColor: palette.accent,
                  side: BorderSide(
                    color: terpilih?.id == o.id
                        ? palette.accent
                        : palette.border,
                  ),
                  labelStyle: TextStyle(
                    color: terpilih?.id == o.id
                        ? palette.surface
                        : palette.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
