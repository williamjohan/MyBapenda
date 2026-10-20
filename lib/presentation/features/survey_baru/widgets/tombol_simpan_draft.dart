import 'package:flutter/material.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';

/// Tombol Simpan Draft ringkas (ikon + "Draft") di samping tombol utama,
/// supaya label tidak terpotong di bar bawah.
class TombolSimpanDraft extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const TombolSimpanDraft({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final aktif = onPressed != null && !isLoading;
    final warna = context.palette.accent.withValues(alpha: aktif ? 1 : 0.4);

    return Tooltip(
      message: 'Simpan Draft',
      child: SizedBox(
        height: 50,
        child: OutlinedButton(
          onPressed: aktif ? onPressed : null,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            side: BorderSide(color: warna.withValues(alpha: aktif ? 0.6 : 0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: context.palette.accent,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save_outlined, size: 18, color: warna),
                    const SizedBox(width: 6),
                    Text(
                      'Draft',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: warna,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
