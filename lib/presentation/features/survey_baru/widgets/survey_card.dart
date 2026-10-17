// lib/presentation/features/survey_baru/widgets/survey_card.dart
import 'package:bapendacore/domain/entities/cek_reklames/survey_permohonan_baru/survey_permohonan_entity.dart';
import 'package:bapendacore/presentation/features/survey_baru/widgets/survey_history/history_format.dart';
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:bapendacore/presentation/shared/widgets/status_chip.dart';
import 'package:flutter/material.dart';

class SurveyCard extends StatefulWidget {
  final SurveyPermohonanEntity data;

  /// Dipanggil hanya oleh tombol "Mulai Survey".
  final VoidCallback onTap;
  final bool initiallyExpanded;
  final int? orderNumber;
  final bool pinned;
  final bool skipped;

  const SurveyCard({
    super.key,
    required this.data,
    required this.onTap,
    this.initiallyExpanded = false,
    this.orderNumber,
    this.pinned = false,
    this.skipped = false,
  });

  @override
  State<SurveyCard> createState() => _SurveyCardState();
}

class _SurveyCardState extends State<SurveyCard> {
  static const _ink = Color(0xFF1F2933);
  static const _muted = Color(0xFF7B8794);
  static const _accent = Color(0xFFB8680F);
  static const _line = Color(0xFFEEF0F3);

  late bool _expanded = widget.initiallyExpanded;

  void _toggle() => setState(() => _expanded = !_expanded);

  BapendaStatusTone _toneFor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'disetujui':
        return BapendaStatusTone.success;
      case 'diproses':
        return BapendaStatusTone.warning;
      case 'pengembalian':
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

  ({String text, Color fg, Color bg})? _tenggat() {
    final exp = _parseTanggal(widget.data.expTask);
    if (exp == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sisa = exp.difference(today).inDays;

    if (sisa < 0) {
      return (
        text: 'Terlambat ${-sisa} hari',
        fg: const Color(0xFFD81A48),
        bg: const Color(0xFFFDECEF),
      );
    }
    if (sisa == 0) {
      return (
        text: 'Batas hari ini',
        fg: const Color(0xFFD81A48),
        bg: const Color(0xFFFDECEF),
      );
    }
    if (sisa <= 3) {
      return (
        text: 'Sisa $sisa hari',
        fg: _accent,
        bg: const Color(0xFFFFF4E5),
      );
    }
    return (
      text: 'Sisa $sisa hari',
      fg: const Color(0xFF1B7F4B),
      bg: const Color(0xFFE8F5EE),
    );
  }

  // ---- UI ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final tenggat = _tenggat();
    final fg = tenggat?.fg ?? _muted;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (ketuk untuk buka/tutup)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _toggle,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: widget.skipped
                            ? const Color(0xFFF1F3F5)
                            : (tenggat?.bg ?? const Color(0xFFFFF4E5)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: widget.skipped
                          ? const Icon(
                              Icons.skip_next_rounded,
                              size: 22,
                              color: _muted,
                            )
                          : widget.orderNumber != null
                          ? Text(
                              '${widget.orderNumber}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: tenggat?.fg ?? _accent,
                              ),
                            )
                          : const Icon(
                              Icons.assignment_outlined,
                              size: 20,
                              color: _accent,
                            ),
                    ),
                    if (widget.pinned)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _ink,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.push_pin_rounded,
                            size: 9,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
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
                      if (widget.pinned || widget.skipped) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.skipped
                              ? 'Dilewati hari ini'
                              : 'Prioritas pilihanmu',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: _accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusChip(
                  label: d.statusPermohonan,
                  tone: _toneFor(d.statusPermohonan),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. Lokasi (1 baris saat tertutup)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.place_outlined,
                  size: 17,
                  color: Color(0xFF9AA5B1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  d.lokPenyelenggaraan,
                  maxLines: _expanded ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (d.showReturnBanner) ...[
            _ReturnBanner(
              title: (d.badge?.isVisible ?? false)
                  ? d.badge!.text
                  : 'Dikembalikan dari Penilaian',
              reason: d.ketPengembalian,
              date: d.tglPengembalian,
              color: d.badge?.color ?? 'danger',
            ),
            const SizedBox(height: 12),
          ],

          // 3. Strip tahap + tenggat (selalu tampil)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: tenggat?.bg ?? const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 16, color: fg),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Tahap: ${d.statusProses}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: fg,
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
                // Tanggal hanya saat dibuka
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: _expanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: _DateCell(
                                  label: 'Mulai',
                                  value: d.startTask,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_right_alt_rounded,
                                size: 22,
                                color: _muted,
                              ),
                              Expanded(
                                child: _DateCell(
                                  label: 'Batas Akhir',
                                  value: d.expTask,
                                  alignEnd: true,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),

          // 4. Detail tambahan (hanya saat dibuka)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Tag(
                              icon: Icons.category_outlined,
                              label: d.kategoriPenyelenggaraanNama,
                            ),
                            _Tag(
                              icon: Icons.campaign_outlined,
                              label: d.jenisReklameNama,
                            ),
                            _Tag(
                              icon: Icons.layers_outlined,
                              label: '${d.jumlahSisi} sisi',
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: _line),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.event_outlined,
                              size: 18,
                              color: Color(0xFF9AA5B1),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Masa Tayang',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _muted,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    d.masaTayang,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: _ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${d.masaPajakHari} hari',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),

          const SizedBox(height: 14),

          // 5. Aksi: toggle detail + mulai survey
          Row(
            children: [
              _DetailToggle(expanded: _expanded, onTap: _toggle),
              const SizedBox(width: 10),
              Expanded(
                child: Button(
                  label: d.dikembalikanPenilaian
                      ? 'Survey Ulang'
                      : 'Mulai Survey',
                  icon: d.dikembalikanPenilaian
                      ? Icons.replay_rounded
                      : Icons.arrow_forward_rounded,
                  iconAtEnd: !d.dikembalikanPenilaian,
                  height: 44,
                  onPressed: widget.onTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailToggle extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _DetailToggle({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDBDFE9), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                expanded ? 'Tutup' : 'Detail',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3E4C59),
                ),
              ),
              const SizedBox(width: 2),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: Color(0xFF3E4C59),
                ),
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
          style: const TextStyle(fontSize: 11, color: Color(0xFF7B8794)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2933),
          ),
        ),
      ],
    );
  }
}

class _ReturnBanner extends StatelessWidget {
  final String title;
  final String? reason;
  final DateTime? date;
  final String color;

  const _ReturnBanner({
    required this.title,
    required this.reason,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final warn = color == 'warning';
    final fg = warn ? const Color(0xFFB8680F) : const Color(0xFFD81A48);
    final bg = warn ? const Color(0xFFFFF4E5) : const Color(0xFFFDECEF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.assignment_return_outlined, size: 18, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
                if (reason != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    reason!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF3E4C59),
                    ),
                  ),
                ],
                if (date != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    HistoryFmt.tanggalJam(date),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7B8794),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
