// lib/presentation/features/reklame/widgets/survey_sisi_tile.dart
import 'package:bapendacore/presentation/shared/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SurveySisiTile extends StatelessWidget {
  final int seq;
  final String jenisReklame;
  final String materi;
  final String lokasi;
  final String masaTayang;
  final bool hasFoto;
  final bool done;
  final VoidCallback onTap;

  const SurveySisiTile({
    super.key,
    required this.seq,
    required this.jenisReklame,
    required this.materi,
    required this.lokasi,
    required this.masaTayang,
    required this.hasFoto,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sub = GoogleFonts.plusJakartaSans(
      fontSize: 12,
      color: const Color(0xFF7B8794),
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done
                      ? const Color(0xFFE6F6EC)
                      : const Color(0xFFFFF3DC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  done ? Icons.check_rounded : Icons.photo_camera_rounded,
                  color: done
                      ? const Color(0xFF1B8A4B)
                      : const Color(0xFFB8680F),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Sisi $seq',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2933),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: StatusChip(
                            label: jenisReklame,
                            tone: BapendaStatusTone.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      materi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sub.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF52606D),
                      ),
                    ),
                    Text(lokasi, style: sub),
                    Text(masaTayang, style: sub),
                    if (hasFoto)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Foto tersimpan',
                          style: sub.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B8A4B),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                children: [
                  StatusChip(
                    label: done ? 'Selesai' : 'Belum',
                    tone: done
                        ? BapendaStatusTone.success
                        : BapendaStatusTone.warning,
                  ),
                  const SizedBox(height: 10),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFB0B7C0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
