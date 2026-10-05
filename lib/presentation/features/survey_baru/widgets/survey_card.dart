// lib/presentation/features/reklame/widgets/permohonan_card.dart
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:bapendacore/presentation/shared/widgets/info_row.dart';
import 'package:bapendacore/presentation/shared/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SurveyCard extends StatelessWidget {
  final String nomorPelayanan;
  final String informasiWajibPajak;
  final String kategori;
  final String statusPermohonan;
  final String statusProses;
  final int jumlahSisi;
  final VoidCallback onTap;

  const SurveyCard({
    super.key,
    required this.nomorPelayanan,
    required this.informasiWajibPajak,
    required this.kategori,
    required this.statusPermohonan,
    required this.statusProses,
    required this.jumlahSisi,
    required this.onTap,
  });

  BapendaStatusTone _toneFor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'disetujui':
        return BapendaStatusTone.success;
      case 'diproses':
        return BapendaStatusTone.warning;
      case 'ditolak':
        return BapendaStatusTone.danger;
      default:
        return BapendaStatusTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nomor Pelayanan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: const Color(0xFF7B8794),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nomorPelayanan,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1F2933),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(
                    label: statusPermohonan,
                    tone: _toneFor(statusPermohonan),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFEEF0F3)),
              ),
              InfoRow(
                label: 'Informasi Wajib Pajak',
                value: informasiWajibPajak,
              ),
              InfoRow(label: 'Kategori', value: kategori),
              InfoRow(label: 'Status Proses', value: statusProses),
              InfoRow(label: 'Jumlah Sisi', value: '$jumlahSisi sisi'),
              const SizedBox(height: 12),
              Button(
                label: 'Mulai Survey',
                icon: Icons.arrow_forward_rounded,
                iconAtEnd: true,
                height: 44,
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
