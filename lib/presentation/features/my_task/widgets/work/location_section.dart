import 'package:bapendacore/core/utils/date_format_id.dart';
import 'package:bapendacore/domain/entities/my_task/task_location_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';
import 'form_section_card.dart';

/// Geotag lokasi petugas saat ini.
///
/// TODO(tech-debt): izin lokasi ditolak, GPS mati, akurasi rendah, deteksi
/// mock location, dan jarak ke objek pajak (geofencing) belum ditangani.
class LocationSection extends StatelessWidget {
  const LocationSection({
    super.key,
    required this.step,
    required this.location,
    required this.isLoading,
    required this.onFetch,
  });

  final int step;
  final TaskLocationEntity? location;
  final bool isLoading;
  final VoidCallback onFetch;

  @override
  Widget build(BuildContext context) {
    final loc = location;
    return FormSectionCard(
      step: step,
      title: 'Lokasi',
      subtitle: 'Koordinat Anda saat mengerjakan tugas',
      isDone: loc != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (loc != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppThemeColors.defaultBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location_rounded, color: AppThemeColors.gold),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${loc.latitude.toStringAsFixed(6)}, ${loc.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppThemeColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Akurasi \u00b1${loc.accuracyMeters.round()} m  \u2022  ${formatJamId(loc.capturedAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppThemeColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onFetch,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : Icon(
                      loc == null
                          ? Icons.gps_fixed_rounded
                          : Icons.refresh_rounded,
                      size: 20,
                    ),
              label: Text(
                isLoading
                    ? 'Mencari lokasi...'
                    : loc == null
                    ? 'Ambil lokasi saat ini'
                    : 'Perbarui lokasi',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppThemeColors.gold,
                side: const BorderSide(color: AppThemeColors.primary),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
