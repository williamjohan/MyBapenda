import 'package:mybapenda/presentation/shared/widgets/button.dart';
import 'package:flutter/material.dart';
import 'survey_deadline.dart';
import 'survey_map_point.dart';

class SurveyTaskDetail extends StatelessWidget {
  final SurveyMapPoint point;
  final int number;
  final String? legText;
  final bool pinned;
  final bool skipped;
  final bool isFirst;
  final VoidCallback? onStart;
  final VoidCallback? onFirst;
  final VoidCallback? onSkip;
  final VoidCallback? onRestore;

  const SurveyTaskDetail({
    super.key,
    required this.point,
    required this.number,
    required this.legText,
    required this.pinned,
    required this.skipped,
    required this.isFirst,
    this.onStart,
    this.onFirst,
    this.onSkip,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final st = SurveyDeadline.styleOf(point.daysLeft);
    final boxFg = skipped ? const Color(0xFF7B8794) : st.fg;
    final boxBg = skipped ? const Color(0xFFF1F3F5) : st.bg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris pertama: nomor urut, nomor pelayanan, dan tenggat.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: boxBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    skipped ? '–' : '$number',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: boxFg,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      point.nomor,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2933),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: st.bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    st.text,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: st.fg,
                    ),
                  ),
                ),
              ],
            ),

            // Baris kedua: alamat menggunakan ruang lebih lebar.
            const SizedBox(height: 9),
            Padding(
              padding: const EdgeInsets.only(left: 38),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Color(0xFF7B8794),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      point.lokasi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: Color(0xFF52606D),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Baris ketiga: jumlah sisi sebagai informasi pendukung.
            Padding(
              padding: const EdgeInsets.only(left: 38, top: 5),
              child: Row(
                children: [
                  const Icon(
                    Icons.layers_outlined,
                    size: 14,
                    color: Color(0xFF7B8794),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${point.jumlahSisi} sisi reklame',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7B8794),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (pinned || skipped) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                skipped ? Icons.skip_next_rounded : Icons.push_pin_rounded,
                size: 14,
                color: const Color(0xFFB8680F),
              ),
              const SizedBox(width: 5),
              Text(
                skipped ? 'Dilewati hari ini' : 'Prioritas pilihanmu',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB8680F),
                ),
              ),
            ],
          ),
        ],
        if (legText != null && !skipped) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.directions_car_filled_outlined,
                size: 15,
                color: Color(0xFF3B6FF5),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  legText!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF52606D),
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        if (skipped)
          Button(
            label: 'Kembalikan ke Urutan',
            icon: Icons.undo_rounded,
            variant: BapendaButtonVariant.outlined,
            height: 42,
            onPressed: onRestore,
          )
        else
          Row(
            children: [
              if (!isFirst && onFirst != null) ...[
                Expanded(
                  child: Button(
                    label: 'Kerjakan Dulu',
                    icon: Icons.vertical_align_top_rounded,
                    variant: BapendaButtonVariant.outlined,
                    height: 42,
                    onPressed: onFirst,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Button(
                  label:
                      'Mulai Survey', // [UBAH] dulu: point.isDemo ? 'Data contoh' : ...
                  icon: Icons.arrow_forward_rounded,
                  iconAtEnd: true,
                  height: 42,
                  onPressed: onStart,
                ),
              ),
            ],
          ),
        if (!skipped && onSkip != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onSkip,
              icon: const Icon(Icons.skip_next_rounded, size: 18),
              label: const Text('Lewati hari ini'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7B8794),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
      ],
    );
  }
}
