// lib/presentation/features/survey_baru/widgets/survey_card.dart
import 'package:bapendacore/domain/entities/cek_reklames/survey_permohonan_baru/survey_permohonan_entity.dart';
import 'package:bapendacore/core/constants/design_system/tokens/app_palette.dart';
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:bapendacore/presentation/shared/widgets/status_chip.dart';
import 'package:flutter/material.dart';

class SurveyCard extends StatelessWidget {
  final SurveyPermohonanEntity data;
  final VoidCallback onTap;

  const SurveyCard({super.key, required this.data, required this.onTap});

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

  // ---- Tenggat -------------------------------------------------------------

  static const _bulan = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'mei': 5,
    'jun': 6,
    'jul': 7,
    'agu': 8,
    'agt': 8,
    'sep': 9,
    'okt': 10,
    'nov': 11,
    'des': 12,
  };

  /// Format API: "16 Okt 2026". Return null kalau tidak bisa dibaca.
  DateTime? _parseTanggal(String s) {
    final p = s.trim().split(RegExp(r'\s+'));
    if (p.length != 3) return null;
    final d = int.tryParse(p[0]);
    final m = _bulan[p[1].toLowerCase()];
    final y = int.tryParse(p[2]);
    if (d == null || m == null || y == null) return null;
    return DateTime(y, m, d);
  }

  ({String text, Color fg, Color bg})? _tenggat(BuildContext context) {
    final exp = _parseTanggal(data.expTask);
    if (exp == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sisa = exp.difference(today).inDays;

    if (sisa < 0) {
      return (
        text: 'Terlambat ${-sisa} hari',
        fg: context.palette.danger,
        bg: context.palette.dangerSoft,
      );
    }
    if (sisa == 0) {
      return (
        text: 'Batas hari ini',
        fg: context.palette.danger,
        bg: context.palette.dangerSoft,
      );
    }
    if (sisa <= 3) {
      return (
        text: 'Sisa $sisa hari',
        fg: context.palette.accent,
        bg: context.palette.accentSoft,
      );
    }
    return (
      text: 'Sisa $sisa hari',
      fg: context.palette.success,
      bg: context.palette.successSoft,
    );
  }

  // ---- UI ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final tenggat = _tenggat(context);

    return Material(
      color: context.palette.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header: identitas + status permohonan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.palette.accentSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      size: 20,
                      color: context.palette.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nomor Pelayanan',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.palette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.noPelayanan,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: context.palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'NPWPD ${data.npwpd}',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusChip(
                    label: data.statusPermohonan,
                    tone: _toneFor(data.statusPermohonan),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 2. Chip atribut
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Tag(
                    icon: Icons.category_outlined,
                    label: data.kategoriPenyelenggaraanNama,
                  ),
                  _Tag(
                    icon: Icons.campaign_outlined,
                    label: data.jenisReklameNama,
                  ),
                  _Tag(
                    icon: Icons.layers_outlined,
                    label: '${data.jumlahSisi} sisi',
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Divider(height: 1, color: context.palette.border),
              const SizedBox(height: 14),

              // 3. Lokasi + masa tayang
              _IconLine(
                icon: Icons.place_outlined,
                label: 'Lokasi Penyelenggaraan',
                value: data.lokPenyelenggaraan,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _IconLine(
                icon: Icons.event_outlined,
                label: 'Masa Tayang',
                value: data.masaTayang,
                trailing: '${data.masaPajakHari} hari',
              ),

              const SizedBox(height: 14),

              // 4. Strip tenggat tugas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tenggat?.bg ?? context.palette.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 16,
                          color: tenggat?.fg ?? context.palette.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Tahap: ${data.statusProses}',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: tenggat?.fg ?? context.palette.textPrimary,
                            ),
                          ),
                        ),
                        if (tenggat != null)
                          Text(
                            tenggat.text,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: tenggat.fg,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _DateCell(
                            label: 'Mulai',
                            value: data.startTask,
                          ),
                        ),
                        Icon(
                          Icons.arrow_right_alt_rounded,
                          size: 22,
                          color: context.palette.textSecondary,
                        ),
                        Expanded(
                          child: _DateCell(
                            label: 'Batas Akhir',
                            value: data.expTask,
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 5. Aksi utama
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

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Tag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.palette.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.palette.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? trailing;
  final int maxLines;

  const _IconLine({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: context.palette.textTertiary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: context.palette.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: context.palette.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Text(
            trailing!,
            style: TextStyle(
              fontSize: 12,
              color: context.palette.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _DateCell extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _DateCell({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: context.palette.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: context.palette.textPrimary,
          ),
        ),
      ],
    );
  }
}
