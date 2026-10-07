import 'package:flutter/material.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../domain/entities/absensi/absen_entity.dart';
import '../../../shared/widgets/button.dart';
import '../constants/absensi_formatters.dart';

Future<void> showHasilAbsenSheet(
  BuildContext context,
  AbsenResultEntity result,
) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: context.palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => HasilAbsenSheet(result: result),
  );
}

class HasilAbsenSheet extends StatelessWidget {
  final AbsenResultEntity result;

  const HasilAbsenSheet({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final lokasi = [
      if (result.namaLokasi != null) result.namaLokasi!,
      if (result.jarakMeter != null)
        AbsensiFormatters.jarak(result.jarakMeter!),
    ].join(' · ');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: palette.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: palette.successSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: palette.success,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              result.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_jenisLabel(result.jenis)} · ${AbsensiFormatters.jam(result.tglPresensi)}',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (lokasi.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.place_outlined,
                    color: palette.textTertiary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      lokasi,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (result.menitTelat > 0)
              _Catatan(
                text: 'Terlambat ${result.menitTelat} menit',
                color: palette.warning,
                background: palette.warningSoft,
              ),
            if (result.menitPsw > 0)
              _Catatan(
                text: 'Pulang ${result.menitPsw} menit lebih cepat',
                color: palette.danger,
                background: palette.dangerSoft,
              ),
            const SizedBox(height: 24),
            Button(
              label: 'Selesai',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  String _jenisLabel(JenisAbsen jenis) {
    switch (jenis) {
      case JenisAbsen.masuk:
        return 'MASUK';
      case JenisAbsen.pulang:
        return 'PULANG';
      case JenisAbsen.scan:
        return 'SCAN';
    }
  }
}

class _Catatan extends StatelessWidget {
  final String text;
  final Color color;
  final Color background;
  const _Catatan({
    required this.text,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
