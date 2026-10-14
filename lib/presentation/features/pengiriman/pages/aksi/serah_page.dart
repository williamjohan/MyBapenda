import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../../domain/entities/pengiriman/berkas_entity.dart';
import '../../../../../domain/entities/pengiriman/master_pengiriman_entity.dart';
import '../../../../shared/widgets/section_label.dart';
import '../../../../shared/widgets/signature_pad.dart';
import '../../cubit/aksi/aksi_cubit.dart';
import '../../cubit/aksi/aksi_state.dart';
import '../../logic/aksi_validasi.dart';
import '../../widgets/aksi/aksi_form_scaffold.dart';
import '../../widgets/aksi/foto_slot_tile.dart';
import '../../widgets/aksi/opsi_master_picker.dart';

/// Serah terima: Langsung / Dititipkan (penerima, hubungan, foto, TTD) atau
/// Ditempel (foto surat tertempel + foto lokasi; hanya bila `modeTempel`).
class SerahPage extends StatefulWidget {
  final BerkasEntity berkas;

  const SerahPage({super.key, required this.berkas});

  @override
  State<SerahPage> createState() => _SerahPageState();
}

class _SerahPageState extends State<SerahPage> {
  final _nama = TextEditingController();
  final _keterangan = TextEditingController();
  final _ttd = SignatureController();
  final _ttdKey = GlobalKey<SignaturePadState>();

  CaraSerah? _cara;
  OpsiMasterEntity? _hubungan;
  bool _ttdKosong = false;

  String get _noResi => widget.berkas.noResi;

  @override
  void dispose() {
    _nama.dispose();
    _keterangan.dispose();
    _ttd.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    final cubit = context.read<AksiCubit>();
    final error = AksiValidasi.serah(
      cara: _cara,
      namaPenerima: _nama.text,
      idHubungan: _hubungan?.id,
      adaTtd: !_ttd.isEmpty,
      wajibFotoObjek: widget.berkas.wajibFotoObjek,
      foto: cubit.state.foto.keys.toSet(),
    );
    setState(
      () => _ttdKosong = (_cara?.butuhPenerima ?? false) && _ttd.isEmpty,
    );
    if (error != null) return cubit.tampilkanError(error);

    final cara = _cara!;
    String? ttdPath;
    if (cara.butuhPenerima) {
      final ukuran = _ttdKey.currentState?.ukuran;
      ttdPath = ukuran == null ? null : await _ttd.toPngFile(ukuran);
      if (ttdPath == null) {
        return cubit.tampilkanError('Gagal menyimpan tanda tangan.');
      }
    }
    if (!mounted) return;
    cubit.kirimSerah(
      noResi: _noResi,
      cara: cara,
      namaPenerima: _nama.text,
      idHubungan: _hubungan?.id,
      fotoTtdPath: ttdPath,
      keterangan: _keterangan.text,
    );
  }

  /// Opsi cara serah dari master; Ditempel hanya bila berkas `modeTempel`.
  List<CaraSerah> _opsiCara(MasterPengirimanEntity? master) {
    final dariMaster = master?.caraSerah
        .map((o) => CaraSerah.fromId(o.id))
        .whereType<CaraSerah>()
        .toList();
    final semua = (dariMaster == null || dariMaster.isEmpty)
        ? CaraSerah.values
        : dariMaster;
    return [
      for (final c in semua)
        if (c != CaraSerah.ditempel || widget.berkas.modeTempel) c,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cara = _cara;

    return AksiFormScaffold(
      judul: 'Serah Terima',
      judulSukses: 'Serah terima tersimpan',
      labelKirim: 'Kirim Serah Terima',
      onKirim: _kirim,
      children: [
        SectionLabel(text: _noResi, icon: Icons.qr_code_2_rounded),
        const SizedBox(height: 10),
        BlocBuilder<AksiCubit, AksiState>(
          buildWhen: (p, c) => p.master != c.master,
          builder: (context, state) => _CaraSerahPicker(
            opsi: _opsiCara(state.master),
            terpilih: cara,
            onPilih: (c) => setState(() {
              _cara = c;
              _ttdKosong = false;
            }),
          ),
        ),
        if (cara != null && cara.butuhPenerima) ...[
          const SizedBox(height: 20),
          AksiTextField(controller: _nama, label: 'Nama penerima', wajib: true),
          const SizedBox(height: 16),
          BlocBuilder<AksiCubit, AksiState>(
            buildWhen: (p, c) =>
                p.master != c.master || p.masterGagal != c.masterGagal,
            builder: (context, state) => OpsiMasterPicker(
              label: 'Hubungan dengan WP',
              opsi: state.master?.hubunganPenerima,
              gagalMuat: state.masterGagal,
              onMuatUlang: context.read<AksiCubit>().muatMaster,
              terpilih: _hubungan,
              onPilih: (o) => setState(() => _hubungan = o),
            ),
          ),
          const SizedBox(height: 16),
          FotoSlotTile(slot: FotoSlot.serah, noResi: _noResi, wajib: true),
          const SizedBox(height: 16),
          Text(
            'Tanda tangan penerima *',
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SignaturePad(
            key: _ttdKey,
            controller: _ttd,
            errorText: _ttdKosong ? 'Belum ditandatangani' : null,
          ),
        ],
        if (cara == CaraSerah.ditempel) ...[
          const SizedBox(height: 20),
          FotoSlotTile(slot: FotoSlot.tempel, noResi: _noResi, wajib: true),
          const SizedBox(height: 16),
          FotoSlotTile(slot: FotoSlot.lokasi, noResi: _noResi, wajib: true),
        ],
        if (cara != null) ...[
          if (widget.berkas.wajibFotoObjek) ...[
            const SizedBox(height: 16),
            FotoSlotTile(slot: FotoSlot.objek, noResi: _noResi, wajib: true),
          ],
          const SizedBox(height: 16),
          AksiTextField(
            controller: _keterangan,
            label: 'Keterangan',
            maxLines: 2,
          ),
        ],
      ],
    );
  }
}

class _CaraSerahPicker extends StatelessWidget {
  final List<CaraSerah> opsi;
  final CaraSerah? terpilih;
  final ValueChanged<CaraSerah> onPilih;

  const _CaraSerahPicker({
    required this.opsi,
    required this.terpilih,
    required this.onPilih,
  });

  static IconData _icon(CaraSerah c) => switch (c) {
    CaraSerah.langsung => Icons.person_outline_rounded,
    CaraSerah.dititipkan => Icons.people_outline_rounded,
    CaraSerah.ditempel => Icons.push_pin_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cara serah *',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < opsi.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _Pilihan(
                  icon: _icon(opsi[i]),
                  label: opsi[i].label,
                  aktif: opsi[i] == terpilih,
                  onTap: () => onPilih(opsi[i]),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Pilihan extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool aktif;
  final VoidCallback onTap;

  const _Pilihan({
    required this.icon,
    required this.label,
    required this.aktif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: aktif ? palette.accentSoft : palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: aktif ? palette.accent : palette.border,
          width: aktif ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: aktif ? palette.accent : palette.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: aktif ? palette.accent : palette.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
