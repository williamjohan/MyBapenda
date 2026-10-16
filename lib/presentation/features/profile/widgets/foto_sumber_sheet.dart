import 'package:flutter/material.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';

/// Pilihan sumber foto profil. true = kamera, false = galeri, null = batal.
class FotoSumberSheet extends StatelessWidget {
  const FotoSumberSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: context.palette.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const FotoSumberSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ganti foto profil',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Format JPG atau PNG, maksimal 2 MB.',
              style: TextStyle(fontSize: 12.5, color: palette.textSecondary),
            ),
            const SizedBox(height: 8),
            _Option(
              icon: Icons.photo_camera_outlined,
              title: 'Ambil dengan kamera',
              onTap: () => Navigator.of(context).pop(true),
            ),
            _Option(
              icon: Icons.photo_library_outlined,
              title: 'Unggah dari galeri',
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: palette.accentSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: palette.accent),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: palette.textPrimary,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: palette.textTertiary),
    );
  }
}
