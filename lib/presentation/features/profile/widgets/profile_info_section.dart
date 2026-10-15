// lib/presentation/features/profile/widgets/profile_info_section.dart
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

  const ProfileInfoSection({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(text: title, icon: icon),
        const SizedBox(height: 10),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) Divider(height: 1, color: palette.border),
                _ProfileInfoTile(item: items[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final ProfileInfoItem item;

  const _ProfileInfoTile({required this.item});

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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
