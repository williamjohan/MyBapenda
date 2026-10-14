import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../shared/widgets/qr_scanner_view.dart';
import '../../../../shared/widgets/section_label.dart';
import '../../cubit/aksi/aksi_cubit.dart';
import '../../logic/aksi_validasi.dart';
import '../../widgets/aksi/aksi_form_scaffold.dart';
import '../../widgets/aksi/foto_slot_tile.dart';

enum ModeScanBerkas {
  /// Ambil surat dari kantor (1 manifest, foto pengambilan wajib).
  ambil,

  /// Kembalikan surat gagal/dibatalkan ke kantor.
  kembalikan,
}

/// Scan banyak QR berkas lalu kirim sekali jalan (`POST ambil` / `kembalikan`).
class ScanBerkasPage extends StatefulWidget {
  final ModeScanBerkas mode;

  /// No resi yang sudah terpilih (mis. dari detail berkas).
  final List<String> awal;

  const ScanBerkasPage({super.key, required this.mode, this.awal = const []});

  @override
  State<ScanBerkasPage> createState() => _ScanBerkasPageState();
}

class _ScanBerkasPageState extends State<ScanBerkasPage> {
  static const _maks = 100;
  late final List<String> _resi = [...widget.awal];

  bool get _ambil => widget.mode == ModeScanBerkas.ambil;

  @override
  void initState() {
    super.initState();
    // Langsung buka kamera bila belum ada berkas terpilih.
    if (_resi.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scan());
    }
  }

  Future<void> _scan() async {
    final hasil = await QrScannerView.scanBanyak(
      context,
      judul: _ambil ? 'Scan Surat Diambil' : 'Scan Surat Dikembalikan',
      maks: _maks,
      awal: _resi,
    );
    if (hasil == null || !mounted) return;
    setState(() {
      _resi
        ..clear()
        ..addAll(hasil);
    });
  }

  void _kirim() {
    final cubit = context.read<AksiCubit>();
    if (_ambil) {
      final error = AksiValidasi.ambil(
        jumlahResi: _resi.length,
        foto: cubit.state.foto.keys.toSet(),
      );
      if (error != null) return cubit.tampilkanError(error);
      cubit.kirimAmbil(_resi);
    } else {
      if (_resi.isEmpty) {
        return cubit.tampilkanError('Scan minimal satu QR berkas.');
      }
      cubit.kirimKembalikan(_resi);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AksiFormScaffold(
      judul: _ambil ? 'Ambil Surat' : 'Kembalikan Surat',
      judulSukses: _ambil ? 'Surat berhasil diambil' : 'Surat dikembalikan',
      labelKirim: _ambil
          ? 'Ambil ${_resi.length} Surat'
          : 'Kembalikan ${_resi.length} Surat',
      onKirim: _kirim,
      children: [
        SectionLabel(
          text: '${_resi.length} berkas terscan',
          icon: Icons.qr_code_scanner_rounded,
          trailing: TextButton.icon(
            onPressed: _scan,
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
            label: Text(_resi.isEmpty ? 'Scan QR' : 'Scan lagi'),
          ),
        ),
        const SizedBox(height: 10),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: _resi.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Belum ada berkas. Ketuk "Scan QR" lalu arahkan kamera '
                    'ke QR di setiap surat.',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (final r in _resi)
                      ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.mark_email_read_outlined,
                          color: palette.accent,
                        ),
                        title: Text(
                          r,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: 'Hapus',
                          onPressed: () => setState(() => _resi.remove(r)),
                          icon: Icon(
                            Icons.close_rounded,
                            color: palette.textTertiary,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        if (_ambil) ...[
          const SizedBox(height: 20),
          FotoSlotTile(
            slot: FotoSlot.ambil,
            noResi: '${_resi.length} surat',
            wajib: true,
          ),
        ] else ...[
          const SizedBox(height: 20),
          FotoSlotTile(slot: FotoSlot.lokasi, noResi: '${_resi.length} surat'),
        ],
      ],
    );
  }
}
