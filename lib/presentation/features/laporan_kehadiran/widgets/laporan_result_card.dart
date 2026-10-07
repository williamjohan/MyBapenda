import 'package:flutter/material.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/section_label.dart';

/// Hasil unduhan: nama file + tombol Buka & Bagikan.
class LaporanResultCard extends StatelessWidget {
  final String fileName;
  final VoidCallback onOpen;
  final VoidCallback onShare;

  const LaporanResultCard({
    super.key,
    required this.fileName,
    required this.onOpen,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel(
            text: 'Laporan Tersimpan',
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: palette.dangerSoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: palette.danger,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Button(
                  label: 'Buka',
                  icon: Icons.open_in_new_rounded,
                  height: 44,
                  onPressed: onOpen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Button(
                  label: 'Bagikan',
                  icon: Icons.share_rounded,
                  height: 44,
                  variant: BapendaButtonVariant.outlined,
                  onPressed: onShare,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
