import 'package:mybapenda/domain/entities/cek_reklames/survey_permohonan_baru/survey_history_entity.dart';
import 'package:mybapenda/presentation/shared/widgets/info_row.dart';
import 'package:flutter/material.dart';
import 'history_format.dart';
import 'history_image.dart';

class HistorySisiCard extends StatefulWidget {
  final HistorySisiEntity sisi;
  final bool initiallyExpanded;

  const HistorySisiCard({
    super.key,
    required this.sisi,
    this.initiallyExpanded = false,
  });

  @override
  State<HistorySisiCard> createState() => _HistorySisiCardState();
}

class _HistorySisiCardState extends State<HistorySisiCard> {
  static const _ink = Color(0xFF1F2933);
  static const _muted = Color(0xFF7B8794);
  static const _accent = Color(0xFFB8680F);

  late bool _open = widget.initiallyExpanded;

  List<Widget> _rows(List<(String, String?)> items) => [
    for (final (label, value) in items)
      if (value != null && value.isNotEmpty)
        InfoRow(label: label, value: value),
  ];

  Widget _section(String title, List<Widget> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: _muted,
            ),
          ),
          const SizedBox(height: 4),
          ...rows,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.sisi;
    final ukuran = HistoryFmt.ukuran(s.panjang, s.lebar, s.tinggi);
    final koordinat = s.hasCoordinate
        ? '${s.latitude!.toStringAsFixed(6)}, ${s.longitude!.toStringAsFixed(6)}'
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _open = !_open),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    '${s.seq}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _accent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.jenisReklame ?? 'Sisi ${s.seq}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          'Sisi ${s.seq}',
                          if (ukuran != null) ukuran,
                          if (s.fotos.isNotEmpty) '${s.fotos.length} foto',
                        ].join(' · '),
                        style: const TextStyle(fontSize: 12, color: _muted),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF52606D),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !_open
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (s.fotos.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 112,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: s.fotos.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final f = s.fotos[i];
                              return GestureDetector(
                                onTap: () => showHistoryPhoto(
                                  context,
                                  f.imageUrl,
                                  caption: f.keterangan,
                                ),
                                child: HistoryImage(
                                  url: f.imageUrl,
                                  width: 150,
                                  height: 112,
                                  radius: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        if (s.fotos.any((f) => f.keterangan != null)) ...[
                          const SizedBox(height: 6),
                          const Text(
                            'Ketuk foto untuk memperbesar dan melihat keterangan.',
                            style: TextStyle(fontSize: 11, color: _muted),
                          ),
                        ],
                      ],
                      _section(
                        'LOKASI',
                        _rows([
                          ('Kecamatan', s.kecamatan),
                          ('Kelurahan', s.kelurahan),
                          ('Lokasi', s.lokPenyelenggaraan),
                          ('Lokasi Tertentu', s.lokasiTertentu),
                          ('No. IMB', s.noImb),
                          ('Koordinat', koordinat),
                        ]),
                      ),
                      _section(
                        'UKURAN & JENIS',
                        _rows([
                          ('Ukuran (P × L × T)', ukuran),
                          ('Jenis Reklame', s.jenisReklame),
                          ('Jenis Produk', s.jenisProduk),
                          ('Letak Reklame', s.letakReklame),
                          ('Status Tanah', s.statusTanah),
                          ('Sudut Pandang', s.sudutPandang),
                        ]),
                      ),
                      _section(
                        'KETERANGAN',
                        _rows([
                          ('Materi', s.materiReklame),
                          ('Ket. Sisi', s.ketSisi),
                          ('Ket. Survey', s.ketSurvey),
                        ]),
                      ),
                      if (s.petugasNama != null || s.diinputPada != null) ...[
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: Color(0xFFEEF0F3)),
                        const SizedBox(height: 10),
                        Text(
                          [
                            if (s.petugasNama != null)
                              'Disurvey oleh ${s.petugasNama}',
                            if (s.diinputPada != null)
                              HistoryFmt.tanggalJam(s.diinputPada),
                          ].join(' · '),
                          style: const TextStyle(fontSize: 11.5, color: _muted),
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
