import 'package:bapendacore/core/constants/app_colors_new.dart';
import 'package:bapendacore/core/utils/date_format_id.dart';
import 'package:bapendacore/domain/entities/history/history_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showHistoryDetailSheet(BuildContext context, HistoryEntity item) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _HistoryDetailSheet(item: item),
  );
}

class _HistoryDetailSheet extends StatelessWidget {
  final HistoryEntity item;
  const _HistoryDetailSheet({required this.item});

  Future<void> _openMaps(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${item.lat},${item.lng}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka aplikasi peta')),
      );
    }
  }

  void _copy(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label disalin')));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: AppThemeColors.defaultSurface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppThemeColors.defaultBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _PhotoPreview(url: item.photoUrl),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppThemeColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppThemeColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.alamat,
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppThemeColors.titleText,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DetailRow(
              icon: Icons.straighten_rounded,
              label: 'Ukuran reklame',
              value:
                  item.hasUkuran ? item.ukuran! : 'Belum ada hasil pengukuran',
              valueColor: item.hasUkuran
                  ? AppThemeColors.success
                  : AppThemeColors.tertiaryText,
            ),
            _DetailRow(
              icon: Icons.my_location_rounded,
              label: 'Koordinat',
              value: item.coordinateLabel,
              trailing: IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                color: AppThemeColors.secondaryText,
                onPressed: () =>
                    _copy(context, item.coordinateLabel, 'Koordinat'),
              ),
            ),
            _DetailRow(
              icon: Icons.schedule_rounded,
              label: 'Waktu pemeriksaan',
              value:
                  '${formatTanggalId(item.insDate)} • ${formatJamId(item.insDate)}',
            ),
            _DetailRow(
              icon: Icons.badge_outlined,
              label: 'Petugas',
              value: item.insBy,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _openMaps(context),
                icon: const Icon(Icons.map_rounded, size: 18),
                label: Text(
                  'Buka di Google Maps',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  final String? url;
  const _PhotoPreview({required this.url});

  bool get _hasUrl => url != null && url!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final heroTag = 'history_photo_${url ?? 'none'}';
    return GestureDetector(
      onTap: _hasUrl ? () => _openFullScreen(context, heroTag) : null,
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: double.infinity,
            height: 180,
            child: _hasUrl
                ? Image.network(
                    url!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AppThemeColors.grey7,
                        child: const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        _placeholder(),
                  )
                : _placeholder(),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppThemeColors.grey7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: AppThemeColors.tertiaryText,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            'Tidak ada foto',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppThemeColors.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }

  void _openFullScreen(BuildContext context, String heroTag) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) =>
            _FullScreenPhoto(url: url!, heroTag: heroTag),
      ),
    );
  }
}

class _FullScreenPhoto extends StatelessWidget {
  final String url;
  final String heroTag;
  const _FullScreenPhoto({required this.url, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: heroTag,
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppThemeColors.tertiaryText),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AppThemeColors.tertiaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppThemeColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}