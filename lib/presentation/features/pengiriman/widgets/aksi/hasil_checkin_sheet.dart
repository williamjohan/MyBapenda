import 'package:flutter/material.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../../domain/entities/pengiriman/pengiriman_payload_entity.dart';
import '../../utils/berkas_style.dart';

/// Ringkasan hasil kirim per berkas (`HasilCheckin[]`): status baru, atau
/// pesan bila jejak tersimpan tapi status tidak berubah.
class HasilCheckinSheet extends StatelessWidget {
  final String judul;
  final List<HasilCheckinEntity> hasil;

  const HasilCheckinSheet({
    super.key,
    required this.judul,
    required this.hasil,
  });

  static Future<void> show(
    BuildContext context, {
    required String judul,
    required List<HasilCheckinEntity> hasil,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => HasilCheckinSheet(judul: judul, hasil: hasil),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final berubah = hasil.where((h) => !h.diabaikan).length;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: palette.statusSukses,
              ),
              const SizedBox(height: 8),
              Text(
                judul,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (hasil.length > 1) ...[
                const SizedBox(height: 4),
                Text(
                  '$berubah dari ${hasil.length} berkas berhasil diproses',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
              ],
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: hasil.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: palette.border),
                  itemBuilder: (_, i) => _Baris(hasil: hasil[i]),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: palette.accent,
                  minimumSize: const Size.fromHeight(46),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Selesai'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Baris extends StatelessWidget {
  final HasilCheckinEntity hasil;
  const _Baris({required this.hasil});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tone = hasil.diabaikan
        ? (fg: palette.statusWarning, bg: palette.statusWarningSoft)
        : (hasil.status?.tone(palette) ??
              (fg: palette.statusSukses, bg: palette.statusSuksesSoft));
    final pesan = hasil.pesan?.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasil.diabaikan ? Icons.info_outline_rounded : Icons.check_rounded,
            color: tone.fg,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasil.noResi,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (hasil.statusNama?.isNotEmpty ?? false)
                  Text(
                    hasil.statusNama!,
                    style: TextStyle(
                      color: tone.fg,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (pesan != null && pesan.isNotEmpty)
                  Text(
                    pesan,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
