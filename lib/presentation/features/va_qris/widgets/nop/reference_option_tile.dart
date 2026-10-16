import 'package:flutter/material.dart';
import '../../../../../core/theme/theme_kit.dart';
import '../../utils/va_qris_ui_helper.dart';
import 'tax_type_visual.dart';

/// Satu objek pajak yang bisa dipilih: hasil "Cari objek pajak" atau riwayat
/// "Terakhir dicari". Diketuk = isi jenis pajak + NOP lalu cari tagihan.
class ReferenceOptionTile extends StatelessWidget {
  const ReferenceOptionTile({
    super.key,
    required this.taxTypeId,
    required this.taxTypeName,
    required this.referenceNumber,
    required this.name,
    required this.onTap,
    this.address,
  });

  final int taxTypeId;
  final String taxTypeName;
  final String referenceNumber;
  final String name;
  final String? address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final chip = taxTypeShortName(taxTypeId, fallback: taxTypeName);
    final alamat = address;

    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: palette.accentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  taxTypeIcon(taxTypeId),
                  size: 22,
                  color: palette.brandStrong,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      VaQrisUiHelper.teks(name),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                    if (alamat != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        VaQrisUiHelper.teks(alamat),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'NOP $referenceNumber',
                      style: TextStyle(
                        fontSize: 12.5,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.w600,
                        color: palette.accent,
                      ),
                    ),
                  ],
                ),
              ),
              if (chip.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: palette.accentSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    chip,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: palette.brandStrong,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
