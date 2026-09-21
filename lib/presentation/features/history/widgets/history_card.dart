import 'package:bapendacore/core/constants/app_colors_new.dart';
import 'package:bapendacore/core/utils/date_format_id.dart';
import 'package:bapendacore/domain/entities/history/history_entity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryCard extends StatelessWidget {
  final HistoryEntity item;
  final VoidCallback onTap;

  const HistoryCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasUkuran = item.hasUkuran;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppThemeColors.defaultBorder.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: AppThemeColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: AppThemeColors.primarySoft.withValues(alpha: 0.4),
          highlightColor: AppThemeColors.primarySoft.withValues(alpha: 0.18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TOP CONTENT
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Thumbnail(url: item.photoUrl),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LOKASI PEMERIKSAAN',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.7,
                              color: AppThemeColors.tertiaryText,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.alamat,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                              color: AppThemeColors.titleText,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    _UkuranBadge(ukuran: item.ukuran),
                  ],
                ),

                const SizedBox(height: 16),

                /// SOFT DIVIDER
                Container(
                  height: 1,
                  color: AppThemeColors.subtleBorder.withValues(alpha: 0.8),
                ),

                const SizedBox(height: 14),

                /// INFORMATION ROW
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.my_location_rounded,
                        label: 'Koordinat',
                        value: item.coordinateLabel,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _InfoItem(
                        icon: Icons.schedule_rounded,
                        label: 'Diperiksa',
                        value: formatTanggalRelatifId(item.insDate),
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// FOOTER CTA
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppThemeColors.primarySoft.withValues(
                            alpha: 0.55,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppThemeColors.defaultSurface,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Icon(
                                Icons.badge_outlined,
                                size: 15,
                                color: AppThemeColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.insBy,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppThemeColors.secondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppThemeColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppThemeColors.primary.withValues(
                              alpha: 0.18,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool alignEnd;

  const _InfoItem({
    required this.icon,
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppThemeColors.tertiaryText),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppThemeColors.tertiaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppThemeColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? url;

  const _Thumbnail({required this.url});

  bool get _hasUrl {
    return url != null && url!.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppThemeColors.primarySoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
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
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 1.8),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _fallback();
                },
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppThemeColors.primarySoft,
      child: Icon(
        Icons.location_on_rounded,
        color: AppThemeColors.primary,
        size: 24,
      ),
    );
  }
}

class _UkuranBadge extends StatelessWidget {
  final String? ukuran;

  const _UkuranBadge({required this.ukuran});

  @override
  Widget build(BuildContext context) {
    final hasValue = ukuran != null && ukuran!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: hasValue
            ? AppThemeColors.successSoft
            : AppThemeColors.grey7.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasValue
              ? AppThemeColors.success.withValues(alpha: 0.15)
              : AppThemeColors.defaultBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.straighten_rounded,
            size: 13,
            color: hasValue
                ? AppThemeColors.success
                : AppThemeColors.tertiaryText,
          ),
          const SizedBox(width: 5),
          Text(
            hasValue ? ukuran! : 'Belum diukur',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: hasValue
                  ? AppThemeColors.success
                  : AppThemeColors.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }
}
