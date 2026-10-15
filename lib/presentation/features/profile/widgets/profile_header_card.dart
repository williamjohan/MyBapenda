// lib/presentation/features/profile/widgets/profile_header_card.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../domain/entities/users/user_entity.dart';
import '../../../shared/widgets/section_label.dart';
import '../../../shared/widgets/status_chip.dart';

/// Kartu atas profil: foto, nama, jabatan, NIP, status aktif.
class ProfileHeaderCard extends StatelessWidget {
  final UserEntity user;

  /// URL foto profil. TODO: isi saat API foto profil tersedia.
  final String? photoUrl;
  final VoidCallback? onEditPhoto;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    this.photoUrl,
    this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isAktif = user.aktif.toLowerCase() == 'aktif';

    return SurfaceCard(
      withPattern: true,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      child: Column(
        children: [
          ProfileAvatar(
            nama: user.nama,
            photoUrl: photoUrl,
            onEdit: onEditPhoto,
          ),
          const SizedBox(height: 14),
          Text(
            user.nama,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.jabatan,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: palette.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'NIP ${user.nip}',
            style: TextStyle(fontSize: 12, color: palette.textTertiary),
          ),
          const SizedBox(height: 12),
          StatusChip(
            label: user.aktif,
            tone: isAktif
                ? BapendaStatusTone.success
                : BapendaStatusTone.neutral,
          ),
        ],
      ),
    );
  }
}

/// Foto profil bulat. Belum ada foto -> inisial nama.
class ProfileAvatar extends StatelessWidget {
  final String nama;
  final String? photoUrl;
  final VoidCallback? onEdit;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.nama,
    this.photoUrl,
    this.onEdit,
    this.radius = 44,
  });

  /// "ROYAN HISYAM RAFLIANSYAH, S. KOM" -> "RH" (gelar diabaikan).
  static String _initials(String nama) {
    final words = nama
        .split(',')
        .first
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first[0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: palette.accent, width: 2),
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: palette.accentSoft,
            backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
            child: hasPhoto
                ? null
                : Text(
                    _initials(nama),
                    style: TextStyle(
                      fontSize: radius * 0.6,
                      fontWeight: FontWeight.w800,
                      color: palette.accent,
                    ),
                  ),
          ),
        ),
        if (onEdit != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: Material(
              color: palette.accent,
              shape: CircleBorder(
                side: BorderSide(color: palette.surface, width: 2),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onEdit,
                child: const Padding(
                  padding: EdgeInsets.all(7),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
