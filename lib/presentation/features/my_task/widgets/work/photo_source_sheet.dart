import 'package:bapendacore/domain/entities/my_task/task_photo_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';

/// Pilihan sumber foto: kamera langsung atau galeri.
///
/// TODO(tech-debt): galeri harus memakai Android Photo Picker (tanpa izin
/// akses media penuh) agar aman dari kebijakan Google Play.
class PhotoSourceSheet extends StatelessWidget {
  const PhotoSourceSheet({super.key});

  static Future<TaskPhotoSource?> show(BuildContext context) {
    return showModalBottomSheet<TaskPhotoSource>(
      context: context,
      backgroundColor: AppThemeColors.defaultSurface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const PhotoSourceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih sumber foto',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppThemeColors.titleText,
              ),
            ),
            const SizedBox(height: 8),
            _Option(
              icon: Icons.photo_camera_outlined,
              title: 'Ambil dengan kamera',
              onTap: () => Navigator.of(context).pop(TaskPhotoSource.camera),
            ),
            _Option(
              icon: Icons.photo_library_outlined,
              title: 'Pilih dari galeri',
              onTap: () => Navigator.of(context).pop(TaskPhotoSource.gallery),
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
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppThemeColors.primarySoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppThemeColors.brown),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: AppThemeColors.titleText,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppThemeColors.tertiaryText,
      ),
    );
  }
}
