import 'dart:io';
import 'package:bapendacore/core/utils/date_format_id.dart';
import 'package:bapendacore/domain/entities/my_task/task_photo_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';

/// Satu slot foto (dipakai untuk selfie, foto sebelum/sesudah, foto surat).
/// Kosong -> ketuk untuk ambil. Terisi -> pratinjau + ganti/hapus.
class TaskPhotoSlotCard extends StatelessWidget {
  const TaskPhotoSlotCard({
    super.key,
    required this.label,
    required this.photo,
    required this.onPick,
    required this.onRemove,
    this.hint,
    this.isBusy = false,
  });

  final String label;
  final String? hint;
  final TaskPhotoEntity? photo;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppThemeColors.primaryText,
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 2),
          Text(
            hint!,
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              color: AppThemeColors.secondaryText,
            ),
          ),
        ],
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 4 / 3,
          child: photo == null
              ? _EmptyPreview(onTap: onPick)
              : _FilledPreview(photo: photo!, onReplace: onPick, onRemove: onRemove),
        ),
      ],
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppThemeColors.defaultBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppThemeColors.defaultBorder, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo_outlined, size: 34, color: AppThemeColors.gold),
              SizedBox(height: 8),
              Text(
                'Ketuk untuk menambahkan foto',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppThemeColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilledPreview extends StatelessWidget {
  const _FilledPreview({
    required this.photo,
    required this.onReplace,
    required this.onRemove,
  });

  final TaskPhotoEntity photo;
  final VoidCallback onReplace;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final path = photo.path;
    final sourceLabel =
        photo.source == TaskPhotoSource.camera ? 'Kamera' : 'Galeri';

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (path != null)
            Image.file(File(path), fit: BoxFit.cover)
          else
            const _SimulatedImage(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                ),
              ),
              child: Text(
                '$sourceLabel  \u2022  ${formatTanggalId(photo.capturedAt)}, ${formatJamId(photo.capturedAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                _RoundAction(
                  icon: Icons.refresh_rounded,
                  tooltip: 'Ganti foto',
                  onTap: onReplace,
                ),
                const SizedBox(width: 8),
                _RoundAction(
                  icon: Icons.delete_outline_rounded,
                  tooltip: 'Hapus foto',
                  onTap: onRemove,
                  color: AppThemeColors.danger,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SimulatedImage extends StatelessWidget {
  const _SimulatedImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppThemeColors.grey7, AppThemeColors.grey9],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, size: 40, color: AppThemeColors.tertiaryText),
            SizedBox(height: 6),
            Text(
              'Foto simulasi',
              style: TextStyle(fontSize: 12.5, color: AppThemeColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color = AppThemeColors.titleText,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}
