import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../shared/widgets/bapenda_sliver_header.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/section_label.dart';
import '../../cubit/aksi/aksi_cubit.dart';
import '../../cubit/aksi/aksi_state.dart';
import 'hasil_checkin_sheet.dart';
import 'lokasi_card.dart';

/// Kerangka halaman aksi: header, kartu lokasi, isi form, tombol kirim di
/// bawah. Galat tampil sebagai snackbar; sukses tampilkan hasil lalu
/// tutup halaman dengan `true` (pemanggil memuat ulang data).
class AksiFormScaffold extends StatelessWidget {
  final String judul;

  /// Judul lembar hasil saat sukses.
  final String judulSukses;
  final String labelKirim;
  final List<Widget> children;
  final VoidCallback onKirim;

  const AksiFormScaffold({
    super.key,
    required this.judul,
    required this.judulSukses,
    required this.labelKirim,
    required this.children,
    required this.onKirim,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return BlocListener<AksiCubit, AksiState>(
      listenWhen: (p, c) =>
          (c.error != null && c.error != p.error) ||
          (c.kirim == KirimStatus.sukses && p.kirim != KirimStatus.sukses),
      listener: (context, state) async {
        if (state.kirim == KirimStatus.sukses && state.antrean != null) {
          // Masuk antrean: langsung kembali, terkirim otomatis.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  '${state.antrean!.jenis.label} tersimpan. '
                  'Dikirim otomatis, walau sedang tanpa sinyal.',
                ),
              ),
            );
          Navigator.of(context).pop(true);
          return;
        }
        if (state.kirim == KirimStatus.sukses) {
          await HasilCheckinSheet.show(
            context,
            judul: judulSukses,
            hasil: state.hasil,
          );
          if (context.mounted) Navigator.of(context).pop(true);
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.error!)));
      },
      child: Scaffold(
        backgroundColor: palette.background,
        body: CustomScrollView(
          slivers: [
            BapendaSliverHeader(title: judul, showBackButton: true),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverList.list(
                children: [
                  const SectionLabel(
                    text: 'Lokasi Check-in',
                    icon: Icons.my_location_rounded,
                  ),
                  const SizedBox(height: 10),
                  const LokasiCard(),
                  const SizedBox(height: 20),
                  ...children,
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: palette.surface,
            border: Border(top: BorderSide(color: palette.border)),
          ),
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12 + MediaQuery.paddingOf(context).bottom,
          ),
          child: BlocBuilder<AksiCubit, AksiState>(
            buildWhen: (p, c) =>
                p.kirim != c.kirim ||
                p.lokasiStatus != c.lokasiStatus ||
                p.fotoDiproses != c.fotoDiproses,
            builder: (context, state) => Button(
              label: labelKirim,
              icon: Icons.send_rounded,
              isLoading: state.kirim == KirimStatus.mengirim,
              onPressed: state.lokasiSiap && state.fotoDiproses == null
                  ? onKirim
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Kolom teks yang mengikuti palette (light/dark).
class AksiTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final bool wajib;

  const AksiTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.wajib = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c),
    );

    return TextField(
      controller: controller,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(color: palette.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: wajib ? '$label *' : label,
        hintText: hint,
        labelStyle: TextStyle(color: palette.textSecondary),
        hintStyle: TextStyle(color: palette.textTertiary),
        filled: true,
        fillColor: palette.surface,
        border: border(palette.border),
        enabledBorder: border(palette.border),
        focusedBorder: border(palette.accent),
      ),
    );
  }
}
