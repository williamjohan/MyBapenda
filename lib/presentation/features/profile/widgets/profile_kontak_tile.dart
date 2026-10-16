import 'package:flutter/material.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../domain/entities/profile/jenis_kontak.dart';
import 'profile_info_section.dart';

/// Baris email / no WA: nilai + tanda terverifikasi + tombol ubah.
class ProfileKontakTile extends StatelessWidget {
  final JenisKontak kontak;
  final String value;
  final bool terverifikasi;
  final VoidCallback onUbah;

  const ProfileKontakTile({
    super.key,
    required this.kontak,
    required this.value,
    required this.terverifikasi,
    required this.onUbah,
  });

  @override
  Widget build(BuildContext context) {
    final kosong = value.trim().isEmpty;

    return ProfileInfoTile(
      item: (
        icon: kontak == JenisKontak.email
            ? Icons.mail_outline_rounded
            : Icons.phone_outlined,
        label: kontak.label,
        value: value,
      ),
      badge: kosong ? null : VerifikasiBadge(terverifikasi: terverifikasi),
      trailing: TextButton(
        onPressed: onUbah,
        style: TextButton.styleFrom(
          foregroundColor: context.palette.accent,
          visualDensity: VisualDensity.compact,
        ),
        child: Text(
          kosong ? 'Tambah' : (terverifikasi ? 'Ubah' : 'Verifikasi'),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Centang hijau "Terverifikasi" / peringatan "Belum terverifikasi".
class VerifikasiBadge extends StatelessWidget {
  final bool terverifikasi;

  const VerifikasiBadge({super.key, required this.terverifikasi});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final fg = terverifikasi ? palette.success : palette.warning;
    final bg = terverifikasi ? palette.successSoft : palette.warningSoft;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            terverifikasi
                ? Icons.verified_rounded
                : Icons.error_outline_rounded,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: 4),
          Text(
            terverifikasi ? 'Terverifikasi' : 'Belum terverifikasi',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
