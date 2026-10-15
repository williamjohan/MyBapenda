import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/entities/pengiriman/pengiriman_payload_entity.dart';
import '../../../../shared/widgets/section_label.dart';
import '../../cubit/aksi/aksi_cubit.dart';
import '../../widgets/aksi/aksi_form_scaffold.dart';
import '../../widgets/aksi/foto_slot_tile.dart';

/// Check-in Dalam Perjalanan (foto opsional, boleh berkali-kali) atau
/// Tiba di Tujuan (foto lokasi wajib).
class CheckinPage extends StatefulWidget {
  final String noResi;
  final JenisCheckin jenis;

  const CheckinPage({super.key, required this.noResi, required this.jenis});

  @override
  State<CheckinPage> createState() => _CheckinPageState();
}

class _CheckinPageState extends State<CheckinPage> {
  final _keterangan = TextEditingController();

  bool get _tiba => widget.jenis == JenisCheckin.tiba;

  @override
  void dispose() {
    _keterangan.dispose();
    super.dispose();
  }

  void _kirim() {
    context.read<AksiCubit>().kirimCheckin(
      widget.jenis,
      widget.noResi,
      keterangan: _keterangan.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AksiFormScaffold(
      judul: _tiba ? 'Tiba di Tujuan' : 'Dalam Perjalanan',
      judulSukses: _tiba
          ? 'Check-in tiba tersimpan'
          : 'Posisi perjalanan tersimpan',
      labelKirim: _tiba ? 'Kirim Check-in Tiba' : 'Kirim Posisi',
      onKirim: _kirim,
      children: [
        SectionLabel(text: widget.noResi, icon: Icons.qr_code_2_rounded),
        const SizedBox(height: 10),
        FotoSlotTile(
          slot: FotoSlot.lokasi,
          noResi: widget.noResi,
          wajib: _tiba,
        ),
        const SizedBox(height: 16),
        AksiTextField(
          controller: _keterangan,
          label: 'Keterangan',
          hint: _tiba ? 'Mis. patokan lokasi' : 'Mis. menuju Jl. Pemuda',
          maxLines: 2,
        ),
      ],
    );
  }
}
