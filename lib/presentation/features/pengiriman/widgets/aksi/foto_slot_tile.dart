import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../cubit/aksi/aksi_cubit.dart';
import '../../cubit/aksi/aksi_state.dart';
import '../../logic/aksi_validasi.dart';

/// Kotak foto untuk satu [FotoSlot]: ketuk untuk ambil dari kamera,
/// tampil pratinjau + tombol ulang/hapus setelah ada.
class FotoSlotTile extends StatelessWidget {
  final FotoSlot slot;
  final String noResi;
  final bool wajib;

  const FotoSlotTile({
    super.key,
    required this.slot,
    required this.noResi,
    this.wajib = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<AksiCubit>();

    return BlocBuilder<AksiCubit, AksiState>(
      buildWhen: (p, c) =>
          p.foto[slot] != c.foto[slot] || p.fotoDiproses != c.fotoDiproses,
      builder: (context, state) {
        final path = state.foto[slot];
        final proses = state.fotoDiproses == slot;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text: slot.label,
                children: [
                  TextSpan(
                    text: wajib ? '  *wajib' : '  (opsional)',
                    style: TextStyle(
                      color: wajib ? palette.statusGagal : palette.textTertiary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Material(
                color: palette.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: proses
                      ? null
                      : () => cubit.ambilFoto(slot, noResi: noResi),
                  child: path == null
                      ? Center(
                          child: proses
                              ? CircularProgressIndicator(color: palette.accent)
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 32,
                                      color: palette.accent,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Ambil foto',
                                      style: TextStyle(
                                        color: palette.textSecondary,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(path),
                              fit: BoxFit.cover,
                              cacheWidth: 800,
                            ),
                            if (proses)
                              const ColoredBox(
                                color: Colors.black38,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Row(
                                children: [
                                  _Aksi(
                                    icon: Icons.cameraswitch_outlined,
                                    tooltip: 'Ambil ulang',
                                    onTap: () =>
                                        cubit.ambilFoto(slot, noResi: noResi),
                                  ),
                                  const SizedBox(width: 6),
                                  _Aksi(
                                    icon: Icons.delete_outline_rounded,
                                    tooltip: 'Hapus',
                                    onTap: () => cubit.hapusFoto(slot),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Aksi extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _Aksi({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
