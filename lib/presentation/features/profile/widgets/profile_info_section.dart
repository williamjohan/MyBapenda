import 'package:flutter/material.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../shared/widgets/section_label.dart';

/// Satu baris info profil: ikon + label + nilai.
typedef ProfileInfoItem = ({IconData icon, String label, String value});

/// Grup info profil dengan judul section, mengikuti light/dark.
class ProfileInfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<ProfileInfoItem> items;

  /// Baris khusus (mis. kontak dengan tombol ubah) di atas `items`.
  final List<Widget> leading;

  const ProfileInfoSection({
    super.key,
    required this.title,
    required this.icon,
    this.items = const [],
    this.leading = const [],
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final rows = [
      ...leading,
      for (final item in items) ProfileInfoTile(item: item),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(text: title, icon: icon),
        const SizedBox(height: 10),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) Divider(height: 1, color: palette.border),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileInfoTile extends StatelessWidget {
  final ProfileInfoItem item;

  /// Tampil di bawah nilai (mis. badge terverifikasi).
  final Widget? badge;

  /// Tampil di kanan (mis. tombol ubah).
  final Widget? trailing;

  const ProfileInfoTile({
    super.key,
    required this.item,
    this.badge,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final value = item.value.trim().isEmpty ? '-' : item.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 20, color: palette.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(fontSize: 12, color: palette.textTertiary),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                    height: 1.35,
                  ),
                ),
                if (badge != null) ...[const SizedBox(height: 6), badge!],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
