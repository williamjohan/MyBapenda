import 'package:mybapenda/domain/entities/va_qris/recent_reference_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/theme_kit.dart';
import 'reference_option_tile.dart';

/// Daftar "Terakhir dicari" (riwayat NOP di HP ini untuk pegawai yang login).
class RecentReferenceSection extends StatelessWidget {
  const RecentReferenceSection({
    super.key,
    required this.items,
    required this.onSelected,
    this.onClear,
  });

  final List<RecentReferenceEntity> items;
  final ValueChanged<RecentReferenceEntity> onSelected;

  /// null = tombol Hapus tidak ditampilkan.
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history_rounded, size: 18, color: palette.accent),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Terakhir dicari',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
            ),
            if (onClear != null)
              TextButton(
                onPressed: onClear,
                style: TextButton.styleFrom(
                  foregroundColor: palette.textSecondary,
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Hapus'),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (final item in items) ...[
          ReferenceOptionTile(
            taxTypeId: item.taxTypeId,
            taxTypeName: item.taxTypeName,
            referenceNumber: item.referenceNumber,
            name: item.name,
            onTap: () => onSelected(item),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
