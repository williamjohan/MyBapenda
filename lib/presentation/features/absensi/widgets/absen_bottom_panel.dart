import 'package:flutter/material.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../cubit/absen/absen_state.dart';
import 'hold_to_absen_button.dart';

/// Panel bawah yang menempel: tombol tahan-untuk-absen + status singkat.
/// Dipasang sebagai `bottomNavigationBar` agar selalu terlihat saat scroll.
class AbsenBottomPanel extends StatefulWidget {
  final AbsenStep? busyStep;
  final bool sudahMasuk;
  final VoidCallback onAbsen;

  const AbsenBottomPanel({
    super.key,
    required this.busyStep,
    required this.sudahMasuk,
    required this.onAbsen,
  });

  @override
  State<AbsenBottomPanel> createState() => _AbsenBottomPanelState();
}

class _AbsenBottomPanelState extends State<AbsenBottomPanel> {
  bool _holding = false;

  String get _judul {
    switch (widget.busyStep) {
      case AbsenStep.locating:
        return 'Mengambil lokasi…';
      case AbsenStep.submitting:
        return 'Mengirim absen…';
      case null:
        if (_holding) return 'Terus tahan…';
        return widget.sudahMasuk
            ? 'Tahan untuk absen pulang'
            : 'Tahan untuk absen masuk';
    }
  }

  String get _subjudul {
    if (widget.busyStep != null) return 'Jangan tutup aplikasi';
    if (_holding) return 'Lepas sebelum penuh untuk membatalkan';
    return 'Tekan & tahan sidik jari sampai lingkaran penuh';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: palette.border)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HoldToAbsenButton(
                size: 96,
                isBusy: widget.busyStep != null,
                onCompleted: widget.onAbsen,
                onHoldChanged: (v) => setState(() => _holding = v),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _judul,
                  key: ValueKey(_judul),
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _subjudul,
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textTertiary, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
