import 'package:flutter/material.dart';

import '../../utils/berkas_style.dart';

/// Chip kecil berwarna dari token status palette (dark-mode aware).
/// Radius & padding sama untuk semua badge (status, SLA, jenis surat).
/// [maxLines] > 1 untuk label panjang (mis. "SK Reklame Bongkar") supaya turun
/// baris, bukan melebar keluar kartu; batasi lebarnya dari luar.
class ToneChip extends StatelessWidget {
  final String label;
  final ToneColors tone;
  final IconData? icon;
  final int maxLines;

  const ToneChip({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: tone.fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              textAlign: maxLines > 1 ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontSize: 11,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: tone.fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge jenis surat yang seragam di semua kartu: lebar maksimal tetap,
/// label panjang ("SK Reklame Bongkar") turun rapi jadi 2 baris.
class JenisSuratBadge extends StatelessWidget {
  final String label;
  final ToneColors tone;

  const JenisSuratBadge({super.key, required this.label, required this.tone});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 88),
      child: ToneChip(label: label, tone: tone, maxLines: 2),
    );
  }
}
