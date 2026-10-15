import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../../domain/entities/pengiriman/master_pengiriman_entity.dart';
import '../../../../shared/widgets/section_label.dart';
import '../../cubit/aksi/aksi_cubit.dart';
import '../../cubit/aksi/aksi_state.dart';
import '../../../../../domain/entities/pengiriman/pengiriman_payload_entity.dart';
import '../../widgets/aksi/aksi_form_scaffold.dart';
import '../../widgets/aksi/foto_slot_tile.dart';
import '../../widgets/aksi/opsi_master_picker.dart';

/// Gagal antar: alasan (master), keterangan bila wajib, foto bukti.
class GagalPage extends StatefulWidget {
  final String noResi;

  const GagalPage({super.key, required this.noResi});

  @override
  State<GagalPage> createState() => _GagalPageState();
}

class _GagalPageState extends State<GagalPage> {
  final _keterangan = TextEditingController();
  OpsiMasterEntity? _alasan;

  @override
  void dispose() {
    _keterangan.dispose();
    super.dispose();
  }

  void _kirim() => context.read<AksiCubit>().kirimGagal(
    noResi: widget.noResi,
    alasan: _alasan,
    keterangan: _keterangan.text,
  );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AksiFormScaffold(
      judul: 'Gagal Antar',
      judulSukses: 'Gagal antar tercatat',
      labelKirim: 'Kirim Laporan Gagal',
      onKirim: _kirim,
      children: [
        SectionLabel(text: widget.noResi, icon: Icons.qr_code_2_rounded),
        const SizedBox(height: 10),
        BlocBuilder<AksiCubit, AksiState>(
          buildWhen: (p, c) =>
              p.master != c.master || p.masterGagal != c.masterGagal,
          builder: (context, state) => OpsiMasterPicker(
            label: 'Alasan gagal',
            opsi: state.master?.alasanGagal,
            gagalMuat: state.masterGagal,
            onMuatUlang: context.read<AksiCubit>().muatMaster,
            terpilih: _alasan,
            onPilih: (o) => setState(() => _alasan = o),
          ),
        ),
        const SizedBox(height: 16),
        AksiTextField(
          controller: _keterangan,
          label: 'Keterangan',
          hint: 'Mis. rumah kosong, sudah 2x diketuk',
          maxLines: 3,
          wajib: _alasan?.wajibKeterangan ?? false,
        ),
        const SizedBox(height: 16),
        FotoSlotTile(slot: FotoSlot.gagal, noResi: widget.noResi, wajib: true),
        const SizedBox(height: 8),
        Text(
          'Surat tetap dibawa. Setelah gagal, kembalikan surat ke kantor '
          'lewat menu Kembalikan (scan QR).',
          style: TextStyle(color: palette.textTertiary, fontSize: 12),
        ),
      ],
    );
  }
}
