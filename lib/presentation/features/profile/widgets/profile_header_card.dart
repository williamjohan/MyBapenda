import 'package:flutter/material.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../domain/entities/users/user_entity.dart';
import '../../../shared/widgets/bapenda_image.dart';
import '../../../shared/widgets/section_label.dart';
import '../../../shared/widgets/status_chip.dart';

/// Kartu atas profil: foto, nama, jabatan, NIP, status aktif.
class ProfileHeaderCard extends StatelessWidget {
  final UserEntity user;

  /// Naik tiap ganti foto supaya gambar dimuat ulang walau URL sama.
  final int fotoVersi;
  final bool uploadingFoto;
  final VoidCallback? onEditPhoto;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    this.fotoVersi = 0,
    this.uploadingFoto = false,
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
            photoUrl: user.foto?.fotoUrl,
            fotoVersi: fotoVersi,
            uploading: uploadingFoto,
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

/// Foto profil bulat. Belum ada foto / gagal muat -> inisial nama.
class ProfileAvatar extends StatelessWidget {
  final String nama;
  final String? photoUrl;
  final int fotoVersi;
  final bool uploading;
  final VoidCallback? onEdit;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.nama,
    this.photoUrl,
    this.fotoVersi = 0,
    this.uploading = false,
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
    final size = radius * 2;

    final initials = Container(
      width: size,
      height: size,
      color: palette.accentSoft,
      alignment: Alignment.center,
      child: Text(
        _initials(nama),
        style: TextStyle(
          fontSize: radius * 0.6,
          fontWeight: FontWeight.w800,
          color: palette.accent,
        ),
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: palette.accent, width: 2),
          ),
          child: ClipOval(
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasPhoto)
                    BapendaImage(
                      // Key berubah -> state baru -> gambar diunduh ulang.
                      key: ValueKey('$photoUrl#$fotoVersi'),
                      path: photoUrl!,
                      width: size,
                      height: size,
                      cacheWidth: (size * 3).round(),
                      errorWidget: initials,
                    )
                  else
                    initials,
                  if (uploading)
                    const ColoredBox(
                      color: Colors.black45,
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
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
                onTap: uploading ? null : onEdit,
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
