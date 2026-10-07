import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../shared/widgets/theme_toggle_button.dart';
import '../constants/absensi_formatters.dart';
import 'live_clock.dart';

/// Konten hero di atas gradient: bar atas, sapaan, jam live,
/// dan ringkasan MASUK / PULANG (kartu kaca).
class AbsensiHero extends StatelessWidget {
  final String? nama;
  final DateTime tanggal;
  final DateTime? masuk;
  final DateTime? pulang;
  final int menitTelat;
  final int menitPulangCepat;
  final bool isLoading;
  final VoidCallback onBack;
  final String? jamMasukJadwal;
  final String? jamPulangJadwal;

  const AbsensiHero({
    super.key,
    required this.nama,
    required this.tanggal,
    required this.masuk,
    required this.pulang,
    required this.menitTelat,
    required this.menitPulangCepat,
    required this.isLoading,
    required this.onBack,
    this.jamMasukJadwal,
    this.jamPulangJadwal,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  tooltip: 'Kembali',
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Expanded(
                  child: Text(
                    'Absensi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const ThemeToggleButton(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeletonizer(
                    enabled: isLoading && nama == null,
                    effect: ShimmerEffect(
                      baseColor: Colors.white.withValues(alpha: 0.25),
                      highlightColor: Colors.white.withValues(alpha: 0.45),
                    ),
                    child: Text(
                      '${_sapaan(DateTime.now())}, ${_namaPendek(nama)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const LiveClock(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    AbsensiFormatters.tanggal(tanggal),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _JadwalChip(
                    text: jamMasukJadwal == null
                        ? 'Tanpa jadwal hari ini'
                        : 'Jadwal $jamMasukJadwal – ${jamPulangJadwal ?? '-'}',
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _GlassJam(
                          label: 'MASUK',
                          icon: Icons.login_rounded,
                          dot: const Color(0xFF86EFAC),
                          jam: AbsensiFormatters.jam(masuk),
                          badge: menitTelat > 0
                              ? 'Telat $menitTelat mnt'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GlassJam(
                          label: 'PULANG',
                          icon: Icons.logout_rounded,
                          dot: const Color(0xFFFCA5A5),
                          jam: AbsensiFormatters.jam(pulang),
                          badge: menitPulangCepat > 0
                              ? 'Cepat $menitPulangCepat mnt'
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _sapaan(DateTime now) {
    final h = now.hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  /// "MOCHAMMAD MIFTACHUN NAJIB" → "Mochammad Miftachun"
  static String _namaPendek(String? nama) {
    if (nama == null || nama.trim().isEmpty) return 'Pegawai Bapenda';
    return nama
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map(
          (w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class _GlassJam extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color dot;
  final String jam;
  final String? badge;

  const _GlassJam({
    required this.label,
    required this.icon,
    required this.dot,
    required this.jam,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.7)),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              jam,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          SizedBox(
            height: 16,
            child: badge == null
                ? null
                : Text(
                    badge!,
                    style: const TextStyle(
                      color: Color(0xFFFDE68A),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _JadwalChip extends StatelessWidget {
  final String text;
  const _JadwalChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
