import 'package:bapendacore/domain/entities/cek_reklames/survey_permohonan_baru/survey_history_entity.dart';
import 'package:bapendacore/presentation/shared/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'history_format.dart';

class SurveyHistoryCard extends StatelessWidget {
  final SurveyHistoryEntity data;
  final VoidCallback onTap;

  const SurveyHistoryCard({super.key, required this.data, required this.onTap});

  static const _ink = Color(0xFF1F2933);
  static const _muted = Color(0xFF7B8794);
  static const _accent = Color(0xFFB8680F);
  static const _green = Color(0xFF1B7F4B);

  @override
  Widget build(BuildContext context) {
    final d = data;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5EE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fact_check_outlined,
                      size: 21,
                      color: _green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.noPelayanan,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'NPWPD ${d.npwpd}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: _muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Tahap proses, bukan statusPermohonan (selalu "Diproses").
                  StatusChip(
                    label: d.statusProses,
                    tone: HistoryFmt.toneOf(d.statusProses),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Line(icon: Icons.person_outline_rounded, text: d.namaPemohon),
              const SizedBox(height: 6),
              _Line(icon: Icons.place_outlined, text: d.lokPenyelenggaraan),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Tag(icon: Icons.campaign_outlined, label: d.jenisReklame),
                  _Tag(
                    icon: Icons.layers_outlined,
                    label: '${d.jumlahSisi} sisi',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFEEF0F3)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.event_available_rounded,
                    size: 16,
                    color: _green,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Disurvey ${HistoryFmt.tanggal(d.tglSurvey)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF52606D),
                      ),
                    ),
                  ),
                  const Text(
                    'Lihat detail',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: _accent,
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

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Line({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9AA5B1)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2933),
            ),
          ),
        ),
      ],
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
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF52606D)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3E4C59),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
